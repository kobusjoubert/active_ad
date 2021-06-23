require 'spec_helper'

RSpec.describe ActiveAd::Client do
  describe '#login' do
    it 'raises NotImplementedError' do
      expect{ described_class.new.login }.to raise_error(NotImplementedError)
    end
  end
end
