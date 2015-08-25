module Proxies
  class VlpRequest < ::Proxies::SoapRequestBuilder
    def service_location
      "/EnrollApp/VLP/ProxyService/EnrollAppFedVLPPS"
    end
  end
end
