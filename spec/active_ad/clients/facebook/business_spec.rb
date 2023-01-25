require 'spec_helper'

RSpec.describe ActiveAd::Facebook::Business do
  before(:all) do
    ActiveAd::Facebook.configure do |config|
      config.app_id     = 'client_100'
      config.app_secret = '1a2b3c'
    end
  end

  let(:client)       { ActiveAd::Facebook::Client.new(access_token: 'secret_access_token') }
  let(:business_101) { described_class.new(id: '101', stale: true, client:) }
  let(:business_901) { described_class.new(id: '901', stale: true, client:) }

  # GET read_request.
  let(:stub_read_101) {
    stub_request(:get, "#{client.base_url}/101")
      .with(query: hash_including(access_token: 'secret_access_token'))
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { id: '101', name: 'Business Name' }.to_json)
  }

  let(:stub_read_901) {
    stub_request(:get, "#{client.base_url}/901")
      .with(query: hash_including(access_token: 'secret_access_token'))
      .to_return(status: 404, headers: { 'Content-Type' => 'application/json' }, body: { error: { message: 'no no no!' } }.to_json)
  }

  # POST create_request.
  let(:stub_create_100) {
    stub_request(:post, "#{client.base_url}/100/businesses")
      .with(body: hash_including(access_token: 'secret_access_token'))
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { id: '101' }.to_json)
  }

  let(:stub_create_100_with_attributes) {
    stub_request(:post, "#{client.base_url}/100/businesses")
      .with(body: hash_including(access_token: 'secret_access_token', name: 'Business Name', vertical: 'OTHER'))
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { id: '101' }.to_json)
  }

  let(:stub_create_900) {
    stub_request(:post, "#{client.base_url}/900/businesses")
      .with(body: hash_including(access_token: 'secret_access_token'))
      .to_return(status: 400, headers: { 'Content-Type' => 'application/json' }, body: { error: { message: 'no no no!' } }.to_json)
  }

  # POST update_request.
  let(:stub_update_101) {
    stub_request(:post, "#{client.base_url}/101")
      .with(body: hash_including(access_token: 'secret_access_token', name: 'New Business Name'))
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { success: true }.to_json)
  }

  let(:stub_update_901) {
    stub_request(:post, "#{client.base_url}/901")
      .with(body: hash_including(access_token: 'secret_access_token', name: 'New Business Name'))
      .to_return(status: 400, headers: { 'Content-Type' => 'application/json' }, body: { error: { message: 'no no no!' } }.to_json)
  }

  describe '.find' do
    it 'returns an object when found' do
      stub_read_101
      expect(described_class.find('101', client:)).to be_an_instance_of(ActiveAd::Facebook::Business)
    end

    it 'returns nil when not found' do
      stub_read_901
      expect(described_class.find('901', client:)).to be_nil
    end
  end

  describe '.find!' do
    it 'returns an object when found' do
      stub_read_101
      expect(described_class.find!('101', client:)).to be_an_instance_of(ActiveAd::Facebook::Business)
    end

    it 'raises an exception when not found' do
      stub_read_901
      expect { described_class.find!('901', client:) }.to raise_error(ActiveAd::RecordNotFound)
    end
  end

  describe '.create' do
    it 'returns an object when created' do
      stub_create_100
      object = described_class.create(user_id: '100', validate: false, client:)
      expect(object).to be_an_instance_of(ActiveAd::Facebook::Business)
    end

    it 'sets an id when created' do
      stub_create_100
      object = described_class.create(user_id: '100', validate: false, client:)
      expect(object.id).to be(101)
    end

    it 'returns an object when not created' do
      stub_create_900
      object = described_class.create(user_id: '900', validate: false, client:)
      expect(object).to be_an_instance_of(ActiveAd::Facebook::Business)
    end

    it 'sets no attributes when not created' do
      stub_create_900
      object = described_class.create(user_id: '900', validate: false, client:)
      expect(object.attributes.compact).to be_empty
    end

    it 'does not allow a user_id of 0' do
      object = described_class.create(user_id: '0', name: 'Business Name', vertical: 'OTHER', client:)
      expect(object.attributes.compact).to be_empty
    end

    it 'sets no attributes when no name supplied' do
      object = described_class.create(user_id: '100', client:)
      expect(object.attributes.compact).to be_empty
    end

    it 'sets no attributes when no vertical supplied' do
      object = described_class.create(user_id: '100', name: 'Business Name', client:)
      expect(object.attributes.compact).to be_empty
    end

    it 'needs all the required attributes to be supplied' do
      stub_create_100_with_attributes
      object = described_class.create(user_id: '100', name: 'Business Name', vertical: 'OTHER', client:)
      expect(object.attributes.with_indifferent_access).to include(id: 101, name: 'Business Name', vertical: 'OTHER')
    end
  end

  describe '.create!' do
    it 'returns an object when created' do
      stub_create_100
      object = described_class.create!(user_id: '100', validate: false, client:)
      expect(object).to be_an_instance_of(ActiveAd::Facebook::Business)
    end

    it 'sets an id when created' do
      stub_create_100
      object = described_class.create!(user_id: '100', validate: false, client:)
      expect(object.id).to be(101)
    end

    it 'raises an exception when not created' do
      stub_create_900
      expect { described_class.create!(user_id: '900', validate: false, client:) }.to raise_error(ActiveAd::RecordNotSaved)
    end

    it 'raises an exception with user_id of 0' do
      expect { described_class.create!(user_id: '0', name: 'Business Name', vertical: 'OTHER', client:) }.to raise_error(ActiveAd::RecordInvalid)
    end

    it 'raises an exception with no name supplied' do
      expect { described_class.create!(user_id: '100', client:) }.to raise_error(ActiveAd::RecordInvalid)
    end

    it 'raises an exception with no vertical supplied' do
      expect { described_class.create!(user_id: '100', name: 'Business Name', client:) }.to raise_error(ActiveAd::RecordInvalid)
    end

    it 'needs all the required attributes to be supplied' do
      stub_create_100_with_attributes
      object = described_class.create!(user_id: '100', name: 'Business Name', vertical: 'OTHER', client:)
      expect(object.attributes.with_indifferent_access).to include(id: 101, name: 'Business Name', vertical: 'OTHER')
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
      business_101.update(name: 'New Business Name')
      expect(business_101.new_record?).to be(false)
    end

    it 'is not a new record after create' do
      stub_create_100
      expect(described_class.create(user_id: '100', validate: false, client:).new_record?).to be(false)
    end
  end

  describe '#valid?' do
    it 'is invalid if no name is present when creating a new record' do
      expect(described_class.new.valid?).to be(false)
    end

    it 'is valid if no name is present when updating an existing record' do
      business_101.name = nil
      expect(business_101.valid?).to be(true)
    end
  end

  describe '#save' do
    it 'returns true when saved' do
      stub_update_101
      business_101.name = 'New Business Name'
      expect(business_101.save).to be(true)
    end

    it 'returns false when not saved' do
      stub_update_901
      business_901.name = 'New Business Name'
      expect(business_901.save).to be(false)
    end
  end

  describe '#save!' do
    it 'returns true when saved' do
      stub_update_101
      business_101.name = 'New Business Name'
      expect(business_101.save!).to be(true)
    end

    it 'raises an exception when not saved' do
      stub_update_901
      business_901.name = 'New Business Name'
      expect { business_901.save! }.to raise_error(ActiveAd::RecordNotSaved)
    end
  end

  describe '#update' do
    it 'returns true when updated' do
      stub_update_101
      expect(business_101.update(name: 'New Business Name')).to be(true)
    end

    it 'returns false when not updated' do
      stub_update_901
      expect(business_901.update(name: 'New Business Name')).to be(false)
    end
  end

  describe '#update!' do
    it 'returns true when updated' do
      stub_update_101
      expect(business_101.update!(name: 'New Business Name')).to be(true)
    end

    it 'raise an exception when not updated' do
      stub_update_901
      expect { business_901.update!(name: 'New Business Name') }.to raise_error(ActiveAd::RecordNotSaved)
    end
  end

  describe '#destroy' do
    it 'raises an exception' do
      expect { business_901.destroy }.to raise_error(ActiveAd::RequestError)
    end
  end

  describe '#destroy!' do
    it 'raises an exception' do
      expect { business_901.destroy! }.to raise_error(ActiveAd::RequestError)
    end
  end

  describe '#page' do
    before(:each) do
      stub_request(:get, "#{client.base_url}/100")
        .with(query: hash_including(access_token: 'secret_access_token'))
        .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { id: '100', name: 'Page Name' }.to_json)
    end

    it 'returns the object type' do
      business_101.page_id = '100'
      expect(business_101.page.class).to be(ActiveAd::Facebook::Page)
    end

    it 'returns the object' do
      business_101.page_id = '100'
      expect(business_101.page.name).to eq('Page Name')
    end
  end

  describe '#accounts' do
    it 'returns a relation' do
      expect(business_101.accounts).to be_a(ActiveAd::Relation)
    end

    it 'returns the objects when invoked' do
      stub_request(:get, "#{client.base_url}/#{business_101.id}/adaccounts")
        .with(query: hash_including(access_token: 'secret_access_token'))
        .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: {
          data: [
            { id: 'act_1', name: 'Account 1' },
            { id: 'act_2', name: 'Account 2' }
          ],
          paging: { cursors: { before: '1' } }
        }.to_json)

      expect(business_101.accounts.map(&:name)).to include('Account 1', 'Account 2')
    end
  end
end
