require 'json'

module Listeners
  class InteractiveVerificationStartListener < ::Listeners::InteractiveVerificationCommonListener
    def service_failure_tag
      "interactive_verification_start"
    end

    def get_service
      ::Proxies::InteractiveVerificationStart.new
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.interactive_verification_start"
    end
  end
end
