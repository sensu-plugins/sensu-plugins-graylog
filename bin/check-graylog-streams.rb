#!/usr/bin/env ruby
#
# Checks Graylog paused streams
# ===
#
# DESCRIPTION:
#   This plugin checks Graylog for any 'paused' streams.
#
# OUTPUT:
#   plain-text
#
# PLATFORMS:
#   all
#
# DEPENDENCIES:
#   A graylog user with streams:read permission (admin or role perm)
#
# LICENSE:
#   Seandy Wibowo <swibowo@sugarcrm.com>
#   nathan hruby <nhruby@sugarcrm.com>
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.

require 'sensu-plugin/check/cli'
require 'rest-client'
require 'json'

class CheckGraylogStreams < Sensu::Plugin::Check::CLI
  option :username,
         short:       '-u',
         long:        '--username USERNAME',
         description: 'Graylog Username',
         required:    true

  option :password,
         short:       '-p',
         long:        '--password PASSWORD',
         description: 'Graylog Password',
         required:    true

  option :host,
         short:       '-h',
         long:        '--host GRAYLOG_HOST',
         description: 'Graylog host to query',
         default:     'localhost'

  option :port,
         short:       '-P',
         long:        '--port GRAYLOG_PORT',
         description: 'Graylog port to query',
         default:     12_900

  option :apipath,
         short:       '-a',
         long:        '--apipath /api',
         description: 'Graylog API path prefix',
         default:     ''

  def graylog_streams
    resource = RestClient::Resource.new(
      "http://#{config[:host]}:#{config[:port]}#{config[:apipath]}/streams",
      user: config[:username],
      password: config[:password],
      timeout: 10
    )
    JSON.parse(resource.get, symbolize_names: true)

  rescue RestClient::RequestTimeout
    unknown 'Connection timeout'
  rescue SocketError
    unknown 'Network unavailable'
  rescue RestClient::Unauthorized
    unknown 'Missing or incorrect API credentials'
  rescue JSON::ParserError
    unknown 'API returned invalid JSON'
  end

  def run
    streams = graylog_streams
    disabled_streams = streams[:streams].select { |s| (s[:disabled] == true) }

    if disabled_streams.count > 0
      streams_desc = []
      disabled_streams.each { |v| streams_desc.push(v[:title]) }

      critical("Streams currently paused/disabled: #{streams_desc.join(', ')}")
    else
      ok('No streams are paused')
    end
  end
end
