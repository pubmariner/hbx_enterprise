require "spec_helper"
require 'nokogiri'

describe Parsers::Xml::Cv::BrokerAccountParser do

  let(:xml) {File.read("spec/data/app/controllers/employer_cv.xml")}
  let(:subject) {Parsers::Xml::Cv::BrokerAccountParser.parse(xml)}
  let(:doc) {Nokogiri::XML(xml)}

  it 'should do something' do
    expect(subject.first.start_on).to eq doc.xpath("//x:broker_account/x:start_on", "x"=>"http://openhbx.org/api/terms/1.0").text
    expect(subject.first.npn).to eq doc.xpath("//x:broker_account/x:writing_agent/x:npn", "x"=>"http://openhbx.org/api/terms/1.0").text
    expect(subject.first.end_on).to eq nil
  end

end