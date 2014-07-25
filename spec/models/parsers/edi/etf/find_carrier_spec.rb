# require './app/models/parsers/edi/etf/find_carrier'
require 'spec_helper'

describe Parsers::Edi::FindCarrier do
  context 'carrier doesn\'t exist' do 
    it 'notifies listener of carrier not found by fein' do
      listener = double
      find_carrier = Parsers::Edi::FindCarrier.new(listener, Parsers::Edi::ImportCache.new)

      expect(listener).to receive(:carrier_not_found)
      expect(find_carrier.by_fein('4321')).to be_nil
    end
  end

  context 'carrier exists' do
    it 'notifies listener of carrier found by fein' do
      carrier = Carrier.new
      carrier.carrier_profiles << CarrierProfile.new(fein: '1234')
      carrier.save!

      listener = double
      find_carrier = Parsers::Edi::FindCarrier.new(listener, Parsers::Edi::ImportCache.new)

      expect(listener).to receive(:carrier_found)
      expect(find_carrier.by_fein('1234')).to eq carrier
    end
  end
  
end
