module Proxies
  class EmployerXmlDropRequest < ::Proxies::SoapRequestBuilder
    def endpoint
      ExchangeInformation.employer_xml_drop_url
    end
  end
end
