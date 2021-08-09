require 'spec_helper'

RSpec.describe ActiveAd::Facebook::Campaign do
  before(:all) do
    client = ActiveAd::Facebook::Client.new(access_token: 'secret_access_token', client_id: 'client_123', client_secret: '1a2b3c')
    ActiveAd::Facebook::Connection.client = client
  end

  let(:campaign) { described_class.new(id: '123', stale: true) }
  let(:client)   { ActiveAd::Base.client }

  describe '.find' do
    it 'returns an object when found' do
      stub_request(:get, "#{client.base_url}/123").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        id: '123', name: 'Campaign Name'
      }.to_json)

      expect(described_class.find('123')).to be_an_instance_of(ActiveAd::Facebook::Campaign)
    end

    it 'returns nil when not found' do
      stub_request(:get, "#{client.base_url}/999").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 404, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect(described_class.find('999')).to be_nil
    end
  end

  describe '.find!' do
    it 'returns an object when found' do
      stub_request(:get, "#{client.base_url}/123").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        id: '123', name: 'Campaign Name'
      }.to_json)

      expect(described_class.find!('123')).to be_an_instance_of(ActiveAd::Facebook::Campaign)
    end

    it 'raises an exception when not found' do
      stub_request(:get, "#{client.base_url}/999").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 404, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect { described_class.find!('999') }.to raise_error(ActiveAd::RecordNotFound)
    end
  end

  describe '.create' do
    it 'returns an object when created' do
      stub_request(:post, "#{client.base_url}/act_123/campaigns").with(body:
        hash_including(access_token: 'secret_access_token', name: 'Campaign Name')
      ).to_return(status: 200, body: {
        id: '123', name: 'Campaign Name'
      }.to_json)

      expect(described_class.create(account_id: '123', name: 'Campaign Name', validate: false)).to be_an_instance_of(ActiveAd::Facebook::Campaign)
    end

    it 'returns an empty object when not created' do
      stub_request(:post, "#{client.base_url}/act_123/campaigns").with(body:
        hash_including(access_token: 'secret_access_token', name: 'Campaign Name')
      ).to_return(status: 400, body: {
        error: { message: 'no no no!' }
      }.to_json)

      object = described_class.create(account_id: '123', name: 'Campaign Name', validate: false)
      expect(object).to be_an_instance_of(ActiveAd::Facebook::Campaign)
      expect(object.id).to be_nil
      expect(object.name).to be_nil
    end
  end

  describe '.create!' do
    it 'returns an object when created' do
      stub_request(:post, "#{client.base_url}/act_123/campaigns").with(body:
        hash_including(access_token: 'secret_access_token', name: 'Campaign Name')
      ).to_return(status: 200, body: {
        id: '123', name: 'Campaign Name'
      }.to_json)

      expect(described_class.create!(account_id: '123', name: 'Campaign Name', validate: false)).to be_an_instance_of(ActiveAd::Facebook::Campaign)
    end

    it 'raises an exception when not created' do
      stub_request(:post, "#{client.base_url}/act_123/campaigns").with(body:
        hash_including(access_token: 'secret_access_token', name: 'Campaign Name')
      ).to_return(status: 400, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect { described_class.create!(account_id: '123', name: 'Campaign Name', validate: false) }.to raise_error(ActiveAd::RecordInvalid)
    end
  end

  describe '#initialize' do
    it 'sets the id' do
      expect(described_class.new(id: '123').id).to eq(123)
    end
  end

  describe '#new_record?' do
    it 'ise a new record when initializing without an id' do
      expect(described_class.new.new_record?).to be true
    end

    it 'is not a new record when initializing with id' do
      expect(described_class.new(id: '123').new_record?).to be false
    end

    it 'is not a new record after update' do
      stub_request(:post, "#{client.base_url}/123").with(body:
        hash_including(access_token: 'secret_access_token', name: 'New Campaign Name')
      ).to_return(status: 200, body: {
        id: '123', name: 'New Campaign Name'
      }.to_json)

      campaign.update(name: 'New Campaign Name', validate: false)
      expect(campaign.new_record?).to be false
    end

    it 'is not a new record after create' do
      stub_request(:post, "#{client.base_url}/act_123/campaigns").with(body:
        hash_including(access_token: 'secret_access_token', name: 'Campaign Name')
      ).to_return(status: 200, body: {
        id: '123', name: 'Campaign Name'
      }.to_json)

      expect(described_class.create(account_id: '123', name: 'Campaign Name', validate: false).new_record?).to be false
    end
  end

  describe '#valid?' do
    it 'returns false when no name is present when creating a new record' do
      expect(described_class.new.valid?).to be false
    end

    it 'returns true when no name is present when updating an existing record' do
      campaign.name = nil
      expect(campaign.valid?).to be true
    end
  end

  describe '#save' do
    it 'returns true when saved' do
      stub_request(:post, "#{client.base_url}/123").with(body:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        id: '123', name: 'Campaign Name'
      }.to_json)

      campaign.name = 'Campaign Name'
      expect(campaign.save(validate: false)).to be true
    end

    it 'returns false when not saved' do
      stub_request(:post, "#{client.base_url}/123").with(body:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 400, body: {
        error: { message: 'no no no!' }
      }.to_json)

      campaign.name = 'Campaign Name'
      expect(campaign.save(validate: false)).to be false
    end
  end

  describe '#save!' do
    it 'returns true when saved' do
      stub_request(:post, "#{client.base_url}/123").with(body:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        id: '123', name: 'Campaign Name'
      }.to_json)

      campaign.name = 'Campaign Name'
      expect(campaign.save!(validate: false)).to be true
    end

    it 'raises an exception when not saved' do
      stub_request(:post, "#{client.base_url}/123").with(body:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 400, body: {
        error: { message: 'no no no!' }
      }.to_json)

      campaign.name = 'Campaign Name'
      expect { campaign.save!(validate: false) }.to raise_error(ActiveAd::RecordInvalid)
    end
  end

  describe '#update' do
    it 'returns true when updated' do
      stub_request(:post, "#{client.base_url}/123").with(body:
        hash_including(access_token: 'secret_access_token', name: 'New Campaign Name')
      ).to_return(status: 200, body: {
        id: '123', name: 'New Campaign Name'
      }.to_json)

      expect(campaign.update(name: 'New Campaign Name', validate: false)).to be true
    end

    it 'returns false when not updated' do
      stub_request(:post, "#{client.base_url}/123").with(body:
        hash_including(access_token: 'secret_access_token', name: 'New Campaign Name')
      ).to_return(status: 400, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect(campaign.update(name: 'New Campaign Name', validate: false)).to be false
    end
  end

  describe '#update!' do
    it 'returns true when updated' do
      stub_request(:post, "#{client.base_url}/123").with(body:
        hash_including(access_token: 'secret_access_token', name: 'New Campaign Name')
      ).to_return(status: 200, body: {
        id: '123', name: 'New Campaign Name'
      }.to_json)

      expect(campaign.update!(name: 'New Campaign Name', validate: false)).to be true
    end

    it 'raise an exception when not updated' do
      stub_request(:post, "#{client.base_url}/123").with(body:
        hash_including(access_token: 'secret_access_token', name: 'New Campaign Name')
      ).to_return(status: 400, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect { campaign.update!(name: 'New Campaign Name', validate: false) }.to raise_error(ActiveAd::RecordInvalid)
    end
  end

  describe '#destroy' do
    it 'returns true when deleted' do
      stub_request(:delete, "#{client.base_url}/123").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        success: true
      }.to_json)

      expect(campaign.destroy).to be true
    end

    it 'returns false when not deleted' do
      stub_request(:delete, "#{client.base_url}/123").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 400, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect(campaign.destroy).to be false
    end
  end

  describe '#destroy!' do
    it 'returns true when deleted' do
      stub_request(:delete, "#{client.base_url}/123").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        success: true
      }.to_json)

      expect(campaign.destroy!).to be true
    end

    it 'raises an exception when not deleted' do
      stub_request(:delete, "#{client.base_url}/123").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 400, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect { campaign.destroy! }.to raise_error(ActiveAd::RecordNotDeleted)
    end
  end

  describe '#account' do
    it 'returns the object type' do
      stub_request(:get, "#{client.base_url}/act_123").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        id: '123', name: 'Account Name'
      }.to_json)

      campaign.account_id = '123'
      expect(campaign.account.class).to be(ActiveAd::Facebook::Account)
    end

    it 'returns the object' do
      stub_request(:get, "#{client.base_url}/act_123").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        id: '123', name: 'Account Name'
      }.to_json)

      campaign.account_id = '123'
      expect(campaign.account.name).to eq('Account Name')
    end
  end

  describe '#ad_sets' do
    it 'returns a relation' do
      expect(campaign.ad_sets).to be_a_kind_of(ActiveAd::Relation)
    end

    it 'returns the objects when invoked' do
      stub_request(:get, "#{client.base_url}/#{campaign.id}/adsets").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        data: [
          { id: 'ad_set_1', name: 'Ad Set 1' },
          { id: 'ad_set_2', name: 'Ad Set 2' }
        ],
        paging: { cursors: { before: '1' } }
      }.to_json)

      expect(campaign.ad_sets.map(&:name)).to include('Ad Set 1', 'Ad Set 2')
    end
  end
end
