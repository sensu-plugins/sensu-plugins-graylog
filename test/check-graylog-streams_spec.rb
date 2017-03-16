require_relative './spec_helper.rb'
require_relative '../bin/check-graylog-streams.rb'

describe 'CheckGraylogStreams', '#run' do
  before(:all) do
    CheckGraylogStreams.class_variable_set(:@@autorun, nil)
  end

  it 'accepts config' do
    args = %w(--username foo --password bar)
    check = CheckGraylogStreams.new(args)
    expect(check.config[:password]).to eq 'bar'
  end

  it 'returns ok' do
    stub_request(:get, 'http://localhost:12900/streams')
      .with(basic_auth: %w(foo bar))
      .to_return(
        status: 200,
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          'total' => 2,
          'streams' => [
            {
              'id' => '000000000000000000000001',
              'title' => 'All messages',
              'disabled' => false
            },
            {
              'id' => 'abc123def456deadbeef',
              'title' => 'test stream',
              'disabled' => false
            }
          ]
        }.to_json
      )
    args = %w(--username foo --password bar --host localhost --port 12900)

    check = CheckGraylogStreams.new(args)
    expect(check).to receive(:ok).with('No streams are paused').and_raise(SystemExit)
    expect { check.run }.to raise_error(SystemExit)
  end

  it 'returns critical' do
    stub_request(:get, 'http://localhost:12900/streams')
      .with(basic_auth: %w(foo bar))
      .to_return(
        status: 200,
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          'total' => 2,
          'streams' => [
            {
              'id' => '000000000000000000000001',
              'title' => 'All messages',
              'disabled' => false
            },
            {
              'id' => 'abc123def456deadbeef',
              'title' => 'test stream',
              'disabled' => true
            }
          ]
        }.to_json
      )
    args = %w(--username foo --password bar --host localhost --port 12900)

    check = CheckGraylogStreams.new(args)
    expect(check).to receive(:critical).with('Streams currently paused/disabled: test stream').and_raise(SystemExit)
    expect { check.run }.to raise_error(SystemExit)
  end
end
