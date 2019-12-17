## Sensu-Plugins-graylog

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-graylog.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-graylog)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-graylog.svg)](http://badge.fury.io/rb/sensu-plugins-graylog)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-graylog/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-graylog)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-graylog/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-graylog)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-graylog.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-graylog)

## Functionality
This plugin provides availability monitoring and metrics collection for the [Graylog](https://www.graylog.org/) log management system.

## Files
 * bin/check-graylog-buffers.rb
 * bin/check-graylog-streams.rb
 * bin/check-graylog2-alive.rb
 * bin/metrics-graylog.rb

## Usage

## Installation

For sensu core:
[Installation and Setup](http://sensu-plugins.io/docs/installation_instructions.html)

For sensu go:
[Sensu go assets](https://docs.sensu.io/sensu-go/latest/reference/assets/)

## Notes
- If you want a limited access user for monitoring purposes please see the [Graylog FAQ](http://docs.graylog.org/en/latest/pages/faq.html#how-can-i-create-a-restricted-user-to-check-internal-graylog-metrics-in-my-monitoring-system+)
  - A limited user must also have the "streams:read" permission on their role in order to use the check-graylog-streams.rb check
- Users may further obfuscate their credentials by creating an [Access Token](http://docs.graylog.org/en/latest/pages/configuration/rest_api.html?highlight=access%20tokens#creating-and-using-access-token) to use instead of their normal login credentials.
  - Note that only an admin may create a token by default.  If you want to have a dedicated monitoring user with an access token you will need to create them as a Admin user, create the token, then change the user to the monitoring specific role. You can change the default behavior by granting `users:tokencreate`, `users:tokenlist`, and `users:tokenremove` to a role and adding that role to the monitoring user.
