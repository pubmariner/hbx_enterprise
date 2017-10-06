require "spec_helper"

describe Parsers::Xml::Cv::BrokerRolesParser do

  let(:xml) {File.read("spec/data/app/controllers/broker_ach_cv.xml")}
  let(:xml1) {File.read("spec/data/app/controllers/broker_cv.xml")}

  let(:subject) {Parsers::Xml::Cv::BrokerRolesParser.parse(xml, :single => true)}
  let(:subject1) {Parsers::Xml::Cv::BrokerRolesParser.parse(xml1, :single => true)}

  it 'should include broker ACH info' do
    expect(subject.broker_payment_account).to_not be_nil
    expect(subject.broker_payment_account).to be_a_kind_of(Parsers::Xml::Cv::BrokerPaymentAccountParser)
  end

  it 'should not include broker ACH info' do
    expect(subject1.broker_payment_account).to be_nil
  end
end