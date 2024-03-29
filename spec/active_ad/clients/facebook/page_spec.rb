require 'spec_helper'

RSpec.describe ActiveAd::Facebook::Page do
  before(:all) do
    ActiveAd::Facebook.configure do |config|
      config.app_id     = 'client_100'
      config.app_secret = '1a2b3c'
    end
  end

  let(:client)   { ActiveAd::Facebook::Client.new(access_token: 'secret_access_token') }
  let(:page_101) { described_class.new(id: '101', stale: true, client:) }
  let(:page_901) { described_class.new(id: '901', stale: true, client:) }

  # GET read_request.
  let(:stub_read_101) {
    stub_request(:get, "#{client.base_url}/101")
      .with(query: hash_including(access_token: 'secret_access_token'))
      .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { id: '101', name: 'User Name' }.to_json)
  }

  let(:stub_read_901) {
    stub_request(:get, "#{client.base_url}/901")
      .with(query: hash_including(access_token: 'secret_access_token'))
      .to_return(status: 404, headers: { 'Content-Type' => 'application/json' }, body: { error: { message: 'no no no!' } }.to_json)
  }

  describe '.find' do
    it 'returns an object when found' do
      stub_read_101
      expect(described_class.find('101', client:)).to be_an_instance_of(ActiveAd::Facebook::Page)
    end

    it 'returns nil when not found' do
      stub_read_901
      expect(described_class.find('901', client:)).to be_nil
    end
  end

  describe '.find!' do
    it 'returns an object when found' do
      stub_read_101
      expect(described_class.find!('101', client:)).to be_an_instance_of(ActiveAd::Facebook::Page)
    end

    it 'raises an exception when not found' do
      stub_read_901
      expect { described_class.find!('901', client:) }.to raise_error(ActiveAd::RecordNotFound)
    end
  end

  describe '#initialize' do
    it 'sets the id' do
      expect(described_class.new(id: '101', client:).id).to be(101)
    end
  end

  describe '#business' do
    before(:each) do
      stub_request(:get, "#{client.base_url}/100")
        .with(query: hash_including(access_token: 'secret_access_token'))
        .to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { id: '100', name: 'Business Name' }.to_json)
    end

    it 'returns the object type' do
      page_101.business_id = '100'
      expect(page_101.business.class).to be(ActiveAd::Facebook::Business)
    end

    it 'returns the object' do
      page_101.business_id = '100'
      expect(page_101.business.name).to eq('Business Name')
    end
  end
end
