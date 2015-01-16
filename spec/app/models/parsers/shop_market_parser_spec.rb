require "spec_helper"

describe Parsers::Xml::Cv::ShopMarketParser do
  let(:enrollment) {
    f = File.open(File.join(Padrino.root, "spec", "data", "parsers", "shop_enrollment.xml"))
    f.read
  }

  subject {
    Parsers::Xml::Cv::EnrollmentParser.parse(enrollment, :single => true)
  }

  let(:employer_fein) { "536002558" }
  let(:employer_name) { "Congress" }
  let(:employer_responsible_amount) { "577.43" }

  let(:market) { subject.policy.hbx_enrollment.shop_market }

  it 'should return employer details' do
    expect(market.employer_fein).to eq(employer_fein)
    expect(market.employer_name).to eq(employer_name)
    expect(market.employer_responsible_amount).to eq(employer_responsible_amount)
  end
end