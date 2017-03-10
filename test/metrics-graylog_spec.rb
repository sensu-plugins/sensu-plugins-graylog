require_relative './spec_helper.rb'
require_relative '../bin/metrics-graylog.rb'

describe 'MetricsGraylog', '#run' do
  before(:all) do
    MetricsGraylog.class_variable_set(:@@autorun, nil)
  end

  it 'accepts config' do
    args = %w(--username foo --password bar)
    check = MetricsGraylog.new(args)
    expect(check.config[:password]).to eq 'bar'
  end

  it 'returns original data' do
    stub_request(:get, /system.*/)
      .with(basic_auth: %w(foo bar))
      .to_return(
        status: 200,
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          'gauges' => {
            'org.graylog2.shared.journal.KafkaJournal.uncommittedMessages' => {
              'value' => 42
            },
            'org.graylog2.shared.journal.KafkaJournal.unflushedMessages' => {
              'value' => 97.43
            }
          }
        }.to_json
      )
    args = %w(--username foo --password bar --host localhost --port 12900)

    check = MetricsGraylog.new(args)
    expect { check.run }.to output(/uncommittedMessages 42.*unflushedMessages 97/m).to_stdout.and raise_error(SystemExit)
  end

  it 'returns all isata' do
    stub_request(:get, /system.*/)
      .with(basic_auth: %w(foo bar))
      .to_return(
        status: 200,
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          'gauges' => {
            'org.graylog2.shared.journal.KafkaJournal.uncommittedMessages' => {
              'value' => 42
            },
            'org.graylog2.shared.journal.KafkaJournal.unflushedMessages' => {
              'value' => 97.43
            },
            'jvm.memory.heap.used' => {
              'value' => 885_385_736
            }
          },
          'counters' => {
            'cluster-eventbus.executor-service.running' => {
              'count' => 0
            }
          }
        }.to_json
      )
    args = %w(--username foo --password bar --host localhost --port 12900 --all)

    check = MetricsGraylog.new(args)
    expect { check.run }.to output(/uncommittedMessages 42.*executor-service\.running 0/m).to_stdout.and raise_error(SystemExit)
  end
end
