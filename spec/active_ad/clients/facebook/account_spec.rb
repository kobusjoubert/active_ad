require 'spec_helper'

RSpec.describe ActiveAd::Facebook::Account do
  let(:account)     { described_class.new(id: 'account_123') }
  let(:api_version) { account.api_version }

  before(:all) do
    client = ActiveAd::Facebook::Client.new(access_token: 'secret_access_token', client_id: 'client_123', client_secret: '1a2b3c')
    ActiveAd::Facebook::Connection.client = client
  end

  describe '.find' do
    it 'returns an account when found' do
      stub_request(:get, "https://graph.facebook.com/v#{api_version}/act_account_123").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        id: 'act_account_123', name: 'Account Name'
      }.to_json)

      expect(described_class.find('account_123')).to be_an_instance_of(ActiveAd::Facebook::Account)
    end

    it 'returns nil if no account found' do
      stub_request(:get, "https://graph.facebook.com/v#{api_version}/act_account_999").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 404, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect(described_class.find('account_999')).to be_nil
    end
  end

  describe '.find!' do
    it 'returns an account when found' do
      stub_request(:get, "https://graph.facebook.com/v#{api_version}/act_account_123").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 200, body: {
        id: 'act_account_123', name: 'Account Name'
      }.to_json)

      expect(described_class.find!('account_123')).to be_an_instance_of(ActiveAd::Facebook::Account)
    end

    it 'raises exception if no account found' do
      stub_request(:get, "https://graph.facebook.com/v#{api_version}/act_account_999").with(query:
        hash_including(access_token: 'secret_access_token')
      ).to_return(status: 404, body: {
        error: { message: 'no no no!' }
      }.to_json)

      expect{ described_class.find!('account_999') }.to raise_error(ActiveAd::RecordNotFound)
    end
  end

  describe '.create'
  describe '.create!'

  describe '#initialize' do
    it 'sets the account_id' do
      expect(described_class.new(id: 'account_123').account_id).to eq('account_123')
    end
  end

  describe '#platform' do
    it 'returns the platform name' do
      expect(account.platform).to eq('facebook')
    end
  end

  describe '#api_version'
  describe '#access_token'
  describe '#save'
  describe '#save!'
  describe '#update'
  describe '#update!'
  describe '#destroy'
  describe '#destroy!'

  describe '#new_record?' do
    it 'is not a new record when initializing with id' do
      stub_request(:any, /.*/)

      expect(described_class.new(id: 'account_123').new_record?).to be(false)
    end

    it 'is not a new record on update', skip: true do
      stub_request(:any, /.*/)

      account = described_class.new(id: 'account_123')
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
