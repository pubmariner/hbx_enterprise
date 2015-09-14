module Proxies
  class ResidencyVerification < ::Proxies::SoapRequestBuilder
    def endpoint
      ExchangeInformation.residency_url
    end
  end
end
