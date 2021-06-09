# Active Ad

Active Ad allows you to talk to different marketing APIs in a simple unified way giving you a consistent interface across all marketing APIs, no need to learn all the different social media APIs out there.

The aim of the project is to feel natural to Ruby users and is developed to be used in Ruby on Rails applications, but can also be used as a stand alone library in any Ruby project.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_ad'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install active_ad

## Usage

### Setup

TODO:

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

You can set the environment of the gem to `development` to make life easier while extending the gem. Setting it to any other environment will not require or load development dependencies like `listen` and `byebug` which we don't want in production.

If you're building a Rails or Rack app, it will use those environments. If you're using this gem as a standalone library, you'll have to set the `ACTIVE_AD_ENV` environment variable to `development`.

Environment lookup happens in the following order: `ENV['ACTIVE_AD_ENV'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || ''`

If nothing has been specified, then this is not development and unnecessary libraries won't be required.

Run console like so while extending and testing the gem.

    ACTIVE_AD_ENV=development bin/console

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ClickAds/active_ad. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ClickAds/active_ad/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveAd project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ClickAds/active_ad/blob/main/CODE_OF_CONDUCT.md).
