require "spec_helper"

describe Proxies::EmployerXmlDropRequest do
  it "has the correct service location" do
    expect(subject.endpoint).to eq ExchangeInformation.employer_xml_drop_url
  end
end
