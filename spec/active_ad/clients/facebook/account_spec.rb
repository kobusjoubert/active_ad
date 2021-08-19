require 'spec_helper'

RSpec.describe ActiveAd::Facebook::Account do
  before(:all) do
    ActiveAd::Facebook.configure do |config|
      config.client = ActiveAd::Facebook::Client.new(access_token: 'secret_access_token', client_id: 'client_100', client_secret: '1a2b3c')
    end
  end

  let(:client)      { ActiveAd::Base.client }
  let(:account_101) { described_class.new(id: '101', stale: true) }
  let(:account_901) { described_class.new(id: '901', stale: true) }

  # GET read_request.
  let(:stub_read_101) {
    stub_request(:get, "#{client.base_url}/act_101").with(query:
      hash_including(access_token: 'secret_access_token')
    ).to_return(status: 200, body: {
      id: 'act_101', name: 'Account Name'
    }.to_json)
  }

  let(:stub_read_901) {
    stub_request(:get, "#{client.base_url}/act_901").with(query:
      hash_including(access_token: 'secret_access_token')
    ).to_return(status: 404, body: {
      error: { message: 'no no no!' }
    }.to_json)
  }

  # POST create_request.
  let(:stub_create_100) {
    stub_request(:post, "#{client.base_url}/100/adaccount").with(body:
      hash_including(access_token: 'secret_access_token')
    ).to_return(status: 200, body: {
      id: 'act_101'
    }.to_json)
  }

  let(:stub_create_100_with_attributes) {
    stub_request(:post, "#{client.base_url}/100/adaccount").with(body:
      hash_including(access_token: 'secret_access_token', name: 'Account Name', currency: 'USD', timezone_id: 0, partner: 'NONE', media_agency: 'NONE',
                     end_advertiser: 'NONE')
    ).to_return(status: 200, body: {
      id: 'act_101'
    }.to_json)
  }

  let(:stub_create_900) {
    stub_request(:post, "#{client.base_url}/900/adaccount").with(body:
      hash_including(access_token: 'secret_access_token')
    ).to_return(status: 400, body: {
      error: { message: 'no no no!' }
    }.to_json)
  }

  # POST update_request.
  let(:stub_update_101) {
    stub_request(:post, "#{client.base_url}/act_101").with(body:
      hash_including(access_token: 'secret_access_token', name: 'New Account Name')
    ).to_return(status: 200, body: {
      success: true
    }.to_json)
  }

  let(:stub_update_901) {
    stub_request(:post, "#{client.base_url}/act_901").with(body:
      hash_including(access_token: 'secret_access_token', name: 'New Account Name')
    ).to_return(status: 400, body: {
      error: { message: 'no no no!' }
    }.to_json)
  }

  describe '.find' do
    it 'returns an object when found' do
      stub_read_101
      expect(described_class.find('101')).to be_an_instance_of(ActiveAd::Facebook::Account)
    end

    it 'returns nil when not found' do
      stub_read_901
      expect(described_class.find('901')).to be_nil
    end
  end

  describe '.find!' do
    it 'returns an object when found' do
      stub_read_101
      expect(described_class.find!('101')).to be_an_instance_of(ActiveAd::Facebook::Account)
    end

    it 'raises an exception when not found' do
      stub_read_901
      expect { described_class.find!('901') }.to raise_error(ActiveAd::RecordNotFound)
    end
  end

  describe '.create' do
    it 'returns an object when created' do
      stub_create_100
      object = described_class.create(business_id: '100', validate: false)
      expect(object).to be_an_instance_of(ActiveAd::Facebook::Account)
    end

    it 'sets an id when created' do
      stub_create_100
      object = described_class.create(business_id: '100', validate: false)
      expect(object.id).to be(101)
    end

    it 'returns an object when not created' do
      stub_create_900
      object = described_class.create(business_id: '900', validate: false)
      expect(object).to be_an_instance_of(ActiveAd::Facebook::Account)
    end

    it 'sets no attributes when not created' do
      stub_create_900
      object = described_class.create(business_id: '900', validate: false)
      expect(object.attributes.compact).to be_empty
    end

    it 'does not allow a business_id of 0' do
      object = described_class.create(business_id: '0', name: 'Account Name', currency: 'USD', timezone_id: 0, partner: 'NONE', media_agency: 'NONE',
                                      end_advertiser: 'NONE')
      expect(object.attributes.compact).to be_empty
    end

    it 'sets no attributes when no name supplied' do
      object = described_class.create(business_id: '100')
      expect(object.attributes.compact).to be_empty
    end

    it 'sets no attributes when no currency supplied' do
      object = described_class.create(business_id: '100', name: 'Account Name')
      expect(object.attributes.compact).to be_empty
    end

    it 'sets no attributes when no timezone_id supplied' do
      object = described_class.create(business_id: '100', name: 'Account Name', currency: 'USD')
      expect(object.attributes.compact).to be_empty
    end

    it 'sets no attributes when no partner supplied' do
      object = described_class.create(business_id: '100', name: 'Account Name', currency: 'USD', timezone_id: 0)
      expect(object.attributes.compact).to be_empty
    end

    it 'sets no attributes when no media_agency supplied' do
      object = described_class.create(business_id: '100', name: 'Account Name', currency: 'USD', timezone_id: 0, partner: 'NONE')
      expect(object.attributes.compact).to be_empty
    end

    it 'sets no attributes when no end_advertiser supplied' do
      object = described_class.create(business_id: '100', name: 'Account Name', currency: 'USD', timezone_id: 0, partner: 'NONE', media_agency: 'NONE')
      expect(object.attributes.compact).to be_empty
    end

    it 'needs all the required attributes to be supplied' do
      stub_create_100_with_attributes
      object = described_class.create(business_id: '100', name: 'Account Name', currency: 'USD', timezone_id: 0, partner: 'NONE', media_agency: 'NONE',
                                      end_advertiser: 'NONE')
      expect(object.attributes.with_indifferent_access).to include(name: 'Account Name', currency: 'USD', timezone_id: 0, partner_id: 'NONE',
                                                                   media_agency_id: 'NONE', end_advertiser_id: 'NONE')
    end
  end

  describe '.create!' do
    it 'returns an object when created' do
      stub_create_100
      object = described_class.create(business_id: '100', validate: false)
      expect(object).to be_an_instance_of(ActiveAd::Facebook::Account)
    end

    it 'sets an id when created' do
      stub_create_100
      object = described_class.create(business_id: '100', validate: false)
      expect(object.id).to be(101)
    end

    it 'raises an exception when not created' do
      stub_create_900
      expect { described_class.create!(business_id: '900', validate: false) }.to raise_error(ActiveAd::RecordNotSaved)
    end

    it 'raises an exception with business_id of 0' do
      expect { described_class.create!(business_id: '0', name: 'Business Name') }.to raise_error(ActiveAd::RecordInvalid)
    end

    it 'raises an exception with no name supplied' do
      expect { described_class.create!(business_id: '100') }.to raise_error(ActiveAd::RecordInvalid)
    end

    it 'sets no attributes when no currency supplied' do
      expect { described_class.create!(business_id: '100', name: 'Account Name') }.to raise_error(ActiveAd::RecordInvalid)
    end

    it 'sets no attributes when no timezone_id supplied' do
      expect { described_class.create!(business_id: '100', name: 'Account Name', currency: 'USD') }.to raise_error(ActiveAd::RecordInvalid)
    end

    it 'sets no attributes when no partner supplied' do
      expect { described_class.create!(business_id: '100', name: 'Account Name', currency: 'USD', timezone_id: 0) }.to raise_error(ActiveAd::RecordInvalid)
    end

    it 'sets no attributes when no media_agency supplied' do
      expect {
        described_class.create!(business_id: '100', name: 'Account Name', currency: 'USD', timezone_id: 0, partner: 'NONE')
      }.to raise_error(ActiveAd::RecordInvalid)
    end

    it 'sets no attributes when no end_advertiser supplied' do
      expect {
        described_class.create!(business_id: '100', name: 'Account Name', currency: 'USD', timezone_id: 0, partner: 'NONE', media_agency: 'NONE')
      }.to raise_error(ActiveAd::RecordInvalid)
    end

    it 'needs all the required attributes to be supplied' do
      stub_create_100_with_attributes
      object = described_class.create!(business_id: '100', name: 'Account Name', currency: 'USD', timezone_id: 0,
                                       partner: 'NONE', media_agency: 'NONE', end_advertiser: 'NONE')
      expect(object.attributes.with_indifferent_access).to include(name: 'Account Name', currency: 'USD', timezone_id: 0, partner_id: 'NONE',
                                                                   media_agency_id: 'NONE', end_advertiser_id: 'NONE')
    end
  end

  describe '#initialize' do
    it 'sets the id' do
      expect(described_class.new(id: '101').id).to be(101)
    end

    it 'removes prefix "act_" when setting the id' do
      expect(described_class.new(id: 'act_101').id).to eq(101)
    end

    it 'sets the id to 0 when trying to set an invalid id' do
      expect(described_class.new(id: 'unrecognizable_123').id).to eq(0)
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
      account_101.update(name: 'New Account Name')
      expect(account_101.new_record?).to be(false)
    end

    it 'is not a new record after create' do
      stub_create_100
      expect(described_class.create(business_id: '100', validate: false).new_record?).to be(false)
    end
  end

  describe '#valid?' do
    it 'is invalid if no name is present when creating a new record' do
      expect(described_class.new.valid?).to be(false)
    end

    it 'is valid if no name is present when updating an existing record' do
      account_101.name = nil
      expect(account_101.valid?).to be(true)
    end
  end

  describe '#save' do
    it 'returns true when saved' do
      stub_update_101
      account_101.name = 'New Account Name'
      expect(account_101.save).to be(true)
    end

    it 'returns false when not saved' do
      stub_update_901
      account_901.name = 'New Account Name'
      expect(account_901.save).to be(false)
    end
  end

  describe '#save!' do
    it 'returns true when saved' do
      stub_update_101
      account_101.name = 'New Account Name'
      expect(account_101.save!).to be(true)
    end

    it 'raises an exception when not saved' do
      stub_update_901
      account_901.name = 'New Account Name'
      expect { account_901.save! }.to raise_error(ActiveAd::RecordNotSaved)
    end
  end

  describe '#update' do
    it 'returns true when updated' do
      stub_update_101
      expect(account_101.update(name: 'New Account Name')).to be(true)
    end

    it 'returns false when not updated' do
      stub_update_901
      expect(account_901.update(name: 'New Account Name')).to be(false)
    end
  end

  describe '#update!' do
    it 'returns true when updated' do
      stub_update_101
      expect(account_101.update!(name: 'New Account Name')).to be(true)
    end

    it 'raise an exception when not updated' do
      stub_update_901
      expect { account_901.update!(name: 'New Account Name') }.to raise_error(ActiveAd::RecordNotSaved)
    end
  end

  describe '#destroy' do
    it 'raises an exception' do
      expect { account_901.destroy }.to raise_error(ActiveAd::RequestError)
    end
  end

  describe '#destroy!' do
    it 'raises an exception' do
      expect { account_901.destroy! }.to raise_error(ActiveAd::RequestError)
    end
  end

  describe '#business' do
    before(:each) do
      stub_request(:get, "#{client.base_url}/100").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        id: '100', name: 'Business Name'
      }.to_json)
    end

    it 'returns the object type' do
      account_101.business_id = '100'
      expect(account_101.business.class).to be(ActiveAd::Facebook::Business)
    end

    it 'returns the object' do
      account_101.business_id = '100'
      expect(account_101.business.name).to eq('Business Name')
    end
  end

  describe '#campaigns' do
    it 'returns a relation' do
      expect(account_101.campaigns).to be_a_kind_of(ActiveAd::Relation)
    end

    it 'returns the objects when invoked' do
      stub_request(:get, "#{client.base_url}/act_#{account_101.id}/campaigns").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        data: [
          { id: '1', name: 'Campaign 1' },
          { id: '2', name: 'Campaign 2' }
        ],
        paging: { cursors: { before: '1' } }
      }.to_json)

      expect(account_101.campaigns.map(&:name)).to include('Campaign 1', 'Campaign 2')
    end
  end

  describe '#custom_audiences' do
    it 'returns a relation' do
      expect(account_101.custom_audiences).to be_a_kind_of(ActiveAd::Relation)
    end

    it 'returns the objects when invoked' do
      stub_request(:get, "#{client.base_url}/act_#{account_101.id}/customaudiences").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        data: [
          { id: '1', name: 'Custom Audience 1' },
          { id: '2', name: 'Custom Audience 2' }
        ],
        paging: { cursors: { before: '1' } }
      }.to_json)

      expect(account_101.custom_audiences.map(&:name)).to include('Custom Audience 1', 'Custom Audience 2')
    end
  end

  describe '#ad_sets' do
    it 'returns a relation' do
      expect(account_101.ad_sets).to be_a_kind_of(ActiveAd::Relation)
    end

    it 'returns the objects when invoked' do
      stub_request(:get, "#{client.base_url}/act_#{account_101.id}/adsets").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        data: [
          { id: '1', name: 'Ad Set 1' },
          { id: '2', name: 'Ad Set 2' }
        ],
        paging: { cursors: { before: '1' } }
      }.to_json)

      expect(account_101.ad_sets.map(&:name)).to include('Ad Set 1', 'Ad Set 2')
    end
  end

  describe '#ads' do
    it 'returns a relation' do
      expect(account_101.ads).to be_a_kind_of(ActiveAd::Relation)
    end

    it 'returns the objects when invoked' do
      stub_request(:get, "#{client.base_url}/act_#{account_101.id}/ads").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        data: [
          { id: '1', name: 'Ad 1' },
          { id: '2', name: 'Ad 2' }
        ],
        paging: { cursors: { before: '1' } }
      }.to_json)

      expect(account_101.ads.map(&:name)).to include('Ad 1', 'Ad 2')
    end
  end

  describe '#ad_creatives' do
    it 'returns a relation' do
      expect(account_101.ad_creatives).to be_a_kind_of(ActiveAd::Relation)
    end

    it 'returns the objects when invoked' do
      stub_request(:get, "#{client.base_url}/act_#{account_101.id}/adcreatives").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        data: [
          { id: '1', name: 'Ad Creative 1' },
          { id: '2', name: 'Ad Creative 2' }
        ],
        paging: { cursors: { before: '1' } }
      }.to_json)

      expect(account_101.ad_creatives.map(&:name)).to include('Ad Creative 1', 'Ad Creative 2')
    end
  end

  describe '#pixels' do
    it 'returns a relation' do
      expect(account_101.pixels).to be_a_kind_of(ActiveAd::Relation)
    end

    it 'returns the objects when invoked' do
      stub_request(:get, "#{client.base_url}/act_#{account_101.id}/adspixels").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        data: [
          { id: '1', name: 'Pixel 1' },
          { id: '2', name: 'Pixel 2' }
        ],
        paging: { cursors: { before: '1' } }
      }.to_json)

      expect(account_101.pixels.map(&:name)).to include('Pixel 1', 'Pixel 2')
    end
  end

  describe '#saved_audiences' do
    it 'returns a relation' do
      expect(account_101.saved_audiences).to be_a_kind_of(ActiveAd::Relation)
    end

    it 'returns the objects when invoked' do
      stub_request(:get, "#{client.base_url}/act_#{account_101.id}/saved_audiences").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        data: [
          { id: '1' },
          { id: '2' }
        ],
        paging: { cursors: { before: '1' } }
      }.to_json)

      expect(account_101.saved_audiences.map(&:id)).to include(1, 2)
    end
  end
end
