#! /usr/bin/env ruby
#  encoding: UTF-8
#   check-graylog2-alive.rb
#
# DESCRIPTION:
#   This plugin checks the the status of the Graylog2 Server using the
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
#   ./check-graylog2-alive.rb -u admin -p 12345
#
# NOTES:
#   This plugin requires a username and password with permission to access
#   the /system API call in the Graylog2 server. A basic non-admin, reader
#   only account will do.
#
# LICENSE:
#   Adam Ashley <aashley@adamashley.name>
#   Swift Networks
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'json'
require 'rest-client'

class CheckGraylog2Alive < Sensu::Plugin::Check::CLI
  option :host,
         description: 'Graylog2 host',
         short: '-h',
         long: '--host HOST',
         default: 'localhost'

  option :username,
         description: 'Graylog2 username',
         short: '-u',
         long: '--username USERNAME',
         default: 'admin',
         required: true

  option :password,
         description: 'Graylog2 password',
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

  def run
    res = vhost_alive?

    if res['status'] == 'ok'
      ok res['message']
    elsif res['status'] == 'critical'
      critical res['message']
    else
      unknown res['message']
    end
  end

  def vhost_alive?
    host     = config[:host]
    port     = config[:port]
    username = config[:username]
    password = config[:password]
    apipath  = config[:apipath]

    lifecycle_ok = ['override lb:alive', 'running']

    begin
      resource = RestClient::Resource.new "http://#{host}:#{port}#{apipath}/system", username, password
      # Attempt to parse response (just to trigger parse exception)
      response = JSON.parse(resource.get)
      status_text = "#{response['lifecycle']}/#{response['is_processing']}/#{response['lb_status']}"
      if lifecycle_ok.include?(response['lifecycle']) && response['is_processing'] && response['lb_status'] == 'alive'
        { 'status' => 'ok', 'message' => "Graylog2 server is: #{status_text}" }
      else
        { 'status' => 'critical', 'message' => "Graylog2 server is responding but not healthy: #{status_text}" }
      end
    rescue Errno::ECONNREFUSED => e
      { 'status' => 'critical', 'message' => e.message }
    rescue => e
      { 'status' => 'unknown', 'message' => e.message }
    end
  end
end
