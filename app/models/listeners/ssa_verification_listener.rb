module Listeners
  class SsaVerificationListener < ::Listeners::RetriedVerificationCommonListener
    def get_service
      ::Proxies::SsaRequest.new
    end

    def service_failure_tag
      "lawful_presence.ssa_verification_response"
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.ssa_verification"
    end

    def response_key 
      "info.events.lawful_presence.ssa_verification_response"
    end

    def routing_key
      "info.events.lawful_presence.ssa_verification_request"
    end
  end
end
