module EffectiveDateChangers
  class Csv 
    def initialize(req, out_csv)
      @request = req
      @errors = []
      @csv = out_csv
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

    def no_changes_needed(details = {})
      @errors << "Policy #{details[:policy_id]} - no changes needed"
    end

    def fail(details = {})
      @csv << (@request.to_a + ["error", @errors.join])
    end

    def success
      @csv << (@request.to_a + ["success"])
    end
  end
end
