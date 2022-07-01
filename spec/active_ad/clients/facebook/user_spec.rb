require 'spec_helper'

RSpec.describe ActiveAd::Facebook::User do
  before(:all) do
    ActiveAd::Facebook.configure do |config|
      config.app_id     = 'client_100'
      config.app_secret = '1a2b3c'
    end
  end

  let(:client)   { ActiveAd::Facebook::Client.new(access_token: 'secret_access_token') }
  let(:user_101) { described_class.new(id: '101', stale: true, client:) }
  let(:user_901) { described_class.new(id: '901', stale: true, client:) }

  # GET read_request.
  let(:stub_read_101) {
    stub_request(:get, "#{client.base_url}/101")
      .with(query: hash_including(access_token: 'secret_access_token'))
      .to_return(status: 200, body: { id: '101', name: 'User Name' }.to_json)
  }

  let(:stub_read_901) {
    stub_request(:get, "#{client.base_url}/901")
      .with(query: hash_including(access_token: 'secret_access_token'))
      .to_return(status: 404, body: { error: { message: 'no no no!' } }.to_json)
  }

  describe '.find' do
    it 'returns an object when found' do
      stub_read_101
      expect(described_class.find('101', client:)).to be_an_instance_of(ActiveAd::Facebook::User)
    end

    it 'returns nil when not found' do
      stub_read_901
      expect(described_class.find('901', client:)).to be_nil
    end
  end

  describe '.find!' do
    it 'returns an object when found' do
      stub_read_101
      expect(described_class.find!('101', client:)).to be_an_instance_of(ActiveAd::Facebook::User)
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

  describe '#businesses' do
    it 'returns a relation' do
      expect(user_101.businesses).to be_a_kind_of(ActiveAd::Relation)
    end

    it 'returns the objects when invoked' do
      stub_request(:get, "#{client.base_url}/#{user_101.id}/businesses")
        .with(query: hash_including(access_token: 'secret_access_token'))
        .to_return(status: 200, body: {
          data: [
            { id: '1', name: 'Business 1' },
            { id: '2', name: 'Business 2' }
          ],
          paging: { cursors: { before: '1' } }
        }.to_json)

      expect(user_101.businesses.map(&:name)).to include('Business 1', 'Business 2')
    end
  end
end
