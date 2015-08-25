require 'json'

module Listeners
  class InteractiveVerificationOverrideListener < ::Listeners::InteractiveVerificationCommonListener
    def service_failure_tag
      "interactive_verification_override"
    end

    def get_service
      ::Proxies::InteractiveVerificationOverride.new
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.interactive_verification_override"
    end
  end
end
