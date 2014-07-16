require 'spec_helper'

describe Parsers::Edi::Etf::PersonLoop do
  subject(:person_loop) { Parsers::Edi::Etf::PersonLoop.new(raw_loop) }

  let(:raw_loop) do
    {
      'L2100A' => { 
        "N3" => ['', street1, street2, ''],
        'N4' => ['', city, state, '']
      }
    }
  end

  let(:street1) { 'something' }
  let(:street2) { 'something' }
  let(:city) { 'Atlanta' }
  let(:state) { 'GA' }

  describe 'policy_loops' do
    let(:raw_policy_loop) { Hash.new }
    let(:raw_loop) { { "L2300s" => [raw_policy_loop, raw_policy_loop, raw_policy_loop] } }
    let(:person_loop) { Parsers::Edi::Etf::PersonLoop.new(raw_loop)}
    it 'returns a collection of policy loop instances' do
      expect(person_loop.policy_loops.count).to eq(raw_loop['L2300s'].count)
    end
  end

  it 'exposes the first street line' do
    expect(person_loop.street1).to eq street1
  end

  it 'exposes the second street line' do
    expect(person_loop.street2).to eq street2
  end

  it 'exposes the city' do
    expect(person_loop.city).to eq city
  end

  it 'exposes the state' do
    expect(person_loop.state).to eq state
  end

  describe '#cancellation_or_termination?' do
    context 'given no member level detail(INS)' do
      let(:raw_loop) { { "INS" => [] } }
      it 'returns false' do 
        expect(person_loop.cancellation_or_termination?).to eq false
      end
    end

    context 'given member level detail stating cancellation or termination' do
      let(:raw_loop) { { "INS" => ['', '', '', '024'] } }
      it 'returns true' do 
        expect(person_loop.cancellation_or_termination?).to eq true
      end
    end

    context 'given some other maintainance type code' do
      let(:raw_loop) { { "INS" => ['', '', '', '666'] } }
      it 'returns false' do 
        expect(person_loop.cancellation_or_termination?).to eq false
      end
    end
  end
end
