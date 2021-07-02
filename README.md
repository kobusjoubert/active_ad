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

Using Facebook's implementation to demonstrate how this will work for each platform.

All of the platforms follow the same pattern as described below, though their own implementations may differ slightly.

Validation happens before `create`, `update` and `destroy` methods are called. When successful, the object will be returned, when unsuccessful, `false`
will be returned. This might also mean that the external API didn't except the request.

Each method also implements the bang method, `create!`, `update!` and `destroy!` which will raise an `ActiveAd::RecordInvalid` exception on create or update
failure or an `ActiveAd::RecordNotDeleted` on destruction failure.

### Client

Create a client.

    client = ActiveAd::Facebook::Client.new(short_lived_access_token: 'a1b2c3', client_id: '123', client_secret: 'a1b2c3')
    client.valid? # => false
    client.login
    client.access_token # => 'a1b2c3'
    client.valid? # => true

Assign the client connection.

    ActiveAd::Facebook::Connection.client = client

### Account

Create an account.

    account = ActiveAd::Facebook::Account.create(business_id: '123', currency: 'USD', name: 'Account Name')

Find accounts.

    accounts = ActiveAd::Facebook::Account.where(status: ['ACTIVE']).limit(10)

Find a previously created account by it's identifier.

    account = ActiveAd::Facebook::Account.find('123')

Or if you don't require fresh data and have it already persisted you can just create an instance.

    account = ActiveAd::Facebook::Account.new(id: '123')

Save an account.

    account.name = 'New Account Name'
    account.save

Update an account.

    account.update(name: 'New Account Name')

Delete an account.

    account.destroy

Find account campaigns.

    campaigns = account.campaigns.where(status: ['ACTIVE']).limit(10)

### Campaign

Create a campaign.

    campaign = ActiveAd::Facebook::Campaign.create(account_id: '123', name: 'Campaign Name')

Find campaigns.

    campaigns = ActiveAd::Facebook::Campaign.where(status: ['ACTIVE']).limit(10)

Find a previously created campaign by it's identifier.

    campaign = ActiveAd::Facebook::Campaign.find('123')

Or if you don't require fresh data and have it already persisted you can just create an instance.

    campaign = ActiveAd::Facebook::Campaign.new(id: '123')

Save a campaign.

    campaign.name = 'New Campaign Name'
    campaign.save

Update a campaign.

    campaign.update(name: 'New Campaign Name')

Delete a campaign.

    campaign.destroy

Find account ad groups.

    ad_groups = campaign.ad_groups.where(status: ['ACTIVE']).limit(10)

### Ad Group

Follows the same pattern as campaigns.

### Ad

Follows the same pattern as campaigns.

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
