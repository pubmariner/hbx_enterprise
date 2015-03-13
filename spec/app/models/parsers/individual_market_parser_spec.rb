require "spec_helper"

describe Parsers::Xml::Cv::ShopMarketParser do
  let(:enrollment) {
    f = File.open(File.join(Padrino.root, "spec", "data", "parsers", "individual_enrollment.xml"))
    f.read
  }

  subject {
    Parsers::Xml::Cv::EnrollmentParser.parse(enrollment, :single => true)
  }

  let(:is_carrier_to_bill) { true }
  let(:applied_aptc_amount) { "54.98" }

  let(:market) { subject.policy.hbx_enrollment.individual_market }

  it 'should return aptc amount' do
    expect(market.is_carrier_to_bill).to eq(is_carrier_to_bill)
    expect(market.applied_aptc_amount).to eq(applied_aptc_amount)
  end
end