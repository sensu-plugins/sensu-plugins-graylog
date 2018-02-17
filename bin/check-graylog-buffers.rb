#! /usr/bin/env ruby
#  encoding: UTF-8
#   check-graylog-buffers.rb
#
# DESCRIPTION:
#   This plugin checks the the status of the Graylog2 buffers using the
#   REST API normally available on port 12900
#
# OUTPUT:
#   plain text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: json
#   gem: rest-client
#
# USAGE:
#   ./check-graylog-buffers.rb -u admin -p 12345
#
# NOTES:
#   This plugin requires a username and password with permission to access
#   the /system API call in the Graylog2 server. A basic non-admin, reader
#   only account will do.
#
# LICENSE:
#   nathan hruby <nhruby@gmail.com>
#   SugarCRM
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'json'
require 'rest-client'

class CheckGraylogBuffers < Sensu::Plugin::Check::CLI
  option :protocol,
         description: 'Protocol for connecting to Graylog',
         long: '--protocol PROTOCOL',
         default: 'http'

  option :insecure,
         description: 'Use insecure connections by not verifying SSL certs',
         short: '-k',
         long: '--insecure',
         boolean: true,
         default: false

  option :host,
         description: 'Graylog host',
         short: '-h',
         long: '--host HOST',
         default: 'localhost'

  option :username,
         description: 'Graylog username',
         short: '-u',
         long: '--username USERNAME',
         default: 'admin',
         required: true

  option :password,
         description: 'Graylog password',
         short: '-p',
         long: '--password PASSWORD',
         required: true

  option :port,
         description: 'Graylog API port',
         short: '-P',
         long: '--port PORT',
         default: '12900'

  option :apipath,
         description: 'Graylog API path prefix',
         short: '-a',
         long: '--apipath /api',
         default: ''

  option :warn,
         short: '-w WARNING',
         long: '--warning',
         proc: proc(&:to_f),
         default: 80

  option :crit,
         short: '-c CRITICAL',
         long: '--critical',
         proc: proc(&:to_f),
         default: 90

  def run
    version = acquire_version
    if Gem::Version.new(version) < Gem::Version.new('2.1.0')
      check_pre_210_buffers
    else
      check_210_buffers
    end
  rescue StandardError => e
    unknown e.message
  end

  def call_api(path, postdata = nil)
    resource = RestClient::Resource.new(
      "#{config[:protocol]}://#{config[:host]}:#{config[:port]}#{config[:apipath]}#{path}",
      user: config[:username],
      password: config[:password],
      verify_ssl: !config[:insecure]
    )

    if !postdata
      JSON.parse(resource.get)
    else
      JSON.parse(resource.post(postdata.to_json, content_type: :json, accept: :json))
    end
  rescue Errno::ECONNREFUSED => e
    critical e.message
  end

  def acquire_version
    ret = call_api('/system')
    ret['version'].split('+')[0]
  end

  # https://github.com/Graylog2/graylog2-server/commit/0bd45c69f65011b50cb1e101c4a9c2eac97c0266
  def check_pre_210_buffers
    ret = call_api('/system/buffers')
    utilization = ret['buffers']['process']['utilization_percent'].to_f
    if utilization >= config[:crit]
      critical format('process buffer utilization is %.2f%%, threshold is %.2f%%', utilization, config[:crit])
    elsif utilization >= config[:warn]
      warn format('process buffer utilization is %.2f%%, threshold is %.2f%%', utilization, config[:warn])
    else
      ok format('process buffer utilization is %.2f%%', utilization)
    end
  end

  def check_210_buffers
    postdata = {
      'metrics' => [
        'org.graylog2.buffers.input.usage',
        'org.graylog2.buffers.input.size',
        'org.graylog2.buffers.process.usage',
        'org.graylog2.buffers.process.size',
        'org.graylog2.buffers.output.usage',
        'org.graylog2.buffers.output.size'
      ]
    }
    ret = call_api('/system/metrics/multiple', postdata)

    if ret['total'] != 6
      unkown format('API responded with incorrect number of metrics, got %d expected 6', ret['total'])
    end

    metric_pct = {}
    %w(input process output).each do |m|
      begin
        usage = ret['metrics'].find { |x| x['full_name'] == "org.graylog2.buffers.#{m}.usage" }
        size = ret['metrics'].find { |x| x['full_name'] == "org.graylog2.buffers.#{m}.size" }
        metric_pct[m] = (usage['metric']['value'].to_f / size['metric']['value'].to_f) * 100.0
      rescue ZeroDivisionError
        metric_pct[m] = 0.0
      end
    end

    message = format('buffer utilization is %.2f%%/%.2f%%/%.2f%%', metric_pct['input'], metric_pct['process'], metric_pct['output'])
    metric_pct.each do |m, p|
      if p >= config[:crit]
        critical format('%s buffer exceeds %.2f%%, %s', m, config[:crit], message)
      elsif p >= config[:warn]
        warn format('%s buffer exceeds %.2f%%, %s', m, config[:warn], message)
      end
    end
    ok message
  end
end
