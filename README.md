## Sensu-Plugins-greylog

[![Build Status](https://travis-ci.org/sensu-plugins/sensu-plugins-greylog.svg?branch=master)](https://travis-ci.org/sensu-plugins/sensu-plugins-greylog)
[![Gem Version](https://badge.fury.io/rb/sensu-plugins-greylog.svg)](http://badge.fury.io/rb/sensu-plugins-greylog)
[![Code Climate](https://codeclimate.com/github/sensu-plugins/sensu-plugins-greylog/badges/gpa.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-greylog)
[![Test Coverage](https://codeclimate.com/github/sensu-plugins/sensu-plugins-greylog/badges/coverage.svg)](https://codeclimate.com/github/sensu-plugins/sensu-plugins-greylog)
[![Dependency Status](https://gemnasium.com/sensu-plugins/sensu-plugins-greylog.svg)](https://gemnasium.com/sensu-plugins/sensu-plugins-greylog)

## Functionality

## Files
 * bin/check-graylog2-alive

## Usage

## Installation

Add the public key (if you haven’t already) as a trusted certificate

```
gem cert --add <(curl -Ls https://raw.githubusercontent.com/sensu-plugins/sensu-plugins.github.io/master/certs/sensu-plugins.pem)
gem install sensu-plugins-greylog -P MediumSecurity
```

You can also download the key from /certs/ within each repository.

#### Rubygems

`gem install sensu-plugins-greylog`

#### Bundler

Add *sensu-plugins-disk-checks* to your Gemfile and run `bundle install` or `bundle update`

#### Chef

Using the Sensu **sensu_gem** LWRP
```
sensu_gem 'sensu-plugins-greylog' do
  options('--prerelease')
  version '0.0.1'
end
```

Using the Chef **gem_package** resource
```
gem_package 'sensu-plugins-greylog' do
  options('--prerelease')
  version '0.0.1'
end
```

## Notes
