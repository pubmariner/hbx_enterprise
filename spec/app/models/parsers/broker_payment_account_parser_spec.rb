require "spec_helper"
require 'nokogiri'

describe Parsers::Xml::Cv::BrokerPaymentAccountParser do

  let(:xml) {File.read("spec/data/app/controllers/broker_ach_cv.xml")}
  let(:subject) {Parsers::Xml::Cv::BrokerPaymentAccountParser.parse(xml)}
  let(:doc) {Nokogiri::XML(xml)}

  it 'should match broker ACH info' do
    expect(subject.first.account_active_on).to eq doc.xpath("//x:account_active_on", "x"=>"http://openhbx.org/api/terms/1.0").text
    expect(subject.first.account_number).to eq doc.xpath("//x:account_number", "x"=>"http://openhbx.org/api/terms/1.0").text
    expect(subject.first.routing_number).to eq doc.xpath("//x:routing_number", "x"=>"http://openhbx.org/api/terms/1.0").text
  end
end