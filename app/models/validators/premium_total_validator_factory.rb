module Validators
  class PremiumTotalValidatorFactory
    def self.create_for(change_request, listener)
      case(change_request.type)
      when 'cancel'
        Validators::CancelTermPremiumTotalValidator.new(change_request, listener)
      when 'terminate'
        Validators::CancelTermPremiumTotalValidator.new(change_request, listener)
      else
        Validators::PremiumTotalValidator.new(change_request, listener)
      end
    end
  end
end
