require 'spec_helper'

describe "controllers/broker" do

  let(:broker_cv) { File.read("spec/data/app/controllers/broker_cv.xml") }
  let(:broker_hash) { Parsers::Xml::Cv::IndividualParser.parse(broker_cv).to_hash }

  describe "/brokers/legacy_xml" do
    it "creates a broker cv" do
      post('/brokers/legacy_xml', broker_cv)
      expect(last_response.body).to include("<npn>1212127</npn>")
      expect(last_response.body).to include("<license_number>1212124</license_number>")
      expect(last_response.body).to include("<exchange_id>1212127</exchange_id>")
      expect(last_response.body).to include("<xc:street>609 H St, NE</xc:street>")
      expect(last_response.body).to include("<xc:uri>1876665434</xc:uri>")
      expect(last_response.body).to include("<xc:text>dude@dc.gov</xc:text>")
    end
  end
end