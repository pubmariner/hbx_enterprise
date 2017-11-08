require "spec_helper"

describe Proxies::LegacyEmployerXmlDropRequest do
  it "has the correct service location" do
    expect(subject.endpoint).to eq ExchangeInformation.legacy_employer_xml_drop_url
  end
end
