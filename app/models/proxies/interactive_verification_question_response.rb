module Proxies
  class InteractiveVerificationQuestionResponse < ::Proxies::SoapRequestBuilder
    def endpoint
      ExchangeInformation.ridp_url
    end
  end
end
