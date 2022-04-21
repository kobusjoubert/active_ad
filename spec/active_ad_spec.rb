RSpec.describe ActiveAd do
  it 'has a version number' do
    expect(ActiveAd::VERSION).not_to be_nil
  end

  describe '.env' do
    it 'does not set the default environment to development' do
      expect(described_class.env.development?).to be(false)
    end
  end
end
