require "spec_helper"

describe Parsers::Xml::Cv::HbxEnrollmentParser do
  let(:enrollment) {
    f = File.open(File.join(Padrino.root, "spec", "data", "parsers", "shop_enrollment.xml"))
    f.read
  }

  let(:premium_total_amount) { "769.91" }
  let(:total_responsible_amount) { "192.48" }

  subject {
    Parsers::Xml::Cv::EnrollmentParser.parse(enrollment, :single => true)
  }

  let(:hbx_enrollment) { subject.policy.hbx_enrollment }

  it 'should have a plan and shop_market' do
    expect(hbx_enrollment.plan).to be_a_kind_of(Parsers::Xml::Cv::EnrollmentPlanParser)
    expect(hbx_enrollment.shop_market).to be_a_kind_of(Parsers::Xml::Cv::ShopMarketParser)
    expect(hbx_enrollment.individual_market).to be_nil
  end

  it 'should return premium total and responsible amounts' do
    expect(hbx_enrollment.premium_total_amount).to eq(premium_total_amount)
    expect(hbx_enrollment.total_responsible_amount).to eq(total_responsible_amount)
  end
end