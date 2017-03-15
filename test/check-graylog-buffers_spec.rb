require_relative './spec_helper.rb'
require_relative '../bin/check-graylog-buffers.rb'

describe 'CheckGraylogBuffers', '#run' do
  before(:all) do
    CheckGraylogBuffers.class_variable_set(:@@autorun, nil)
  end

  it 'accepts config' do
    args = %w(--username foo --password bar)
    check = CheckGraylogBuffers.new(args)
    expect(check.config[:password]).to eq 'bar'
  end

  it 'returns ok for pre 210' do
    stub_request(:get, /system.*/)
      .with(basic_auth: %w(foo bar))
      .to_return(
        status: 200,
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          'version' => '2.0.0+a1b2c3d'
        }.to_json
      ).then
      .to_return(
        status: 200,
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          'buffers' => {
            'process' => {
              'utilization_percent' => 50.12
            }
          }
        }.to_json
      )
    args = %w(--username foo --password bar --host localhost --port 12900)

    check = CheckGraylogBuffers.new(args)
    expect(check).to receive(:ok).with('process buffer utilization is 50.12%').and_raise(SystemExit)
    expect { check.run }.to raise_error(SystemExit)
  end

  it 'returns critical for pre 210' do
    stub_request(:get, /system.*/)
      .with(basic_auth: %w(foo bar))
      .to_return(
        status: 200,
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          'version' => '2.0.0+a1b2c3d'
        }.to_json
      ).then
      .to_return(
        status: 200,
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          'buffers' => {
            'process' => {
              'utilization_percent' => 99.99
            }
          }
        }.to_json
      )
    args = %w(--username foo --password bar --host localhost --port 12900)

    check = CheckGraylogBuffers.new(args)
    expect(check).to receive(:critical).with('process buffer utilization is 99.99%, threshold is 90.00%').and_raise(SystemExit)
    expect { check.run }.to raise_error(SystemExit)
  end

  it 'returns ok for post 210' do
    stub_request(:any, /system.*/)
      .with(basic_auth: %w(foo bar))
      .to_return(
        status: 200,
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          'version' => '2.2.0+a1b2c3d'
        }.to_json
      ).then
      .to_return(
        status: 200,
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          'total' => 6,
          'metrics' => [
            {
              'full_name' => 'org.graylog2.buffers.input.usage',
              'metric' => { 'value' => 2 },
              'name' => 'usage',
              'type' => 'gauge'
            },
            {
              'full_name' => 'org.graylog2.buffers.input.size',
              'metric' => { 'value' => 65_536 },
              'name' => 'size',
              'type' => 'gauge'
            },
            {
              'full_name' => 'org.graylog2.buffers.process.usage',
              'metric' => { 'value' => 4 },
              'name' => 'usage',
              'type' => 'gauge'
            },
            {
              'full_name' => 'org.graylog2.buffers.process.size',
              'metric' => { 'value' => 65_536 },
              'name' => 'size',
              'type' => 'gauge'
            },
            {
              'full_name' => 'org.graylog2.buffers.output.usage',
              'metric' => { 'value' => 8 },
              'name' => 'usage',
              'type' => 'gauge'
            },
            {
              'full_name' => 'org.graylog2.buffers.output.size',
              'metric' => { 'value' => 65_536 },
              'name' => 'usage',
              'type' => 'gauge'
            }
          ]
        }.to_json
      )
    args = %w(--username foo --password bar --host localhost --port 12900)

    check = CheckGraylogBuffers.new(args)
    expect(check).to receive(:ok).with('buffer utilization is 0.00%/0.01%/0.01%').and_raise(SystemExit)
    expect { check.run }.to raise_error(SystemExit)
  end

  it 'returns critical for post 210' do
    stub_request(:any, /system.*/)
      .with(basic_auth: %w(foo bar))
      .to_return(
        status: 200,
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          'version' => '2.2.0+a1b2c3d'
        }.to_json
      ).then
      .to_return(
        status: 200,
        headers: {
          'Content-Type' => 'application/json'
        },
        body: {
          'total' => 6,
          'metrics' => [
            {
              'full_name' => 'org.graylog2.buffers.input.usage',
              'metric' => { 'value' => 2 },
              'name' => 'usage',
              'type' => 'gauge'
            },
            {
              'full_name' => 'org.graylog2.buffers.input.size',
              'metric' => { 'value' => 65_536 },
              'name' => 'size',
              'type' => 'gauge'
            },
            {
              'full_name' => 'org.graylog2.buffers.process.usage',
              'metric' => { 'value' => 4 },
              'name' => 'usage',
              'type' => 'gauge'
            },
            {
              'full_name' => 'org.graylog2.buffers.process.size',
              'metric' => { 'value' => 65_536 },
              'name' => 'size',
              'type' => 'gauge'
            },
            {
              'full_name' => 'org.graylog2.buffers.output.usage',
              'metric' => { 'value' => 65_000 },
              'name' => 'usage',
              'type' => 'gauge'
            },
            {
              'full_name' => 'org.graylog2.buffers.output.size',
              'metric' => { 'value' => 65_536 },
              'name' => 'usage',
              'type' => 'gauge'
            }
          ]
        }.to_json
      )
    args = %w(--username foo --password bar --host localhost --port 12900)

    check = CheckGraylogBuffers.new(args)
    expect(check).to receive(:critical).with('output buffer exceeds 90.00%, buffer utilization is 0.00%/0.01%/99.18%').and_raise(SystemExit)
    expect { check.run }.to raise_error(SystemExit)
  end
end
