# Active Ad

Active Ad allows you to talk to different marketing APIs in a simple unified way giving you a consistent interface across all marketing APIs without needing to
learn all the marketing API libraries available.

The goal is to expose the necessary features from all the different marketing APIs so that you can create ads using a simple unified interface that feels
natural to Ruby users without the need to learn all the differences between the marketing APIs.

You can use this gem in Ruby on Rails applications or as a stand-alone library in any Ruby project.

Active Ad will allow you to start running ads quickly. When you need to have more control over every feature of the different marketing APIs, you could use the
libraries from the vendors themselves.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_ad'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install active_ad
```

## Usage

Validation happens on `save`, `create` and `update`. When successful, `true` will be returned for `save` and `update`, and the object will be returned for
`create`. When validation fails or the external API request fails, `false` will be returned.

Each method also implements a bang method, `save!`, `create!` and `update!` which will raise an `ActiveAd::RecordInvalid` exception when validation fails or an
`ActiveAd::RecordNotSaved` when the external API request fails.

Method `destroy` will return `false` when the external API request fails, while `destroy!` will raise an `ActiveAd::RecordNotDeleted` exception. In both cases `true` will be returned when
successful.

Method `unlink` will return `false` when the external API request fails, while `unlink!` will raise an `ActiveAd::RecordNotUnlinked` exception. In both cases `true` will be returned when
successful.

Method `find` will return `nil` when the external API request fails, while `find!` will raise an `ActiveAd::RecordNotFound` exception. In both cases a subclass of `ActiveAd::Base` will be
returned when successful.

When using `where`, an enumerable will be returned and all results will be queried when calling `each` or `map` on it and will result in API rate limiting when
being abused. It is up to you to enforce a `limit` if you don't want all results, for example `where.limit(10)`. The same goes for relational scopes
like `account.campaigns`, you can use `account.campaigns.limit(10)`.

Method `where` and models with `has_many` relations like `account.campaigns`, when calling `first`, `each`,  `map` and so on, will raise an `ActiveAd::RelationNotFound` exception when an
external API request fails. To have it return `nil` instead, set `ActiveAd.raise_relational_errors` to `false` on initialization.

Models with `belongs_to` relations like `campaign.account` will raise an `ActiveAd::RecordNotFound` exception when the external API request fails. To have it return `nil` instead, set
`ActiveAd.raise_relational_errors` to `false` on initialization.

### Configuration

Defatault configuration options to be set in an initializer somewhere. If you're using Rails put it in a file called `config/initializers/active_ad.rb`

```ruby
ActiveAd.configure do |config|
  config.log_level = :debug # Log levels are :debug, :info, :warn, :error, :fatal and :unknown.
  config.raise_relational_errors = true # Return nil or raise an exception when relational models aren't found? Eg: 'campaign.account', 'account.campaigns'.
end
```

### Exceptions

Validation callbacks run before any mutating request is sent to the external APIs. When validation fails, you can inspect the `record` attribute.

```ruby
begin
  record.save!
rescue ActiveAd::RecordInvalid => e
  puts e.record.errors
end
```

After successful validation, requests will be made to the external APIs. Any exception being raised at this point will include a `record` and a `response`
attribute which can be inspected.

```ruby
begin
  record.save!
rescue ActiveAd::RecordNotSaved => e
  puts "#{e.response.status} #{e.response.reason_phrase}: #{e.response.body}"
  puts e.record.attributes
end
```

### Paging

Lists can be paged by using the `next_offset_value` attribute returned from each result set.

```ruby
ads = ActiveAd::Facebook::Ad.limit(10, client: client)

loop do
  ads.map { |ad| ad.id }
  break unless (offset = ads.next_offset_value)

  ads = ads.offset(offset)
