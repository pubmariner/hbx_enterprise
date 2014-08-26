module MemberAddressChangers
  class Csv 
    def initialize(req, out_csv)
      @request = req
      @errors = []
      @csv = out_csv
    end

    def no_such_member(details)
      @errors << "- Member #{details[:member_id]} does not exist\n"
    end

    def too_many_health_policies(details)
      @errors << "- has too many active health policies\n"
    end

    def too_many_dental_policies(details)
      @errors << "- has too many active dental policies\n"
    end

    def no_active_policies(details)
      @errors << "- no active policies\n"
    end

    def fail(details = {})
      @csv << (@request.to_a + ["error", @errors.join])
    end

    def success
      @csv << (@request.to_a + ["success"])
    end
  end
end
