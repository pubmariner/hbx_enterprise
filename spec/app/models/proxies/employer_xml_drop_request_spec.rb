require "spec_helper"

describe Proxies::EmployerXmlDropRequest do
  it "has the correct service location" do
    expect(subject.service_location).to eq "/soa-infra/services/EDI/GroupXMLV2CarrCmpService/groupxmlv2carrabcsimpl_client_ep"
  end
end
