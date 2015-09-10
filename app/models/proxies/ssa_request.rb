module Proxies
  class SsaRequest < ::Proxies::SoapRequestBuilder
    def service_location
      "/EnrollApp/SSA/ProxyService/EnrollAppSSAFedPS"
    end
  end
end
