module Proxies
  class SsaRequest < ::Proxies::SoapRequestBuilder
    def service_location
      "/EnrollAppSSAWebService/ProxyService/EnrollAppSSAFedPS"
    end
  end
end
