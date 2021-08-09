require 'spec_helper'

RSpec.describe ActiveAd::Facebook::Client do
  let(:client) { described_class.new(access_token: 'secret_access_token', client_id: 'client_123', client_secret: '1a2b3c') }

  describe '#platform' do
    it 'returns the platform name' do
      expect(client.platform).to eq('facebook')
    end
  end

  describe '#api_version' do
    it 'returns the api version' do
      expect(client.api_version).to eq('11.0')
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
      stub_request(:get, "#{described_class.base_url}/oauth/access_token").with(query: {
        client_id: 'client_123', client_secret: '1a2b3c', grant_type: 'fb_exchange_token', fb_exchange_token: 'secret_short_access_token'
      }).to_return(status: 200, body: {
        access_token: 'secret_access_token'
      }.to_json)

      client.access_token = nil
      client.short_lived_access_token = 'secret_short_access_token'
      client.login
      expect(client.access_token).to eq('secret_access_token')
    end
  end

  describe '#refresh_token' do
    it 'retrieves and sets a refreshed long lived access_token in exchange for the current long lived access_token' do
      stub_request(:get, "#{described_class.base_url}/oauth/access_token").with(query: {
        client_id: 'client_123', client_secret: '1a2b3c', grant_type: 'fb_exchange_token', fb_exchange_token: 'secret_access_token'
      }).to_return(status: 200, body: {
        access_token: 'refreshed_secret_access_token'
      }.to_json)

      client.refresh_token
      expect(client.access_token).to eq('refreshed_secret_access_token')
    end
  end
end
