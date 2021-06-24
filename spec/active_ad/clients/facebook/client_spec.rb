require 'spec_helper'

RSpec.describe ActiveAd::Facebook::Client do
  let(:api_version) { described_class::API_VERSION }
  let(:client)      { described_class.new(access_token: 'secret_access_token', client_id: 'client_123', client_secret: '1a2b3c') }

  describe '#platform' do
    it 'returns the platform name' do
      expect(client.platform).to eq('facebook')
    end
  end

  describe '#login' do
    it 'is valid when an access_token is present' do
      expect(client.valid?).to be(true)
    end

    it 'is invalid when there is no access_token present' do
      client.access_token = nil
      expect(client.valid?).to be(false)
    end

    it 'retrieves and sets a long lived access_token in exchange for a short lived access_token' do
      stub_request(:get, "https://graph.facebook.com/v#{api_version}/oauth/access_token").with(query: {
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
end
