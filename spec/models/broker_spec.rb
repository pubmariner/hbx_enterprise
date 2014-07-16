require 'spec_helper'

describe Broker do
  describe '.find_or_create' do
    it 'finds an existing broker by broker' do
      exisiting_broker = create :broker
      broker = Broker.new(exisiting_broker.attributes)
      expect(Broker.find_or_create(broker)).to eq exisiting_broker
    end

    it 'creates new broker if existing broker is not found' do
      new_broker = build :broker
      expect(Broker.find_or_create(new_broker)).to eq new_broker 
    end
  end
end
