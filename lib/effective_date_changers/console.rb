module EffectiveDateChangers
  class Console
    def initialize(req)
      @request = req
      @errors = []
    end

    def no_such_policy(details = {})
      @errors << "Policy #{details[:policy_id]} does not exist"
    end

    def policy_inactive(details = {})
      @errors << "Policy #{details[:policy_id]} is not active"
    end

    def ambiguous_terminations(details = {})
      @errors << "Policy #{details[:policy_id]} is ambiguous"
    end

    def start_date_mismatch(details = {})
      @errors << "Policy #{details[:policy_id]} has a start date mismatch"
    end

    def fail(details = {})
      @errors.each do |err|
        puts err
      end
    end

    def success
      puts "Policy #{@request.policy_id} effective dates changed successfully!"
    end
  end
end
