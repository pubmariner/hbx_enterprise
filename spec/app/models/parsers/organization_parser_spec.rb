require "spec_helper"

describe Parsers::Xml::Cv::OrganizationParser do

  let(:xml) {File.read("spec/data/parsers/organization.xml")}
  let(:subject) {Parsers::Xml::Cv::OrganizationParser.parse(xml)}
  it 'should do something' do

      puts subject.to_hash
  end
end