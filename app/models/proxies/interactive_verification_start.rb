module Proxies
  class InteractiveVerificationStart < ::Proxies::SoapRequestBuilder
    def endpoint
      ExchangeInformation.ridp_url
    end
  end
end
