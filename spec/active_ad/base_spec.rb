require 'spec_helper'

RSpec.describe ActiveAd::Base do
  describe '.find' do
    it 'returns nil when no id provided' do
      expect(described_class.find(nil)).to be_nil
    end

    it 'returns nil when no client provided' do
      expect(described_class.find('1')).to be_nil
    end

    it 'raises NotImplementedError' do
      expect{ described_class.find('1', client: '') }.to raise_error(NotImplementedError)
    end
  end

  describe '.find!' do
    it 'raises ArgumentError when no id provided' do
      expect { described_class.find!(nil) }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError when no client provided' do
      expect { described_class.find!('1') }.to raise_error(ArgumentError)
    end

    it 'raises NotImplementedError' do
      expect { described_class.find!('1', client: '') }.to raise_error(NotImplementedError)
    end
  end

  describe '.create' do
    it 'raises NotImplementedError' do
      expect { described_class.create(validate: false) }.to raise_error(NotImplementedError)
    end
  end

  describe '.create!' do
    it 'raises NotImplementedError' do
      expect { described_class.create!(validate: false) }.to raise_error(NotImplementedError)
    end
  end

  describe '#save' do
    it 'raises NotImplementedError' do
      expect { described_class.new.save(validate: false) }.to raise_error(NotImplementedError)
    end
  end

  describe '#save!' do
    it 'raises NotImplementedError' do
      expect { described_class.new.save!(validate: false) }.to raise_error(NotImplementedError)
    end
  end

  describe '#update' do
    it 'raises NotImplementedError' do
      expect { described_class.new.update(validate: false) }.to raise_error(NotImplementedError)
    end
  end

  describe '#update!' do
    it 'raises NotImplementedError' do
      expect { described_class.new.update!(validate: false) }.to raise_error(NotImplementedError)
    end
  end

  describe '#destroy' do
    it 'raises NotImplementedError' do
      expect { described_class.new.destroy }.to raise_error(NotImplementedError)
    end
  end

  describe '#destroy!' do
    it 'raises NotImplementedError' do
      expect { described_class.new.destroy! }.to raise_error(NotImplementedError)
    end
  end
end
