module Proxies
  class InteractiveVerificationOverride < ::Proxies::SoapRequestBuilder
    def endpoint
      ExchangeInformation.fars_url
    end
  end
end
