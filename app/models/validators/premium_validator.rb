module Validators

  class PremiumValidator
    def initialize(enrollment_group, plan, listener)
      @enrollment_group = enrollment_group
      @plan = plan
      @listener = listener
    end

    def validate
      valid = true
      enrollees = @enrollment_group.enrollees
      
      extractor = FreeEnrolleeExtractor.new(5)
      free_enrollees = extractor.extract_from!(enrollees)
      free_enrollees.each do |e|
        provided = e.premium_amount
        expected = 0
        if(provided != expected)
          @listener.enrollee_has_incorrect_premium({name: e.name, provided: provided, expected: expected})
          valid = false
        end
      end

      enrollees.each do |e|
        provided = e.premium_amount
        expected = @plan.premium_for_enrollee(e).amount.to_f.round(2)
        if(provided != expected)
          @listener.enrollee_has_incorrect_premium({name: e.name, provided: provided, expected: expected})
          valid = false
        end
      end

      return valid
    end

    # private 
    # def name(enrollee)
    #   enrollee.first_name + ' ' + enrollee.last_name
    # end
  end
end
