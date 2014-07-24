
module Validators

  class CancelTermPremiumTotalValidator
    def initialize(change_request, listener)
      @change_request = change_request
      @listener = listener
    end

    def validate
      provided = @change_request.premium_amount_total.round(2)
      expected = expected_total
      if(provided != expected)
        @listener.group_has_incorrect_premium_total({provided: provided, expected: expected})
        return false
      end
      true
    end

    def expected_total
      amount = @change_request.enrollee_premium_sum.round(2)
      unless @change_request.subscriber_affected?
        amount = amount - @change_request.affected_enrollees_sum
      end
      amount
    end
  end
end
