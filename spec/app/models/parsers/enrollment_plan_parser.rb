require "spec_helper"

describe Parsers::Xml::Cv::EnrollmentPlanParser do
  let(:enrollment) {
    f = File.open(File.join(Padrino.root, "spec", "data", "parsers", "shop_enrollment.xml"))
    f.read
  }

  subject {
    Parsers::Xml::Cv::EnrollmentParser.parse(enrollment, :single => true)
  }

  let(:hios_id) { "86052DC0440008-01" }
  let(:coverage_type) { "urn:openhbx:terms:v1:qhp_benefit_coverage#health" }
  let(:plan_year) { "2015" }
  let(:name) { "BlueChoice Advantage $1000" }
  let(:is_dental_only) { false }

  let(:plan) { subject.hbx_enrollment.plan }

  it 'should return plan elements' do
    expect(plan.id).to eq(hios_id)
    expect(plan.coverage_type).to eq(coverage_type)
    expect(plan.plan_year).to eq(plan_year)
    expect(plan.name).to eq(name)
    expect(plan.is_dental_only).to eq(is_dental_only)
  end
end