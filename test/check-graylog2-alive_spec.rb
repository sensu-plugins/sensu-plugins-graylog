require_relative './spec_helper.rb'
require_relative '../bin/check-graylog2-alive.rb'

describe 'CheckGraylog2Alive', '#run' do
  before(:all) do
    CheckGraylog2Alive.class_variable_set(:@@autorun, nil)
  end

  it 'accepts config' do
    args = %w(--username foo --password bar)
    check = CheckGraylog2Alive.new(args)
    expect(check.config[:password]).to eq 'bar'
  end

  it 'returns ok' do
    stub_request(:get, 'http://localhost:12900/api/system')
      .with(basic_auth: %w(foo bar))
      .to_return(
        status: 200,
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          'lifecycle' => 'running',
          'is_processing' => true,
          'lb_status' => 'alive'
        }.to_json
      )
    args = %w(--username foo --password bar --host localhost --port 12900)

    check = CheckGraylog2Alive.new(args)
    expect(check).to receive(:ok).with('Graylog2 server is: running/true/alive').and_raise(SystemExit)
    expect { check.run }.to raise_error(SystemExit)
  end

  it 'returns critical' do
    stub_request(:get, 'http://localhost:12900/api/system')
      .with(basic_auth: %w(foo bar))
      .to_return(
        status: 200,
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          'lifecycle' => 'busticado',
          'is_processing' => true,
          'lb_status' => 'dead'
        }.to_json
      )
    args = %w(--username foo --password bar --host localhost --port 12900)

    check = CheckGraylog2Alive.new(args)
    expect(check).to receive(:critical).with('Graylog2 server is responding but not healthy: busticado/true/dead').and_raise(SystemExit)
    expect { check.run }.to raise_error(SystemExit)
  end

  it 'uses apipath' do
    stub_request(:get, 'http://localhost:12900/api/system')
      .with(basic_auth: %w(foo bar))
      .to_return(
        status: 200,
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          'lifecycle' => 'running',
          'is_processing' => true,
          'lb_status' => 'alive'
        }.to_json
      )
    args = %w(--username foo --password bar --host localhost --port 12900 --apipath /api)

    check = CheckGraylog2Alive.new(args)
    expect(check).to receive(:ok).with('Graylog2 server is: running/true/alive').and_raise(SystemExit)
    expect { check.run }.to raise_error(SystemExit)
  end
end
