module Listeners
  class ResidencyVerificationListener < ::Listeners::RetriedVerificationCommonListener
    def get_service
      ::Proxies::ResidencyVerification.new
    end

    def service_failure_tag
      "residency.verification_request"
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.residency_verification"
    end

    def response_key 
      "info.events.residency.verification_response"
    end

    def routing_key
      "info.events.residency.verification_request"
    end
  end
end
