module Proxies
  class InteractiveVerificationStart < ::Proxies::SoapRequestBuilder
    def service_location
      "/soa-infra/services/EnrollApp/EnrollAppRIDPFedSvc/enrollappridpfedsvc_client_ep"
    end
  end
end
