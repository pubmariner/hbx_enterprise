require 'spec_helper' #needed for '.blank?'
#'./app/models/parsers/edi/etf/person_parser'

describe Parsers::Edi::Etf::PersonParser do
  subject(:parser) { Parsers::Edi::Etf::PersonParser.new(l2000) }

  let(:l2000) do
    {
      'L2100A' => { 
        "N3" => ['', street1, street2, ''],
        'N4' => ['', city, state, zip]
      } 
    }
  end
  let(:street2) { 'something' }
  let(:street1) { 'something' }
  let(:city) { 'Atlanta' }
  let(:state) { 'GA' }
  let(:zip) { '20002' }

  describe '#get_street2' do
    context 'present' do
      let(:street2) { 'something' }

      its 'street2 is set' do
        street2 = 'something'
        expect(parser.get_street2).to eq street2
      end
    end

    context 'absent' do
      let(:street2) { ' ' }

      its 'street2 is nil' do
        expect(parser.get_street2).to eq nil
      end
    end
  end

  describe '#get_street1' do
    it 'returns the street first line' do
      expect(parser.get_street1).to eq street1
    end
  end

  describe '#get_city' do
    it 'returns the city' do
      expect(parser.get_city).to eq city
    end
  end

  describe '#get_state' do
    it 'returns the state' do
      expect(parser.get_state).to eq state
    end
  end

  describe '#get_zip' do
    it 'returns the zip' do
      expect(parser.get_zip).to eq zip
    end
  end
end