end
```

## Facebook

Using Facebook's implementation to demonstrate usage. All of the platforms follow similar patterns, though their own implementations may differ slightly.

```mermaid
%%{
  init: {
    'theme': 'base',
    'themeVariables': {
      'primaryColor': '#f8f9fa',
      'primaryTextColor': '#192b3a',
      'primaryBorderColor': '#192b3a',
      'textColor': '#192b3a',
      'lineColor': '#657786'
    }
  }
}%%
  erDiagram
    User ||--|{ Page : ""
    User ||--|{ Business : ""
    Page ||..|| Business : ""
    Business ||--|{ Account : ""
    Account ||--|{ Audience : ""
    Account ||--|{ Pixel : ""
    Account ||--|{ Campaign : ""
    Campaign ||--|{ AdGroup : ""
    AdGroup ||--|{ Ad : ""
```

By default all fields will be returned from Facebook's API. To return only the fields you need, use the `fields` parameter when using `find`, `where` or any relational methods.

```ruby
ActiveAd::Facebook::Ad.find('123', fields: [:name], client: client)
ActiveAd::Facebook::Ad.find('123', fields: [], client: client).ad_set(fields: [:name])
ActiveAd::Facebook::AdSet.find('123', fields: [], client: client).ads(fields: [:name])
ActiveAd::Facebook::AdSet.where(campaign_id: '123', fields: [:name], client: client)
```

### Configuration

Set your Facebook app id and secret somewhere in an initializer. If you're using Rails put it in a file called `config/initializers/active_ad.rb`

```ruby
ActiveAd::Facebook.configure do |config|
  config.app_id = '123'
  config.app_secret = 'a1b2c3'
end
```

### Client

If you don't have a long lived access token yet, create a client and exchange your short lived access token for a long lived access token.

```ruby
client = ActiveAd::Facebook::Client.new(short_lived_access_token: 'a1b2c3')
client.valid? # => false
client.login! # => true
client.access_token # => 'd4e5f6'
client.valid? # => true
```

Or if you do have your long lived access token.

```ruby
client = ActiveAd::Facebook::Client.new(access_token: 'd4e5f6')
client.valid? # => true
```

Every day or so you should refresh your current access token.

```ruby
client.refresh_token! # => true
client.access_token # => 'g7h8i9'
client.valid? # => true
```

### User

Find a previously created user by it's identifier.

```ruby
user = ActiveAd::Facebook::User.find('me', client: client)
user = ActiveAd::Facebook::User.find('123', client: client)
```

Or if you don't require fresh data and have it persisted already, you can create a new object with `stale: true`.

```ruby
user = ActiveAd::Facebook::User.new(stale: true, id: '123', name: 'User Name', client: client)
```

To refresh the data.

```ruby
user.reload
```

Get a user's pages.

```ruby
pages = user.pages
```

Get a user's businesses.

```ruby
businesses = user.businesses
```

### Page

Find a previously created page by it's identifier.

```ruby
page = ActiveAd::Facebook::Page.find('123', client: client)
```

Or if you don't require fresh data and have it persisted already, you can create a new object with `stale: true`.

```ruby
page = ActiveAd::Facebook::Page.new(stale: true, id: '123', name: 'Page Name', client: client)
```

To refresh the data.

```ruby
page.reload
```

Get a page's business.

```ruby
business = page.business
```

### Business

Create a business.

```ruby
business = ActiveAd::Facebook::Business.create(user_id: '123', primary_page: '123', name: 'Business Name', vertical: 'OTHER', client: client)
```

Find a previously created account by it's identifier.

```ruby
business = ActiveAd::Facebook::Business.find('123', client: client)
```

Or if you don't require fresh data and have it persisted already, you can create a new object with `stale: true`.

```ruby
business = ActiveAd::Facebook::Business.new(stale: true, id: '123', name: 'Business Name', client: client)
```

To refresh the data.

```ruby
business.reload
```

Save an business.

```ruby
business.name = 'New Business Name'
business.save
```

Update a business.

```ruby
business.update(name: 'New Business Name')
```

Unlink a business.

```ruby
business.unlink(account_id: '123')
business.unlink(page_id: '123')
```

Get a business' page.

```ruby
page = business.page
```

### Account

Create an account.

```ruby
account = ActiveAd::Facebook::Account.create(business_id: '123', currency: 'USD', name: 'Account Name', client: client)
```

Find accounts.

```ruby
accounts = ActiveAd::Facebook::Account.where(business_id: '123', status: ['ACTIVE'], client: client)
```

Find a previously created account by it's identifier.

```ruby
account = ActiveAd::Facebook::Account.find('123', client: client)
```

Or if you don't require fresh data and have it persisted already, you can create a new object with `stale: true`.

```ruby
account = ActiveAd::Facebook::Account.new(stale: true, id: '123', name: 'Account Name', client: client)
```

To refresh the data.

```ruby
account.reload
```

Save an account.

```ruby
account.name = 'New Account Name'
account.save
```

Update an account.

```ruby
account.update(name: 'New Account Name')
```

Delete an account.

```ruby
account.destroy
```

Get an account's campaigns.

```ruby
campaigns = account.campaigns.where(status: ['ACTIVE'])
```

Get an account's pixels.

```ruby
pixels = account.pixels
```

Get an account's saved audiences.

```ruby
saved_audiences = account.saved_audiences
```

### Campaign

Create a campaign.

```ruby
campaign = ActiveAd::Facebook::Campaign.create(account_id: '123', name: 'Campaign Name', client: client)
```

Find campaigns.

```ruby
campaigns = ActiveAd::Facebook::Campaign.where(account_id: '123', status: ['ACTIVE'], client: client)
```

Find a previously created campaign by it's identifier.

```ruby
campaign = ActiveAd::Facebook::Campaign.find('123', client: client)
```

Or if you don't require fresh data and have it persisted already, you can create a new object with `stale: true`.

```ruby
campaign = ActiveAd::Facebook::Campaign.new(stale: true, id: '123', name: 'Campaign Name', client: client)
```

To refresh the data.

```ruby
campaign.reload
```

Save a campaign.

```ruby
campaign.name = 'New Campaign Name'
campaign.save
```

Update a campaign.

```ruby
campaign.update(name: 'New Campaign Name')
```

Delete a campaign.

```ruby
campaign.destroy
```

Get a campaign's ad groups.

```ruby
ad_sets = campaign.ad_sets.where(status: ['ACTIVE'])
```

Get a campaign's account.

```ruby
account = campaign.account
```

### Ad Group

Create an ad group.

```ruby
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

ad_set = ActiveAd::Facebook::AdSet.create!(**options, client: client)
```

Find ad groups.

```ruby
ad_sets = ActiveAd::Facebook::AdSet.where(campaign_id: '123', status: ['PAUSED'], client: client)
```

Find a previously created ad group by it's identifier.

```ruby
ad_set = ActiveAd::Facebook::AdSet.find('123', client: client)
```

Or if you don't require fresh data and have it persisted already, you can create a new object with `stale: true`.

```ruby
ad_set = ActiveAd::Facebook::AdSet.new(stale: true, id: '123', name: 'Ad Set Name', client: client)
```

To refresh the data.

```ruby
ad_set.reload
```

Save an ad group.

```ruby
ad_set.name = 'New Ad Set Name'
ad_set.save
```

Update an ad group.

```ruby
ad_set.update(name: 'New Ad Set Name')
```

Delete an ad group.

```ruby
ad_set.destroy
```

Get an ad group's ads.

```ruby
ads = ad_set.ads.where(status: ['ACTIVE'])
```

Get an ad group's campaign.

```ruby
campaign = ad_set.campaign
```

### Ad

Create an ad.
```ruby
options = {
  account_id: '123',
  ad_set_id: '456',
  creative: {
    creative_id: '789'
  },
  name: 'Ad Name',
  status: 'PAUSED'
}

ad = ActiveAd::Facebook::Ad.create!(**options, client: client)
```

Find ads.

```ruby
ads = ActiveAd::Facebook::Ad.where(ad_set_id: '123', status: ['PAUSED'], client: client)
```

Find a previously created ad by it's identifier.

```ruby
ad = ActiveAd::Facebook::Ad.find('123', client: client)
```

Or if you don't require fresh data and have it persisted already, you can create a new object with `stale: true`.

```ruby
ad = ActiveAd::Facebook::Ad.new(stale: true, id: '123', name: 'Ad Name', client: client)
```

To refresh the data.

```ruby
ad.reload
```

Save an ad.

```ruby
ad.name = 'New Ad Name'
ad.save
```

Update an ad.

```ruby
ad.update(name: 'New Ad Name')
```

Delete an ad.

```ruby
ad.destroy
```

Get an ad's ad creative.

```ruby
ad_creative = ad.ad_creative
```

Get an ad's ad group.

```ruby
campaign = ad.ad_set
```

### Pixel

Create a pixel.

```ruby
pixel = ActiveAd::Facebook::Pixel.create(account_id: '123', name: 'Pixel Name', client: client)
```

Find pixels.

```ruby
pixels = ActiveAd::Facebook::Pixel.where(account_id: '123', client: client)
```

Find a previously created pixel by it's identifier.

```ruby
pixel = ActiveAd::Facebook::Pixel.find('123', client: client)
```

Or if you don't require fresh data and have it persisted already, you can create a new object with `stale: true`.

```ruby
pixel = ActiveAd::Facebook::Pixel.new(stale: true, id: '123', name: 'Pixel Name', client: client)
```

To refresh the data.

```ruby
pixel.reload
```

Save a pixel.

```ruby
pixel.name = 'New Pixel Name'
pixel.save
```

Update a pixel.

```ruby
pixel.update(name: 'New Pixel Name')
```

Get a pixel's account.

```ruby
pixel.account
```

Get a pixel's business.

```ruby
pixel.business
```

### Saved Audience

Find saved audiences.

```ruby
saved_audiences = ActiveAd::Facebook::SavedAudience.where(account_id: '123', client: client)
```

Find a previously created saved audience by it's identifier.

```ruby
saved_audience = ActiveAd::Facebook::SavedAudience.find('123', client: client)
```

Or if you don't require fresh data and have it persisted already, you can create a new object with `stale: true`.

```ruby
saved_audience = ActiveAd::Facebook::SavedAudience.new(stale: true, id: '123', name: 'Saved Audience Name', client: client)
```

To refresh the data.

```ruby
saved_audience.reload
```

Get a saved audience's account.

```ruby
saved_audience.account
```

### Custom Audience

Create a custom audience.

```ruby
options = {
  account_id: '123',
  name: 'Custom Audience Name',
  subtype: 'CUSTOM',
  customer_file_source: 'USER_PROVIDED_ONLY'
}

ad = ActiveAd::Facebook::Ad.create!(**options, client: client)
```

Find custom audiences.

```ruby
custom_audiences = ActiveAd::Facebook::CustomAudience.where(account_id: '123', client: client)
```

Find a previously created custom audience by it's identifier.

```ruby
custom_audience = ActiveAd::Facebook::CustomAudience.find('123', client: client)
```

Or if you don't require fresh data and have it persisted already, you can create a new object with `stale: true`.

```ruby
custom_audience = ActiveAd::Facebook::CustomAudience.new(stale: true, id: '123', name: 'Custom Audience Name', client: client)
```

To refresh the data.

```ruby
custom_audience.reload
```

Save a custom audience.

```ruby
custom_audience.name = 'New Custom Audience Name'
custom_audience.save
```

Update a custom audience.

```ruby
custom_audience.update(name: 'New Custom Audience Name')
```

Delete a custom audience.

```ruby
custom_audience.destroy
```

Get a custom audience's account.

```ruby
custom_audience.account
```

Get a custom audience's pixel.

```ruby
custom_audience.pixel
```

## Roadmap

### Version 0

Implement classes which maps to it's external API entities.

`ActiveAd::Facebook::Client` -< `ActiveAd::Facebook::Account` -< `ActiveAd::Facebook::Campaign` -< `ActiveAd::Facebook::AdSet` -< `ActiveAd::Facebook::Ad` >-
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

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rake spec` to run the tests and run `bin/rake rubocop` to check your style. You can also run `bin/console`
for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`,
which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

You can set the `ACTIVE_AD_ENV` environment variable to `development` to make life easier while extending the gem. Setting it to any other environment will not require or load development dependencies like
`listen` and `debug` which we don't want in production.

Run console like so while extending and testing the gem.

```
ACTIVE_AD_ENV=development bin/console
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kobusjoubert/active_ad. This project is intended to be a safe, welcoming space for collaboration, and contributors are
expected to adhere to the [code of conduct](https://github.com/kobusjoubert/active_ad/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveAd project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the
[code of conduct](https://github.com/kobusjoubert/active_ad/blob/main/CODE_OF_CONDUCT.md).
