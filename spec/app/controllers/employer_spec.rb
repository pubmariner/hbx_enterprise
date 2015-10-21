require 'spec_helper'
require 'nokogiri'

describe "controllers/broker" do

  let(:xsd_path) { '/Users/CitadelFirm/Downloads/Employer-2.xsd' }
  let(:doc_path) { '/Users/CitadelFirm/Downloads/employer-sample.xml' }
  let(:employer_cv) { File.read("spec/data/app/controllers/employer_cv.xml") }
  let(:employer_hash) { Parsers::Xml::Cv::EmployerProfileParser.parse(employer_cv).to_hash }

  describe "/employers/legacy_xml" do
    it "creates a employer legacy xml" do
      post('/employers/legacy_xml', employer_cv)

      xsd = Nokogiri::XML::Schema(File.open(xsd_path))
      doc = Nokogiri::XML(last_response.body)
      expect(xsd.validate(doc).length).to eq(0)
    end
  end
end