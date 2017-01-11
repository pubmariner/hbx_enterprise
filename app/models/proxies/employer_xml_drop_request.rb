module Proxies
  class EmployerXmlDropRequest < ::Proxies::SoapRequestBuilder
    def service_location
      "/soa-infra/services/EDI/GroupXMLV2CarrCmpService/groupxmlv2carrabcsimpl_client_ep"
    end
  end
end
