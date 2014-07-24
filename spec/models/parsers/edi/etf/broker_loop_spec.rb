require 'spec_helper'
describe Parsers::Edi::Etf::BrokerLoop do
  let(:name) { 'SuperBroker' }
  let(:npn) { 'npn' }
  let(:raw_loop) {  { 'N1' => ['','', name, '', npn] } }
  let(:broker_loop) { Parsers::Edi::Etf::BrokerLoop.new(raw_loop) }

  it 'exposes broker name' do
    expect(broker_loop.name).to eq name
  end

  it 'exposes broker npn' do
    expect(broker_loop.npn).to eq npn
  end

  describe '#valid?' do
    context 'no npn' do
      let(:npn) { ' ' }
      it 'returns false' do
        expect(broker_loop.valid?).to eq false
      end
    end

    context 'npn present' do
      it 'returns true' do
        expect(broker_loop.valid?).to eq true
      end
    end

    context 'loop is blank' do
      let(:raw_loop) { Hash.new }
      it 'returns false' do
        expect(broker_loop.valid?).to eq false
      end
    end
  end


end
