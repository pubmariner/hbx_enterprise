module Proxies
  class InteractiveVerificationStart < ::Proxies::SoapRequestBuilder
    def service_location
      "/EnrollApp/RIDP/ProxyService/EnrollAppFedRIDPPS"
    end
  end
end
