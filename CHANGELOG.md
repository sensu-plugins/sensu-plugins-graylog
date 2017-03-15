#Change Log
This project adheres to [Semantic Versioning](http://semver.org/).

This CHANGELOG follows the format listed at [Keep A Changelog](http://keepachangelog.com/)

## [Unreleased]
### Changed
- update check-graylog2-alive.rb to accept an `--apipath` argument to specify the path of the transport api
- update -alive lifecycle check because there are now multiple valid lifecyle states
- drop ruby 1.9.3 support
- update sensu-plugin dep to '~> 1.2'
- add some tests, this pulled in webmock to mock restclient calls
- update readme
- check-graylog-buffers
  - port python to ruby
  - py file is now a binstub for rb file
  - add version support for pre/post 2.1.0 buffer metrics
  - add apipath support
  - add tests
- metics-graylog
  - port python to ruby
  - py file is now a binstub for rb file
  - add --all flag for more stats (still some work to do here)
  - add apipath support
  - add tests



## [0.1.0] - 2016-01-29
### Added
- add new checks for graylog buffers and kafka journal
- add ruby wrappers for python checks

## [0.0.2] - 2015-07-14
### Changed
- updated sensu-plugin gem to 1.2.0

## 0.0.1 - 2015-06-27
### Added
- initial release

[Unreleased]: https://github.com/sensu-plugins/sensu-plugins-graylog/compare/0.1.0...HEAD
[0.1.1]: https://github.com/sensu-plugins/sensu-plugins-graylog/compare/0.0.2...0.1.0
[0.0.2]: https://github.com/sensu-plugins/sensu-plugins-graylog/compare/0.0.1...0.0.2
