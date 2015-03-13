require "spec_helper"

describe Parsers::Xml::Cv::EnrolleeParser do
  let(:enrollment) {
    f = File.open(File.join(Padrino.root, "spec", "data", "parsers", "shop_enrollment.xml"))
    f.read
  }

  let(:begin_date) { "20150101" }
  let(:premium_amount) { "275.05" }
  let(:premium_amount1) { "247.43" }

  subject {
    Parsers::Xml::Cv::EnrollmentParser.parse(enrollment, :single => true)
  }

  let(:enrollee) { subject.policy.enrollees[0] }
  let(:enrollee1) { subject.policy.enrollees[1] }

  it 'should return member' do 
    expect(enrollee).to_not be_nil
    expect(enrollee.member).to be_a_kind_of(Parsers::Xml::Cv::IndividualParser)
    expect(enrollee).to_not be_nil
    expect(enrollee1.member).to be_a_kind_of(Parsers::Xml::Cv::IndividualParser)
  end

  it 'should have begin date and premium amount' do
    expect(enrollee.begin_date).to eq(begin_date)
    expect(enrollee.premium_amount).to eq(premium_amount)
    expect(enrollee1.begin_date).to eq(begin_date)
    expect(enrollee1.premium_amount).to eq(premium_amount1)
  end
end