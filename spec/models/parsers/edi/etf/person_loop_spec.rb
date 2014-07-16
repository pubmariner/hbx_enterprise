require_relative File.join("..", "..", "..", "..", "spec_helper")

describe Parsers::Edi::Etf::PersonLoop, "
given:
 - a member id
 - a relationship code
 - a benefit status
 - an employment status
 - a non-subscriber relationship code
" do
  include EdiFactory

  let(:the_member_id) { "the member id" }
  let(:the_relationship_code) { "the relationship code" }
  let(:the_benefit_status_code) { "the benefit status code" }
  let(:the_employment_status_code) { "the employment status code" }

  let(:l2000) {
    {
          "INS" => [0, nil, the_relationship_code, nil, nil, the_benefit_status_code, nil, nil, the_employment_status_code],
          "REFs" => [
            member_id_ref_segment(the_member_id)
          ] 
    }
  }

  subject { Parsers::Edi::Etf::PersonLoop.new(l2000)  }

  its(:member_id) { should eq(the_member_id) }
  its(:carrier_member_id) { should be_nil }
  its(:rel_code) { should eq(the_relationship_code) }
  its(:ben_stat) { should eq(the_benefit_status_code) }
  its(:emp_stat) { should eq(the_employment_status_code) }

  it { should_not be_subscriber }

end


describe Parsers::Edi::Etf::PersonLoop, "
given:
 - a carrier_member_id
 - a subscriber relationship code
 - no employment status, but an INS segment
" do
  include EdiFactory

  let(:carrier_member_id) { "the carrier member id" }

  let(:l2000) {
    {
          "INS" => [0, nil, "18", nil, nil],
          "REFs" => [
            carrier_member_id_ref_segment(carrier_member_id)
          ] 
    }
  }

  subject { Parsers::Edi::Etf::PersonLoop.new(l2000)  }

  its(:carrier_member_id) { should eq(carrier_member_id) }
  its(:emp_stat) { should be_nil }

  it { should be_subscriber }

  it "should NOT have a responsible party" do
    expect(subject).not_to be_responsible_party 
  end

end

describe Parsers::Edi::Etf::PersonLoop, "
given:
 - a responsible party
" do
  include EdiFactory


  let(:l2000) {
    {
          "INS" => [0, nil, "18", nil, nil],
          "REFs" => [
          ],
         "L2100G" => [1] 
    }
  }

  subject { Parsers::Edi::Etf::PersonLoop.new(l2000)  }

  it { should be_subscriber }

  it "should have a responsible party" do
    expect(subject).to be_responsible_party 
  end

end

describe Parsers::Edi::Etf::PersonLoop, "
given:
 - a custodial parent
" do
  include EdiFactory

  let(:l2000) {
    {
          "INS" => [0, nil, "18", nil, nil],
          "REFs" => [
          ],
         "L2100F" => [1] 
    }
  }

  subject { Parsers::Edi::Etf::PersonLoop.new(l2000)  }

  it "should have a responsible party" do
    expect(subject).to be_responsible_party 
  end
end


describe Parsers::Edi::Etf::PersonLoop do
  describe 'policy_loops' do
    let(:raw_policy_loop) { Hash.new }
    let(:raw_loop) { { "L2300s" => [raw_policy_loop, raw_policy_loop, raw_policy_loop] } }
    let(:person_loop) { Parsers::Edi::Etf::PersonLoop.new(raw_loop)}
    it 'returns a collection of policy loop instances' do
      expect(person_loop.policy_loops.count).to eq(raw_loop['L2300s'].count)
    end
  end

  describe '#street1' do
    it 'exposes the street first line' do
      street1 = 'something'
      raw_loop = { 'L2100A' => { "N3" => ['', street1, '', ''] } }
      person_loop = Parsers::Edi::Etf::PersonLoop.new(raw_loop)
      expect(person_loop.street1).to eq street1
    end
  end

  describe '#city' do
    it 'exposes the city' do
      city = 'Atlanta'
      raw_loop = { 'L2100A' => { 'N4' => ['', city, '', ''] } }
      person_loop = Parsers::Edi::Etf::PersonLoop.new(raw_loop)
      expect(person_loop.city).to eq city
    end
  end

  describe '#state' do
    it 'exposes the state' do
      state = 'AL'
      raw_loop = { 'L2100A' => { 'N4' => ['', '', state, ''] } }
      person_loop = Parsers::Edi::Etf::PersonLoop.new(raw_loop)
      expect(person_loop.state).to eq state
    end
  end

  describe '#cancellation_or_termination?' do
    let(:person_loop) { Parsers::Edi::Etf::PersonLoop.new(raw_loop) }
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
