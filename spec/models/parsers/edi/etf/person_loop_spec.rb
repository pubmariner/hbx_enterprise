require 'spec_helper'

describe Parsers::Edi::Etf::PersonLoop do
  subject(:person_loop) { Parsers::Edi::Etf::PersonLoop.new(raw_loop) }

  let(:raw_loop) do
    {
      'L2100A' => { 
        "N3" => ['', street1, street2, ''],
        'N4' => ['', city, state, zip],
        'NM1' => ['', '', '', name_last, name_first, name_middle, name_prefix, name_suffix]
      },
      'REFs' => [['', '17', member_id ]]
    }
  end

  let(:street1) { 'something' }
  let(:street2) { 'something' }
  let(:city) { 'Atlanta' }
  let(:state) { 'GA' }
  let(:zip) { '20002' }
  let(:member_id) { '666'}
  let(:name_prefix) { 'Mrs' }
  let(:name_first) { 'Jane' }
  let(:name_middle) { 'X' }
  let(:name_last) { 'Doe' }
  let(:name_suffix) { 'Jr' }

  describe 'policy_loops' do
    let(:raw_policy_loop) { Hash.new }
    let(:raw_loop) { { "L2300s" => [raw_policy_loop, raw_policy_loop, raw_policy_loop] } }
    let(:person_loop) { Parsers::Edi::Etf::PersonLoop.new(raw_loop)}
    it 'returns a collection of policy loop instances' do
      expect(person_loop.policy_loops.count).to eq(raw_loop['L2300s'].count)
    end
  end

  it 'exposes first street line' do
    expect(person_loop.street1).to eq street1
  end

  it 'exposes second street line' do
    expect(person_loop.street2).to eq street2
  end

  it 'exposes city' do
    expect(person_loop.city).to eq city
  end

  it 'exposes state' do
    expect(person_loop.state).to eq state
  end

  it 'exposes zip code' do
    expect(person_loop.zip).to eq zip
  end

  it 'exposes member id' do
    expect(person_loop.member_id).to eq member_id
  end

  it 'exposes name prefix' do
    expect(person_loop.name_prefix).to eq name_prefix
  end

  it 'exposes first name' do
    expect(person_loop.name_first).to eq name_first
  end

  it 'exposes middle name' do
    expect(person_loop.name_middle).to eq name_middle
  end

  it 'exposes last name' do
    expect(person_loop.name_last).to eq name_last
  end

  it 'exposes name suffix' do
    expect(person_loop.name_suffix).to eq name_suffix
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
