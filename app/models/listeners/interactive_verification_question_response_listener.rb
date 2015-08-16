require 'json'

module Listeners
  class InteractiveVerificationQuestionResponseListener < ::Listeners::InteractiveVerificationCommonListener
    def get_service
      ::Proxies::InteractiveVerificationQuestionResponse.new
    end

    def service_failure_tag
      "interactive_verification_question_response"
    end

    def self.queue_name
      ec = ExchangeInformation
      "#{ec.hbx_id}.#{ec.environment}.q.hbx_enterprise.interactive_verification_question_response"
    end
  end
end
