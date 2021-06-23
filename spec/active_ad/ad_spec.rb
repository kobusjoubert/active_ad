require 'spec_helper'

RSpec.describe ActiveAd::Ad do
  describe '.find' do
    it 'raises NotImplementedError' do
      expect{ described_class.find('1') }.to raise_error(NotImplementedError)
    end
  end

  describe '.find!' do
    it 'raises NotImplementedError' do
      expect{ described_class.find!('1') }.to raise_error(NotImplementedError)
    end
  end

  describe '.create' do
    it 'raises NotImplementedError' do
      expect{ described_class.create(validate: false) }.to raise_error(NotImplementedError)
    end
  end

  describe '.create!' do
    it 'raises NotImplementedError' do
      expect{ described_class.create!(validate: false) }.to raise_error(NotImplementedError)
    end
  end

  describe '#save' do
    it 'raises NotImplementedError' do
      expect{ described_class.new.save(validate: false) }.to raise_error(NotImplementedError)
    end
  end

  describe '#save!' do
    it 'raises NotImplementedError' do
      expect{ described_class.new.save!(validate: false) }.to raise_error(NotImplementedError)
    end
  end

  describe '#update' do
    it 'raises NotImplementedError' do
      expect{ described_class.new.update(validate: false) }.to raise_error(NotImplementedError)
    end
  end

  describe '#update!' do
    it 'raises NotImplementedError' do
      expect{ described_class.new.update!(validate: false) }.to raise_error(NotImplementedError)
    end
  end

  describe '#destroy' do
    it 'raises NotImplementedError' do
      expect{ described_class.new.destroy }.to raise_error(NotImplementedError)
    end
  end

  describe '#destroy!' do
    it 'raises NotImplementedError' do
      expect{ described_class.new.destroy! }.to raise_error(NotImplementedError)
    end
  end
end
