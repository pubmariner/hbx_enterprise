module Proxies
  class VlpRequest < ::Proxies::SoapRequestBuilder
    def endpoint
      ExchangeInformation.vlp_url
    end
  end
end
