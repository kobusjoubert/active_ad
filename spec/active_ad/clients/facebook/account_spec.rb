require 'spec_helper'

RSpec.describe ActiveAd::Facebook::Account do
  before(:all) do
    client = ActiveAd::Facebook::Client.new(access_token: 'secret_access_token', client_id: 'client_123', client_secret: '1a2b3c')
    ActiveAd::Facebook::Connection.client = client
  end

  let(:account) { described_class.new(id: 'account_123') }
  let(:client)  { ActiveAd::Base.client }

  describe '.find' do
    it 'returns an account when found' do
      stub_request(:get, "https://graph.facebook.com/v#{client.api_version}/act_123").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        id: 'act_123', name: 'Account Name'
      }.to_json)

      expect(described_class.find('123')).to be_an_instance_of(ActiveAd::Facebook::Account)
    end

    it 'returns nil if no account found' do
      stub_request(:get, "https://graph.facebook.com/v#{client.api_version}/act_999").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 404, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect(described_class.find('999')).to be_nil
    end

    it 'returns nil when requesting an invalid id' do
      stub_request(:get, "https://graph.facebook.com/v#{client.api_version}/act_0").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 404, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect(described_class.find('unrecognizable_123')).to be_nil
    end
  end

  describe '.find!' do
    it 'returns an account when found' do
      stub_request(:get, "https://graph.facebook.com/v#{client.api_version}/act_123").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        id: 'act_123', name: 'Account Name'
      }.to_json)

      expect(described_class.find!('123')).to be_an_instance_of(ActiveAd::Facebook::Account)
    end

    it 'raises exception if no account found' do
      stub_request(:get, "https://graph.facebook.com/v#{client.api_version}/act_999").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 404, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect{ described_class.find!('999') }.to raise_error(ActiveAd::RecordNotFound)
    end

    it 'raises exception when requesting an invalid id' do
      stub_request(:get, "https://graph.facebook.com/v#{client.api_version}/act_0").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 404, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect{ described_class.find!('unrecognizable_123') }.to raise_error(ActiveAd::RecordNotFound)
    end
  end

  describe '.create'
  describe '.create!'

  describe '#initialize' do
    it 'sets the id' do
      expect(described_class.new(id: '123').id).to eq(123)
    end

    it 'removes prefix "act_" when setting the id' do
      expect(described_class.new(id: 'act_123').id).to eq(123)
    end

    it 'sets the id to 0 when trying to set an invalid id' do
      expect(described_class.new(id: 'unrecognizable_123').id).to eq(0)
    end
  end

  describe '#save'
  describe '#save!'
  describe '#update'
  describe '#update!'
  describe '#destroy'
  describe '#destroy!'

  describe '#new_record?' do
    it 'is not a new record when initializing with id' do
      stub_request(:any, /.*/)

      expect(described_class.new(id: '123').new_record?).to be(false)
    end

    it 'is not a new record on update' do
      stub_request(:any, /.*/)

      account = described_class.new(id: '123')
      account.update(name: 'New Account Name', validate: false)
      expect(account.new_record?).to be(false)
    end

    it 'is a new record on create', skip: true do
      stub_request(:any, /.*/)

      expect(described_class.create(name: 'Account Name', validate: false).new_record?).to be(true)
    end
  end

  describe '#valid?'
end
