module MemberAddressChangers
  class Console
    def initialize(req)
      @request = req
      @errors = []
    end

    def invalid_address(details = {})
      details.each_pair do |k, v|
        property_errors = Array(v)
        property_errors.each do |err|
          @errors << "Address invalid: #{k} #{err}"
        end
      end
    end

    def no_such_member(details = {})
      @errors << "Member #{details[:member_id]} does not exist"
    end

    def too_many_health_policies(details = {})
      @errors << "Member #{details[:member_id]} has too many active health policies"
    end

    def too_many_dental_policies(details = {})
      @errors << "Member #{details[:member_id]} has too many active dental policies"
    end

    def no_active_policies(details = {})
      @errors << "Member #{details[:member_id]} has no active policies"
    end

    def fail(details = {})
      @errors.each do |err|
        puts err
      end
    end

    def success
      puts "Member #{@request.member_id} address changed successfully!"
    end
  end
end
