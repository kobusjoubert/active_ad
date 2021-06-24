require 'spec_helper'

RSpec.describe ActiveAd::Facebook::Campaign do
  let(:campaign)    { described_class.new(id: 'campaign_123') }
  let(:api_version) { campaign.api_version }

  before(:all) do
    client = ActiveAd::Facebook::Client.new(access_token: 'secret_access_token', client_id: 'client_123', client_secret: '1a2b3c')
    ActiveAd::Facebook::Connection.client = client
  end

  describe '.find' do
    it 'returns an object when found' do
      stub_request(:get, "https://graph.facebook.com/v#{api_version}/campaign_123").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        id: 'campaign_123', name: 'Campaign Name'
      }.to_json)

      expect(described_class.find('campaign_123')).to be_an_instance_of(ActiveAd::Facebook::Campaign)
    end

    it 'returns nil when not found' do
      stub_request(:get, "https://graph.facebook.com/v#{api_version}/campaign_999").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 404, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect(described_class.find('campaign_999')).to be_nil
    end
  end

  describe '.find!' do
    it 'returns an object when found' do
      stub_request(:get, "https://graph.facebook.com/v#{api_version}/campaign_123").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        id: 'campaign_123', name: 'Campaign Name'
      }.to_json)

      expect(described_class.find!('campaign_123')).to be_an_instance_of(ActiveAd::Facebook::Campaign)
    end

    it 'raises an exception when not found' do
      stub_request(:get, "https://graph.facebook.com/v#{api_version}/campaign_999").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 404, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect { described_class.find!('campaign_999') }.to raise_error(ActiveAd::RecordNotFound)
    end
  end

  describe '.create' do
    it 'returns an object when created' do
      stub_request(:post, "https://graph.facebook.com/v#{api_version}/act_account_123/campaigns").with(body:
        hash_including(access_token: 'secret_access_token', name: 'Campaign Name')
      ).to_return(status: 200, body: {
        id: 'campaign_123', name: 'Campaign Name'
      }.to_json)

      expect(described_class.create(account_id: 'account_123', name: 'Campaign Name', validate: false)).to be_an_instance_of(ActiveAd::Facebook::Campaign)
    end

    it 'returns an empty object when not created' do
      stub_request(:post, "https://graph.facebook.com/v#{api_version}/act_account_123/campaigns").with(body:
        hash_including(access_token: 'secret_access_token', name: 'Campaign Name')
      ).to_return(status: 400, body: {
        error: { message: 'no no no!' }
      }.to_json)

      object = described_class.create(account_id: 'account_123', name: 'Campaign Name', validate: false)
      expect(object).to be_an_instance_of(ActiveAd::Facebook::Campaign)
      expect(object.id).to be_nil
      expect(object.name).to be_nil
    end
  end

  describe '.create!' do
    it 'returns an object when created' do
      stub_request(:post, "https://graph.facebook.com/v#{api_version}/act_account_123/campaigns").with(body:
        hash_including(access_token: 'secret_access_token', name: 'Campaign Name')
      ).to_return(status: 200, body: {
        id: 'campaign_123', name: 'Campaign Name'
      }.to_json)

      expect(described_class.create!(account_id: 'account_123', name: 'Campaign Name', validate: false)).to be_an_instance_of(ActiveAd::Facebook::Campaign)
    end

    it 'raises an exception when not created' do
      stub_request(:post, "https://graph.facebook.com/v#{api_version}/act_account_123/campaigns").with(body:
        hash_including(access_token: 'secret_access_token', name: 'Campaign Name')
      ).to_return(status: 400, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect { described_class.create!(account_id: 'account_123', name: 'Campaign Name', validate: false) }.to raise_error(ActiveAd::RecordInvalid)
    end
  end

  describe '#initialize' do
    it 'sets the campaign_id' do
      expect(described_class.new(id: 'campaign_123').campaign_id).to eq('campaign_123')
    end
  end

  describe '#platform' do
    it 'returns the platform name' do
      expect(campaign.platform).to eq('facebook')
    end
  end

  describe '#api_version' do
    it 'returns the api version' do
      expect(campaign.api_version).to eq('11.0')
    end
  end

  describe '#access_token' do
    it 'returns the access token' do
      expect(campaign.access_token).to eq('secret_access_token')
    end
  end

  describe '#new_record?' do
    it 'ise a new record when initializing without an id' do
      stub_request(:any, /.*/)

      expect(described_class.new.new_record?).to be true
    end

    it 'is not a new record when initializing with id' do
      stub_request(:any, /.*/)

      expect(described_class.new(id: 'campaign_123').new_record?).to be false
    end

    it 'is not a new record after update' do
      stub_request(:any, /.*/)

      campaign.update(name: 'New Campaign Name', validate: false)
      expect(campaign.new_record?).to be false
    end

    it 'is not a new record after create' do
      stub_request(:any, /.*/)

      expect(described_class.create(name: 'Campaign Name', validate: false).new_record?).to be false
    end
  end

  describe '#valid?' do
    it 'returns false when no name is present when creating a new record' do
      expect(described_class.new.valid?).to be false
    end

    it 'returns true when no name is present when updating a record' do
      campaign.name = nil
      expect(campaign.valid?).to be true
    end
  end

  describe '#save' do
    it 'returns true when saved' do
      stub_request(:post, "https://graph.facebook.com/v#{api_version}/campaign_123").with(body:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        id: 'campaign_123'
      }.to_json)

      expect(campaign.save(validate: false)).to be true
    end

    it 'returns false when not saved' do
      stub_request(:post, "https://graph.facebook.com/v#{api_version}/campaign_123").with(body:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 400, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect(campaign.save(validate: false)).to be false
    end
  end

  describe '#save!' do
    it 'returns true when saved' do
      stub_request(:post, "https://graph.facebook.com/v#{api_version}/campaign_123").with(body:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        id: 'campaign_123'
      }.to_json)

      expect(campaign.save!(validate: false)).to be true
    end

    it 'raises an exception when not saved' do
      stub_request(:post, "https://graph.facebook.com/v#{api_version}/campaign_123").with(body:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 400, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect { campaign.save!(validate: false) }.to raise_error(ActiveAd::RecordInvalid)
    end
  end

  describe '#update' do
    it 'returns true when updated' do
      stub_request(:post, "https://graph.facebook.com/v#{api_version}/campaign_123").with(body:
        hash_including(access_token: 'secret_access_token', name: 'Campaign Name')
      ).to_return(status: 200, body: {
        id: 'campaign_123', name: 'Campaign Name'
      }.to_json)

      expect(campaign.update(name: 'Campaign Name', validate: false)).to be true
    end

    it 'returns false when not updated' do
      stub_request(:post, "https://graph.facebook.com/v#{api_version}/campaign_123").with(body:
        hash_including(access_token: 'secret_access_token', name: 'Campaign Name')
      ).to_return(status: 400, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect(campaign.update(name: 'Campaign Name', validate: false)).to be false
    end
  end

  describe '#update!' do
    it 'returns true when updated' do
      stub_request(:post, "https://graph.facebook.com/v#{api_version}/campaign_123").with(body:
        hash_including(access_token: 'secret_access_token', name: 'Campaign Name')
      ).to_return(status: 200, body: {
        id: 'campaign_123', name: 'Campaign Name'
      }.to_json)

      expect(campaign.update!(name: 'Campaign Name', validate: false)).to be true
    end

    it 'raise an exception when not updated' do
      stub_request(:post, "https://graph.facebook.com/v#{api_version}/campaign_123").with(body:
        hash_including(access_token: 'secret_access_token', name: 'Campaign Name')
      ).to_return(status: 400, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect { campaign.update!(name: 'Campaign Name', validate: false) }.to raise_error(ActiveAd::RecordInvalid)
    end
  end

  describe '#destroy' do
    it 'returns true when deleted' do
      stub_request(:delete, "https://graph.facebook.com/v#{api_version}/campaign_123").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        success: true
      }.to_json)

      expect(campaign.destroy).to be true
    end

    it 'returns false when not deleted' do
      stub_request(:delete, "https://graph.facebook.com/v#{api_version}/campaign_123").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 400, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect(campaign.destroy).to be false
    end
  end

  describe '#destroy!' do
    it 'returns true when deleted' do
      stub_request(:delete, "https://graph.facebook.com/v#{api_version}/campaign_123").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        success: true
      }.to_json)

      expect(campaign.destroy!).to be true
    end

    it 'raises an exception when not deleted' do
      stub_request(:delete, "https://graph.facebook.com/v#{api_version}/campaign_123").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 400, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect { campaign.destroy! }.to raise_error(ActiveAd::RecordNotDeleted)
    end
  end
end
