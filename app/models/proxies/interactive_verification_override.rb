module Proxies
  class InteractiveVerificationOverride < ::Proxies::SoapRequestBuilder
    def service_location
      "/EnrollAppRIDPFarscmpService/BusinessService/EnrollAppRIDPFarscmpPS"
    end
  end
end
