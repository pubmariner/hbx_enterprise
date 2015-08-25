module Proxies
  class ResidencyVerification < ::Proxies::SoapRequestBuilder
    def service_location
      "/LocalHub/VerificationService"
    end
  end
end
