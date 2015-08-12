module Proxies
  class ResidencyVerification < ::Proxies::SoapRequestBuilder
    def service_location
      "/soa-infra/services/POC/EnrollAppLocalHubVerificationCmpService/enrollapplocalhubverificationbpelprocess_client_ep"
    end
  end
end
