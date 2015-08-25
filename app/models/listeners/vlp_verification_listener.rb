module Listeners
  class VlpVerificationListener < ::Listeners::RetriedVerificationCommonListener
    def get_service
      ::Proxies::VlpRequest.new
    end

    def service_failure_tag
      "lawful_presence.vlp_verification_response"
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.vlp_verification"
    end

    def response_key 
      "info.events.lawful_presence.vlp_verification_response"
    end

    def routing_key
      "info.events.lawful_presence.vlp_verification_request"
    end
  end
end
