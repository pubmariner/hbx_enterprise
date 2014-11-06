require 'spec_helper'

shared_examples "a plan parser" do
    it "should have the right name" do
      expect(subject.plan_name).to eql(plan_name)
    end
    it "should have the right hios_id" do
      expect(subject.hios_id).to eql(hios_id)
    end

    it "should have the right premium total" do
      expect(subject.premium_total).to eql(premium_total)
    end

    it "should have the right person premiums" do
      expect(subject.person_premiums).to eql(person_premiums)
    end
end

describe Parsers::EnrollmentDetails::PlanParser do
    let(:plan) {
      f = File.open(File.join(HbxEnterprise::App.root, "..", "spec", "data", "parsers", "enrollment_details", "#{file_name}_plan.xml"))
      Nokogiri::XML(f).root
    }

    subject {
      Parsers::EnrollmentDetails::PlanParser.new(plan)
    }

  describe "given a dental plan" do
    let(:file_name) { "dental" }
    let(:plan_name) { "Select Plan" }
    let(:hios_id) { "92479DC0010002" }
    let(:premium_total) { "30.83" }
    let(:person_premiums) {
      {"247857"=>"14.19", "248017"=>"16.64"}
    }

    it_should_behave_like "a plan parser"

    it "should be a dental plan" do
      expect(subject).to be_dental
    end
  end

  describe "given a health plan" do
    let(:file_name) { "health" }
    let(:plan_name) { "BlueChoice HSA Bronze $6,000" }
    let(:hios_id) { "86052DC0410002-01" }
    let(:premium_total) { "262.60" }
    let(:person_premiums) {
      {
        "247857" => "129.68",
        "248017" => "132.92"
      }
    }

    it_should_behave_like "a plan parser"

    it "should not be a dental plan" do
      expect(subject).not_to be_dental
    end
  end
end
