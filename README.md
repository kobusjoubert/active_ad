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

Validation happens before `create`, `update` and `destroy` methods are called. When successful, the object will be returned, when unsuccessful, `false`
will be returned. This might also mean that the external API didn't accept the request.

Each method also implements the bang method, `create!`, `update!` and `destroy!` which will raise an `ActiveAd::RecordInvalid` exception on create or update
failure or an `ActiveAd::RecordNotDeleted` on destruction failure.

Using Facebook's implementation to demonstrate usage. All of the platforms follow similar patterns, though their own implementations may differ slightly.

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

Get an account's campaigns.

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

Get a campaign's ad groups.

    ad_sets = campaign.ad_sets.where(status: ['ACTIVE']).limit(10)

Get a campaign's account.

    account = campaign.account

### Ad Group

Create an ad group.

    options = {
      account_id: '123',
      campaign_id: '456',
      name: 'Ad Set Name',
      status: 'PAUSED',
      bid_amount: 200,
      daily_budget: 50000,
      targeting: {
        device_platforms: ['mobile'],
        facebook_positions: ['feed'],
        geo_locations: {
          countries: ['ZA']
        },
        publisher_platforms: ['facebook']
      }
    }

    ad_set = ActiveAd::Facebook::AdSet.create!(**options)
    
Find ad groups.

    ad_sets = ActiveAd::Facebook::AdSet.where(status: ['PAUSED']).limit(10)

Find a previously created ad group by it's identifier.

    ad_set = ActiveAd::Facebook::AdSet.find('123')

Or if you don't require fresh data and have it already persisted you can just create an instance.

    ad_set = ActiveAd::Facebook::AdSet.new(id: '123')

Save an ad group.

    ad_set.name = 'New Ad Set Name'
    ad_set.save

Update an ad group.

    ad_set.update(name: 'New Ad Set Name')

Delete an ad group.

    ad_set.destroy

Get an ad group's ads.

    ads = ad_set.ads.where(status: ['ACTIVE']).limit(10)

Get an ad group's campaign.

    campaign = ad_set.campaign

### Ad

Create an ad.

    options = {
      account_id: '123',
      ad_set_id: '456',
      creative: {
        creative_id: '789'
      },
      name: 'Ad Name',
      status: 'PAUSED'
    }

    ad = ActiveAd::Facebook::Ad.create!(**options)

Find ads.

    ads = ActiveAd::Facebook::Ad.where(status: ['PAUSED']).limit(10)

Find a previously created ad by it's identifier.

    ad = ActiveAd::Facebook::Ad.find('123')

Or if you don't require fresh data and have it already persisted you can just create an instance.

    ad = ActiveAd::Facebook::Ad.new(id: '123')

Save an ad.

    ad.name = 'New Ad Name'
    ad.save

Update an ad.

    ad.update(name: 'New Ad Name')

Delete an ad.

    ad.destroy

Get an ad's ad creative.

    ad_creative = ad.ad_creative

Get an ad's ad group.

    campaign = ad.ad_set

### Paging

Lists can be paged by using the `next_offset_value` attribute returned from each result set.

    ads = ActiveAd::Facebook::Ad.limit(10)
    loop do
      ads.map { |ad| ad.id }
      break unless (offset = ads.next_offset_value)
      ads = ads.offset(offset)
    end

## Roadmap

### Version 0

Implement classes which maps to it's external API entities.

`ActiveAd::Facebook::Client` -< `ActiveAd::Facebook::Account` -< `ActiveAd::Facebook::Campaign` -< `ActiveAd::Facebook::AdSet` -< `ActiveAd::Facebook::Ad` -<
`ActiveAd::Facebook::AdCreative`

`ActiveAd::Google::Client` -< `ActiveAd::Google::Account` -< `ActiveAd::Google::Campaign` -< `ActiveAd::Google::AdGroup` -< `ActiveAd::Google::Ad`

### Version 1

Implement base classes with *one-to-many* `-<` relationships looking like this.

`ActiveAd::Client` -< `ActiveAd::Account` -< `ActiveAd::Campaign` -< `ActiveAd::AdGroup` -< `ActiveAd::Ad`

The base classes will then use the different platform classes to make all the required requests to create the different base entities.

If we look at Facebook, the classes to be used in the base classes will look like this.

`ActiveAd::Client` will use `ActiveAd::Facebook::Client` which will define the platform being used.

`ActiveAd::Account` will use `ActiveAd::Facebook::Account`.

`ActiveAd::Campaign` will use `ActiveAd::Facebook::Campaign`.

`ActiveAd::AdGroup` will use `ActiveAd::Facebook::AdSet`.

`ActiveAd::Ad` will use `ActiveAd::Facebook::Ad` and `ActiveAd::Facebook::AdCreative` to create an ad as a whole.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

You can set the environment of the gem to `development` to make life easier while extending the gem. Setting it to any other environment will not require or load development dependencies like `listen` and `byebug` which we don't want in production.

If you're building a Rails or Rack app, it will use those environments. If you're using this gem as a standalone library, you'll have to set the `ACTIVE_AD_ENV` environment variable to `development`.

Environment lookup happens in the following order: `ENV['ACTIVE_AD_ENV'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || ''`

If nothing has been specified, then this is not development and unnecessary libraries won't be required.

Run console like so while extending and testing the gem.

    ACTIVE_AD_ENV=development bin/console

## Logger

The default log level while working in the development environment is set to `DEBUG`, for all other instances it's set to `INFO`.

If the logger gets too noisy while developing, you can change the log level.

    ActiveAd.logger.level = Logger::INFO

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ClickAds/active_ad. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ClickAds/active_ad/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveAd project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ClickAds/active_ad/blob/main/CODE_OF_CONDUCT.md).
