require 'spec_helper'

RSpec.describe ActiveAd::Facebook::Client do
  let(:client) { described_class.new(access_token: 'secret_access_token', app_id: 'client_100', app_secret: '1a2b3c') }

  describe '#platform' do
    it 'returns the platform name' do
      expect(client.platform).to eq(:facebook)
    end
  end

  describe '#api_version' do
    it 'returns the api version' do
      expect(client.api_version).to eq('15.0')
    end
  end

  describe '#valid?' do
    it 'returns true when an access_token is present' do
      expect(client.valid?).to be(true)
    end

    it 'returns false when there is no access_token present' do
      client.access_token = nil
      expect(client.valid?).to be(false)
    end
  end

  describe '#login' do
    it 'retrieves and sets a long lived access_token in exchange for a short lived access_token' do
      stub_request(:get, "#{described_class.base_url}/oauth/access_token")
        .with(query: { client_id: 'client_100', client_secret: '1a2b3c', grant_type: 'fb_exchange_token', fb_exchange_token: 'secret_short_access_token' })
        .to_return(status: 200, body: { access_token: 'secret_access_token' }.to_json)

      client.access_token = nil
      client.short_lived_access_token = 'secret_short_access_token'
      client.login
      expect(client.access_token).to eq('secret_access_token')
    end
  end

  describe '#refresh_token' do
    it 'retrieves and sets a refreshed long lived access_token in exchange for the current long lived access_token' do
      stub_request(:get, "#{described_class.base_url}/oauth/access_token")
        .with(query: { client_id: 'client_100', client_secret: '1a2b3c', grant_type: 'fb_exchange_token', fb_exchange_token: 'secret_access_token' })
        .to_return(status: 200, body: { access_token: 'refreshed_secret_access_token' }.to_json)

      client.refresh_token
      expect(client.access_token).to eq('refreshed_secret_access_token')
    end
  end

  describe '#user', skip: true do
    before(:all) do
      ActiveAd::Facebook.configure do |config|
        config.app_id     = 'client_100'
        config.app_secret = '1a2b3c'
      end
    end

    before(:each) do
      stub_request(:get, "#{client.base_url}/me")
        .with(query: hash_including(access_token: 'secret_access_token'))
        .to_return(status: 200, body: { id: '100', name: 'User Name' }.to_json)
    end

    it 'returns the object type' do
      expect(client.user.class).to be(ActiveAd::Facebook::User)
    end

    it 'returns the object' do
      expect(client.user.name).to eq('User Name')
    end
  end
end
