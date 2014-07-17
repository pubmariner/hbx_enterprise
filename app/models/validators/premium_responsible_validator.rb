module Validators
  class PremiumResponsibleValidator
    def initialize(enrollment_group, listener)
      @enrollment_group = enrollment_group
      @listener = listener
    end

    def validate
      provided = @enrollment_group.total_responsible_amount.round(2)
      expected = adjusted_amount.round(2)
      if(provided != expected)
        @listener.group_has_incorrect_responsible_amount({provided: provided, expected: expected})
        return false
      end
      true
    end

    private 

    def adjusted_amount
      @enrollment_group.premium_amount_total - @enrollment_group.credit
    end
  end
end
