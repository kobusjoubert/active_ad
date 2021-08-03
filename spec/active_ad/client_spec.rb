require 'spec_helper'

RSpec.describe ActiveAd::Client do
  describe '#login' do
    it 'raises NotImplementedError' do
      expect{ described_class.new.login }.to raise_error(NotImplementedError)
    end
  end

  describe '#refresh_token' do
    it 'raises NotImplementedError' do
      expect{ described_class.new.refresh_token }.to raise_error(NotImplementedError)
    end
  end
end
