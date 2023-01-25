require 'spec_helper'

RSpec.describe ActiveAd::Facebook::Ad do
  before(:all) do
    ActiveAd::Facebook.configure do |config|
      config.app_id     = 'client_100'
      config.app_secret = '1a2b3c'
    end
  end

  let(:client) { ActiveAd::Facebook::Client.new(access_token: 'secret_access_token') }
  let(:ad_101) { described_class.new(id: '101', stale: true, client:) }
  let(:ad_801) { described_class.new(id: '801', stale: true, client:) }
  let(:ad_901) { described_class.new(id: '901', stale: true, client:) }

  # GET read_request.
  let(:stub_read_101) {
    stub_request(:get, "#{client.base_url}/101")
      .with(query: hash_including(access_token: 'secret_access_token'))
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { id: '101', name: 'Ad Name' }.to_json)
  }

  let(:stub_read_901) {
    stub_request(:get, "#{client.base_url}/901")
      .with(query: hash_including(access_token: 'secret_access_token'))
      .to_return(status: 404, headers: { 'Content-Type' => 'application/json' }, body: { error: { message: 'no no no!' } }.to_json)
  }

  # POST create_request.
  let(:stub_create_100) {
    stub_request(:post, "#{client.base_url}/act_100/ads")
      .with(body: hash_including(access_token: 'secret_access_token'))
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { id: '101' }.to_json)
  }

  let(:stub_create_100_with_attributes) {
    stub_request(:post, "#{client.base_url}/act_100/ads")
      .with(body: hash_including(access_token: 'secret_access_token', name: 'Ad Name', status: 'PAUSED', creative: { creative_id: '300' }))
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { id: '101' }.to_json)
  }

  let(:stub_create_900) {
    stub_request(:post, "#{client.base_url}/act_900/ads")
      .with(body: hash_including(access_token: 'secret_access_token'))
      .to_return(status: 400, headers: { 'Content-Type' => 'application/json' }, body: { error: { message: 'no no no!' } }.to_json)
  }

  # POST update_request.
  let(:stub_update_101) {
    stub_request(:post, "#{client.base_url}/101")
      .with(body: hash_including(access_token: 'secret_access_token', name: 'New Ad Name'))
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { success: true }.to_json)
  }

  let(:stub_update_901) {
    stub_request(:post, "#{client.base_url}/901")
      .with(body: hash_including(access_token: 'secret_access_token', name: 'New Ad Name'))
      .to_return(status: 400, headers: { 'Content-Type' => 'application/json' }, body: { error: { message: 'no no no!' } }.to_json)
  }

  # DELETE delete_request.
  let(:stub_delete_101) {
    stub_request(:delete, "#{client.base_url}/101")
      .with(query: hash_including(access_token: 'secret_access_token'))
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { success: true }.to_json)
  }

  let(:stub_delete_801) {
    stub_request(:delete, "#{client.base_url}/801")
      .with(query: hash_including(access_token: 'secret_access_token'))
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { success: false }.to_json)
  }

  let(:stub_delete_901) {
    stub_request(:delete, "#{client.base_url}/901")
      .with(query: hash_including(access_token: 'secret_access_token'))
      .to_return(status: 400, headers: { 'Content-Type' => 'application/json' }, body: { error: { message: 'no no no!' } }.to_json)
  }

  describe '.find' do
    it 'returns an object when found' do
      stub_read_101
      expect(described_class.find('101', client:)).to be_an_instance_of(ActiveAd::Facebook::Ad)
    end

    it 'returns nil when not found' do
      stub_read_901
      expect(described_class.find('901', client:)).to be_nil
    end
  end

  describe '.find!' do
    it 'returns an object when found' do
      stub_read_101
      expect(described_class.find!('101', client:)).to be_an_instance_of(ActiveAd::Facebook::Ad)
    end

    it 'raises an exception when not found' do
      stub_read_901
      expect { described_class.find!('901', client:) }.to raise_error(ActiveAd::RecordNotFound)
    end
  end

  describe '.create' do
    it 'returns an object when created' do
      stub_create_100
      object = described_class.create(account_id: '100', validate: false, client:)
      expect(object).to be_an_instance_of(ActiveAd::Facebook::Ad)
    end

    it 'sets an id when created' do
      stub_create_100
      object = described_class.create(account_id: '100', validate: false, client:)
      expect(object.id).to be(101)
    end

    it 'returns an object when not created' do
      stub_create_900
      object = described_class.create(account_id: '900', validate: false, client:)
      expect(object).to be_an_instance_of(ActiveAd::Facebook::Ad)
    end

    it 'sets no attributes when not created' do
      stub_create_900
      object = described_class.create(account_id: '900', validate: false, client:)
      expect(object.attributes.compact).to be_empty
    end

    it 'does not allow an account_id of 0' do
      object = described_class.create(account_id: '0', ad_set_id: '200', name: 'Ad Name', status: 'PAUSED', creative: { creative_id: '300' }, client:)
      expect(object.attributes.compact).to be_empty
    end

    it 'sets no attributes when no ad_set_id supplied' do
      object = described_class.create(account_id: '100', client:)
      expect(object.attributes.compact).to be_empty
    end

    it 'sets no attributes when no name supplied' do
      object = described_class.create(account_id: '100', ad_set_id: '200', client:)
      expect(object.attributes.compact).to be_empty
    end

    it 'sets no attributes when no status supplied' do
      object = described_class.create(account_id: '100', ad_set_id: '200', name: 'Ad Name', client:)
      expect(object.attributes.compact).to be_empty
    end

    it 'sets no attributes when no creative supplied' do
      object = described_class.create(account_id: '100', ad_set_id: '200', name: 'Ad Name', status: 'PAUSED', client:)
      expect(object.attributes.compact).to be_empty
    end

    it 'needs all the required attributes to be supplied' do
      stub_create_100_with_attributes
      object = described_class.create(account_id: '100', ad_set_id: '200', name: 'Ad Name', status: 'PAUSED', creative: { creative_id: '300' }, client:)
      expect(object.attributes.with_indifferent_access).to include(id: 101, ad_set_id: 200, name: 'Ad Name', status: 'PAUSED', creative: { creative_id: '300' })
    end
  end

  describe '.create!' do
    it 'returns an object when created' do
      stub_create_100
      object = described_class.create!(account_id: '100', validate: false, client:)
      expect(object).to be_an_instance_of(ActiveAd::Facebook::Ad)
    end

    it 'sets an id when created' do
      stub_create_100
      object = described_class.create!(account_id: '100', validate: false, client:)
      expect(object.id).to be(101)
    end

    it 'raises an exception when not created' do
      stub_create_900
      expect { described_class.create!(account_id: '900', validate: false, client:) }.to raise_error(ActiveAd::RecordNotSaved)
    end

    it 'raises an exception with account_id of 0' do
      expect {
        described_class.create!(account_id: '0', ad_set_id: '200', name: 'Ad Name', status: 'PAUSED', creative: { creative_id: '300' }, client:)
      }.to raise_error(ActiveAd::RecordInvalid)
    end

    it 'raises an exception with no ad_set_id supplied' do
      expect { described_class.create!(account_id: '100', client:) }.to raise_error(ActiveAd::RecordInvalid)
    end

    it 'raises an exception with no name supplied' do
      expect { described_class.create!(account_id: '100', ad_set_id: '200', client:) }.to raise_error(ActiveAd::RecordInvalid)
    end

    it 'raises an exception with no status supplied' do
      expect { described_class.create!(account_id: '100', ad_set_id: '200', name: 'Ad Name', client:) }.to raise_error(ActiveAd::RecordInvalid)
    end

    it 'raises an exception with no creative supplied' do
      expect {
        described_class.create!(account_id: '100', ad_set_id: '200', name: 'Ad Name', status: 'PAUSED', client:)
      }.to raise_error(ActiveAd::RecordInvalid)
    end

    it 'needs all the required attributes to be supplied' do
      stub_create_100_with_attributes
      object = described_class.create!(account_id: '100', ad_set_id: '200', name: 'Ad Name', status: 'PAUSED', creative: { creative_id: '300' }, client:)
      expect(object.attributes.with_indifferent_access).to include(id: 101, ad_set_id: 200, name: 'Ad Name', status: 'PAUSED', creative: { creative_id: '300' })
    end
  end

  describe '#initialize' do
    it 'sets the id' do
      expect(described_class.new(id: '101').id).to be(101)
    end
  end

  describe '#new_record?' do
    it 'is a new record when initializing without an id' do
      expect(described_class.new.new_record?).to be(true)
    end

    it 'is not a new record when initializing with id' do
      expect(described_class.new(id: '101').new_record?).to be(false)
    end

    it 'is not a new record after update' do
      stub_update_101
      ad_101.update(name: 'New Ad Name')
      expect(ad_101.new_record?).to be(false)
    end

    it 'is not a new record after create' do
      stub_create_100
      expect(described_class.create(account_id: '100', validate: false, client:).new_record?).to be(false)
    end
  end

  describe '#valid?' do
    it 'is invalid if no name is present when creating a new record' do
      expect(described_class.new.valid?).to be(false)
    end

    it 'is valid if no name is present when updating an existing record' do
      ad_101.name = nil
      expect(ad_101.valid?).to be(true)
    end
  end

  describe '#save' do
    it 'returns true when saved' do
      stub_update_101
      ad_101.name = 'New Ad Name'
      expect(ad_101.save).to be(true)
    end

    it 'returns false when not saved' do
      stub_update_901
      ad_901.name = 'New Ad Name'
      expect(ad_901.save).to be(false)
    end
  end

  describe '#save!' do
    it 'returns true when saved' do
      stub_update_101
      ad_101.name = 'New Ad Name'
      expect(ad_101.save!).to be(true)
    end

    it 'raises an exception when not saved' do
      stub_update_901
      ad_901.name = 'New Ad Name'
      expect { ad_901.save! }.to raise_error(ActiveAd::RecordNotSaved)
    end
  end

  describe '#update' do
    it 'returns true when updated' do
      stub_update_101
      expect(ad_101.update(name: 'New Ad Name')).to be(true)
    end

    it 'returns false when not updated' do
      stub_update_901
      expect(ad_901.update(name: 'New Ad Name')).to be(false)
    end
  end

  describe '#update!' do
    it 'returns true when updated' do
      stub_update_101
      expect(ad_101.update!(name: 'New Ad Name')).to be(true)
    end

    it 'raise an exception when not updated' do
      stub_update_901
      expect { ad_901.update!(name: 'New Ad Name') }.to raise_error(ActiveAd::RecordNotSaved)
    end
  end

  describe '#destroy' do
    it 'returns true when deleted' do
      stub_delete_101
      expect(ad_101.destroy).to be(true)
    end

    it 'returns false when not deleted' do
      stub_delete_801
      expect(ad_801.destroy).to be(false)
    end

    it 'returns false on a bad request' do
      stub_delete_901
      expect(ad_901.destroy).to be(false)
    end
  end

  describe '#destroy!' do
    it 'returns true when deleted' do
      stub_delete_101
      expect(ad_101.destroy!).to be(true)
    end

    it 'raises an exception when not deleted' do
      stub_delete_801
      expect { ad_801.destroy! }.to raise_error(ActiveAd::RecordNotDeleted)
    end

    it 'raises an exception on a bad request' do
      stub_delete_901
      expect { ad_901.destroy! }.to raise_error(ActiveAd::RecordNotDeleted)
    end
  end

  describe '#account' do
    before(:each) do
      stub_request(:get, "#{client.base_url}/act_100")
        .with(query: hash_including(access_token: 'secret_access_token'))
        .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { id: '100', name: 'Account Name' }.to_json)
    end

    it 'returns the object type' do
      ad_101.account_id = '100'
      expect(ad_101.account.class).to be(ActiveAd::Facebook::Account)
    end

    it 'returns the object' do
      ad_101.account_id = '100'
      expect(ad_101.account.name).to eq('Account Name')
    end
  end

  describe '#campaign' do
    before(:each) do
      stub_request(:get, "#{client.base_url}/100")
        .with(query: hash_including(access_token: 'secret_access_token'))
        .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { id: '100', name: 'Campaign Name' }.to_json)
    end

    it 'returns the object type' do
      ad_101.campaign_id = '100'
      expect(ad_101.campaign.class).to be(ActiveAd::Facebook::Campaign)
    end

    it 'returns the object' do
      ad_101.campaign_id = '100'
      expect(ad_101.campaign.name).to eq('Campaign Name')
    end
  end

  describe '#ad_set' do
    before(:each) do
      stub_request(:get, "#{client.base_url}/100")
        .with(query: hash_including(access_token: 'secret_access_token'))
        .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { id: '100', name: 'Ad Set Name' }.to_json)
    end

    it 'returns the object type' do
      ad_101.ad_set_id = '100'
      expect(ad_101.ad_set.class).to be(ActiveAd::Facebook::AdSet)
    end

    it 'returns the object' do
      ad_101.ad_set_id = '100'
      expect(ad_101.ad_set.name).to eq('Ad Set Name')
    end
  end

  describe '#ad_creative' do
    before(:each) do
      stub_request(:get, "#{client.base_url}/100")
        .with(query: hash_including(access_token: 'secret_access_token'))
        .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { id: '100', name: 'Ad Creative Name' }.to_json)
    end

    it 'returns the object type' do
      ad_101.ad_creative_id = '100'
      expect(ad_101.ad_creative.class).to be(ActiveAd::Facebook::AdCreative)
    end

    it 'returns the object' do
      ad_101.ad_creative_id = '100'
      expect(ad_101.ad_creative.name).to eq('Ad Creative Name')
    end
  end
end
