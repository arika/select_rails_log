# SelectRailsLog

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add select_rails_log
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install select_rails_log
```

## Usage

At first, add the following to an appropriate configuration file in the environments directory.

``` ruby
config.log_tags = [:request_id]
config.log_formatter = ::Logger::Formatter.new
```

Start the application and perform various operations until sufficient output is written to the log file.
Then you can use the following command to select the log file.

```console
$ select_rails_log path/to/rails.log
```

### Sample session

TODO

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test-unit` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/arika/select_rails_log. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/arika/select_rails_log/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SelectRailsLog project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/arika/select_rails_log/blob/master/CODE_OF_CONDUCT.md).
