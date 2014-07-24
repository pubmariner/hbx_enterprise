module Validators
  class PremiumResponsibleValidator
    def initialize(change_request, listener)
      @change_request = change_request
      @listener = listener
    end

    def validate
      provided = @change_request.total_responsible_amount.round(2)
      expected = adjusted_amount.round(2)
      if(provided != expected)
        @listener.group_has_incorrect_responsible_amount({provided: provided, expected: expected})
        return false
      end
      true
    end

    private 

    def adjusted_amount
      @change_request.premium_amount_total - @change_request.credit
    end
  end
end
