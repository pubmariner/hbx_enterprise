require 'spec_helper'
require 'nokogiri'

describe "app/views/employers/legacy_v1.haml" do


  let(:employer_cv) { File.read("spec/data/app/controllers/cancelled_py_cv.xml") }
  let(:employer_cv2) { File.read("spec/data/app/controllers/employer_cv.xml") }


  describe "render template with canceled plan year cv" do

    let!(:cv_hash) { Parsers::Xml::Cv::OrganizationParser.parse(employer_cv).to_hash }
    let!(:plan_year) { HbxEnterprise::App.prototype.helpers.latest_plan_year(cv_hash[:employer_profile][:plan_years]) }
    let!(:rendered) { HbxEnterprise::App.prototype.helpers.partial("employers/legacy_v1", {:engine => :haml, :locals => {cv_hash: cv_hash, plan_year: plan_year, carrier: "CareFirst"}}) }
    let!(:doc) {Nokogiri::XML(rendered)}

    it "template plan year start date == end date " do
      expect(doc.to_s).to include("<ns1:plan_year_start>2015-02-01</ns1:plan_year_start>")
      expect(doc.to_s).to include("<ns1:plan_year_end>2015-02-01</ns1:plan_year_end>")
    end

    it "template exchange_status need to be inactive" do
      expect(doc.to_s).to include("<ns1:exchange_status>inactive</ns1:exchange_status>")
    end
  end

  describe "render template with active plan year cv" do

    let!(:cv_hash) { Parsers::Xml::Cv::OrganizationParser.parse(employer_cv2).to_hash }
    let!(:plan_year) { HbxEnterprise::App.prototype.helpers.latest_plan_year(cv_hash[:employer_profile][:plan_years]) }
    let!(:rendered) { HbxEnterprise::App.prototype.helpers.partial("employers/legacy_v1", {:engine => :haml, :locals => {cv_hash: cv_hash, plan_year: plan_year, carrier: "CareFirst"}}) }
    let!(:doc) {Nokogiri::XML(rendered)}

    it "template should have start date & end date " do
      expect(doc.to_s).to include("<ns1:plan_year_start>2015-02-01</ns1:plan_year_start>")
      expect(doc.to_s).to include("<ns1:plan_year_end>2016-01-31</ns1:plan_year_end>")
    end

    it "template exchange_status need to be active" do
      expect(doc.to_s).to include("<ns1:exchange_status>active</ns1:exchange_status>")
    end
  end
end
