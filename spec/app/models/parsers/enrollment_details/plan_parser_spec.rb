require 'spec_helper'

shared_examples "an aptc plan" do
    it "should have the right amount of applied_aptc" do
       expect(subject.applied_aptc).to eql(applied_aptc)
    end

    it "should have the right total_responsible_amount" do
      expect(subject.total_responsible_amount).to eql(tot_res_amount)
    end
end

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
      expect(subject.person_premiums(idMapping)).to eql(person_premiums)
    end

    it "should have the right ehb_percent" do
      expect(subject.ehb_percent).to eql(ehb_percent)
    end

    it "should have the right carrier name" do
      expect(subject.carrier_display_name).to eql(carrier_display_name)
    end

    it "should have the right carrier active" do
      expect(subject.carrier_active).to eql(carrier_active)
    end

    it "should have the right metal level" do
      expect(subject.metal_level).to eql(metal_level)
    end

    it "should have the right metal level" do
      expect(subject.plan_year).to eql(plan_year)
    end

    it "should have the carrier id" do
      expect(subject.carrier_id).to eql(carrier_id)
    end

  it "should assign enrollees" do

    allow(enrollee1).to receive(:premium_amount=)
    allow(enrollee2).to receive(:premium_amount=)

    subject.assign_enrollees(enrollees, idMapping)

    expect(subject.enrollees.first).to eql(enrollee1)
    expect(subject.enrollees.last).to eql(enrollee2)

  end

end

describe Parsers::EnrollmentDetails::PlanParser do
    let(:elected_aptc) {
      0.00
    }

    let(:applied_aptc) { 0.00 }

    let(:plan) {
      f = File.open(File.join(HbxEnterprise::App.root, "..", "spec", "data", "parsers", "enrollment_details", "#{file_name}_plan.xml"))
      Nokogiri::XML(f).root
    }

    let(:idMapping) {
      {"247857" => "114419", "248017" => "114"}
    }


    let(:enrollee1){
      double(:hbx_id => "114419", :person_id => "247857")
    }

    let(:enrollee2){
      double(:hbx_id => "114", :person_id => "248017")
    }

    let(:enrollees){
      [enrollee1, enrollee2]
    }


    subject {
      Parsers::EnrollmentDetails::PlanParser.new(plan, elected_aptc)
    }

  describe "given a health plan with more than the ehb-allowed aptc" do
    let(:file_name) { "health" }
    let(:elected_aptc) { 20000.00 }
    let(:applied_aptc) { 261.08 }
    let(:tot_res_amount) { 1.52 }

    it_should_behave_like "an aptc plan"

  end

  describe "given a health plan with exactly the max ehb-allowed aptc" do
    let(:file_name) { "health" }
    let(:elected_aptc) { 261.08 }
    let(:applied_aptc) { 261.08 }
    let(:tot_res_amount) { 1.52 }

    it_should_behave_like "an aptc plan"

  end

  describe "given a health plan with less than max aptc elected" do
    let(:file_name) { "health" }
    let(:elected_aptc) { 100.00 }
    let(:applied_aptc) { 100.00 }
    let(:tot_res_amount) { 162.60 }

    it_should_behave_like "an aptc plan"
  end


  describe "given a dental plan with aptc" do
    let(:file_name) { "dental" }
    let(:elected_aptc) { 5.00 }
    let(:applied_aptc) { 0.00 }

    let(:tot_res_amount) { 30.83 }

    it_should_behave_like "an aptc plan"
  end

  describe "given a dental plan" do
    let(:file_name) { "dental" }
    let(:plan_name) { "Select Plan" }
    let(:hios_id) { "92479DC0010002" }
    let(:premium_total) { 30.83 }
    #let(:person_premiums) {
    #  {"247857"=>"14.19", "248017"=>"16.64"}
    #}
    let(:person_premiums) {
      {"114419"=>"14.19", "114"=>"16.64"}
    }
    let(:ehb_percent) { 71.5 }
    let(:carrier_display_name) {"Dominion Dental Services Inc"}
    let(:carrier_active) { true }
    let(:coverage_type) {"urn:openhbx:terms:v1:benefit_coverage#dental"}
    let(:metal_level) {"urn:openhbx:terms:v1:plan_metal_level#dental"}
    let(:plan_year) {"2014"}
    let(:carrier_id) {"4c5e9365-7ff9-48dc-b979-2e2022ad9278"}



    it_should_behave_like "a plan parser"

    it "should be a dental plan" do
      expect(subject).to be_dental
    end
  end

  describe "given a health plan" do
    let(:file_name) { "health" }
    let(:plan_name) { "BlueChoice HSA Bronze $6,000" }
    let(:hios_id) { "86052DC0410002-01" }
    let(:premium_total) { 262.60 }
    #let(:person_premiums) {
    #{
    #    "247857" => "129.68",
    #    "248017" => "132.92"
    #  }
    #}

    let(:person_premiums) {
      {"114419"=>"129.68", "114"=>"132.92"}
    }

    let(:ehb_percent) { 99.42 }
    let(:carrier_display_name) {"Nice Insurance"}
    let(:carrier_active) {true}
    let(:coverage_type) {"urn:openhbx:terms:v1:benefit_coverage#health"}
    let(:metal_level) {"urn:openhbx:terms:v1:plan_metal_level#bronze"}
    let(:plan_year) {"2014"}
    let(:carrier_id) {"4c5e9365-7ff9-48dc-b979-2e2022ad9278"}

    it_should_behave_like "a plan parser"

    it "should not be a dental plan" do
      expect(subject).not_to be_dental
    end
  end
end


