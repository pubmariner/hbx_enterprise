module MemberAddressChangers
  class Console
    def initialize(m_id)
      @member_id = m_id
      @errors = []
    end

    def no_such_member(details)
      @errors << "Member #{details[:member_id]} does not exist"
    end

    def too_many_health_policies(details)
      @errors << "Member #{details[:member_id]} has too many active health policies"
    end

    def too_many_dental_policies(details)
      @errors << "Member #{details[:member_id]} has too many active dental policies"
    end

    def no_active_policies(details)
      @errors << "Member #{details[:member_id]} has no active policies"
    end

    def fail(details = {})
      @errors.each do |err|
        puts err
      end
    end

    def success
      puts "Member #{@member_id} address changed successfully!"
    end
  end
end
