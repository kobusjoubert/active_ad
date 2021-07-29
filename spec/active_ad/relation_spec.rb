require 'spec_helper'

RSpec.describe ActiveAd::Relation do
  let(:klass)        { OpenStruct.new(client: OpenStruct.new(pagination_type: nil)) }
  let(:relationable) { described_class.new(klass) }

  describe '.where' do
    it 'sets kwargs primitive values' do
      expect(relationable.where(key: 'value').kwargs).to eq(key: 'value')
    end

    it 'resets kwargs primitive values' do
      relationable_1 = relationable.where(key: 'value')
      expect(relationable_1.where(key: 'new_value').kwargs).to eq(key: 'new_value')
    end

    it 'appends to kwargs array values' do
      relationable_1 = relationable.where(key: ['value'])
      expect(relationable_1.where(key: ['another_value']).kwargs).to eq(key: ['value', 'another_value'])
    end

    it 'does not mutate previous relationable objects' do
      relationable_1 = relationable.where(key: 'value_1')
      relationable_2 = relationable_1.where(key: 'value_2')
      expect(relationable_1.kwargs).not_to eq(relationable_2.kwargs)
    end
  end

  describe '.rewhere' do
    it 'resets kwargs primitive values' do
      relationable_1 = relationable.where(key: 'value')
      expect(relationable_1.rewhere(key: 'new_value').kwargs).to eq(key: 'new_value')
    end

    it 'resets kwargs array values' do
      relationable_1 = relationable.where(key: ['value'])
      expect(relationable_1.rewhere(key: ['another_value']).kwargs).to eq(key: ['another_value'])
    end

    it 'does not mutate previous relationable objects' do
      relationable_1 = relationable.where(key: 'value_1')
      relationable_2 = relationable_1.rewhere(key: 'value_2')
      expect(relationable_1.kwargs).not_to eq(relationable_2.kwargs)
    end
  end

  describe '.limit' do
    it 'sets limit_value' do
      expect(relationable.limit(10).limit_value).to eq(10)
    end

    it 'resets limit_value' do
      expect(relationable.limit(10).limit(20).limit_value).to eq(20)
    end

    it 'does not mutate a previous relationable objects' do
      relationable_1 = relationable.limit(10)
      relationable_2 = relationable_1.limit(20)
      expect(relationable_1.limit_value).not_to eq(relationable_2.limit_value)
    end
  end

  describe '.offset' do
    it 'sets offset_value' do
      expect(relationable.offset(20).offset_value).to eq(20)
    end

    it 'resets offset_value' do
      expect(relationable.offset(20).offset(30).offset_value).to eq(30)
    end

    it 'does not mutate previous relationable objects' do
      relationable_1 = relationable.offset(10)
      relationable_2 = relationable_1.offset(20)
      expect(relationable_1.offset_value).not_to eq(relationable_2.offset_value)
    end
  end
end
