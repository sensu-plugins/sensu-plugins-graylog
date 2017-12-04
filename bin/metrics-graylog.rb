#! /usr/bin/env ruby
#
#   metrics-graylog.rb
#
# DESCRIPTION:
#
# OUTPUT:
#   metric data
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: sensu-plugin
#   gem: rest-client
#   gem: json
#
# USAGE:
#   metrics-graylog.rb -u user -p passwd
#
# NOTES:
#   Without --all, this script returns two metrics, as the original version of
#   this script did:
#
#         graylog metric metric name                             ->             sensu metric name
#   org.graylog2.shared.journal.KafkaJournal.uncommittedMessages -> graylog.HOST.graylog.kafkajournal.uncommittedMessages
#   org.graylog2.shared.journal.KafkaJournal.unflushedMessages   -> graylog.HOST.graylog.kafkajournal.unflushedMessages
#
# LICENSE:
#   nathan hruby <nhruby@gmail.com
#   SugarCRM
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/metric/cli'
require 'json'
require 'rest-client'

class MetricsGraylog < Sensu::Plugin::Metric::CLI::Graphite
  option :protocol,
         description: 'Protocol for connecting to Graylog',
         short: '-proto',
         long: '--protocol PROTOCOL',
         default: 'http'

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

  option :scheme,
         description: 'All metric naming scheme',
         long: '--scheme SCHEME',
         short: '-s SCHEME',
         default: "#{Socket.gethostname}.graylog"

  option :all,
         description: 'Get all metrics',
         long: '--all',
         boolean: true,
         default: false

  def run
    if config[:all]
      all_output
    else
      original_output
    end
    ok
  rescue => e
    unknown e.message
  end

  def acquire_stats
    resource = RestClient::Resource.new "#{config[:protocol]}://#{config[:host]}:#{config[:port]}#{config[:apipath]}/system/metrics", config[:username], config[:password]
    JSON.parse(resource.get)
  rescue Errno::ECONNREFUSED => e
    critical e.message
  end

  # XXX: only doing counters and guages since they map nicely to line data
  # format.  Skipping meters, histograms, and timers till I can figure out
  # sensible representation.  I don't want to throw bad data in and then have
  # to maintain it forever.
  def all_output
    data = acquire_stats
    timestamp = Time.now.to_i
    # sample line
    # some-hostname-here.graylog.gauges.org.graylog2.shared.journal.KafkaJournal.writtenMessages 123 1489185301
    %w( gauges counters ).each do |type|
      data[type].each do |k, v|
        # XXX: nrh: this is a random array but I have no idea what it supposed to
        # contain
        next if k == 'jvm.threads.deadlocks'
        output format('%s %2f %d', "#{config[:scheme]}.#{type}.#{k}", v['value'].to_f, timestamp)
      end
    end
  end

  def original_output
    data = acquire_stats
    timestamp = Time.now.to_i
    host = Socket.gethostname
    uncommitted_messages = data['gauges']['org.graylog2.shared.journal.KafkaJournal.uncommittedMessages']['value']
    unflushed_messages = data['gauges']['org.graylog2.shared.journal.KafkaJournal.unflushedMessages']['value']
    output format('graylog.%s.graylog.kafkajournal.uncommittedMessages %d %d', host, uncommitted_messages, timestamp)
    output format('graylog.%s.graylog.kafkajournal.unflushedMessages %d %d', host, unflushed_messages, timestamp)
  end
end
