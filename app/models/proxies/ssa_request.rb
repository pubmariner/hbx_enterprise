module Proxies
  class SsaRequest < ::Proxies::SoapRequestBuilder
    def endpoint
      ExchangeInformation.ssa_url
    end
  end
end
