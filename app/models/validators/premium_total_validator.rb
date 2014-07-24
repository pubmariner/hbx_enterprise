module Validators

  class PremiumTotalValidator
    def initialize(change_request, listener)
      @change_request = change_request
      @listener = listener
    end

    def validate
      provided = @change_request.premium_amount_total.round(2)
      expected = @change_request.enrollee_premium_sum.round(2)

      if(provided != expected)
        @listener.group_has_incorrect_premium_total({provided: provided, expected: expected})
        return false
      end
      true
    end
  end
end
