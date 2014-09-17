module ChangeAddress
  class EligiblePolicies
    include Enumerable
    def initialize(person)
      @person = person
      @policy_list = person.policies.select { |pol| pol.currently_active? || pol.future_active? }
      @eligible_policies = categorize_policies(@policy_list).flat_map { |pg| most_recent_policies(pg) }
    end

    def self.for_person(person)
      self.new(person)
    end

    def each
      @eligible_policies.each do |pol|
        yield pol
      end
    end

    def each_affected_group(address_type)
      existing_address = current_address_of(@person, address_type) # get persons address by type
      policies = @eligible_policies # get persons active_policies
      
      affected_enrollee_map = policies.inject({}) do |m, policy|
        if(policy.subscriber.person == @person)
          m[policy.id] = policy.enrollees.select do |enrollee|
            enrollee_address = current_address_of(enrollee.person, address_type)
            (existing_address.nil? ? enrollee_address.nil? : existing_address.match(enrollee_address)) && !enrollee.canceled?
          end
        else
          m[policy.id] = policy.enrollees.select { |e| (e.person == @person) && !e.canceled?}
        end
        m
      end

      policies.each do |pol|
        yield pol, affected_enrollee_map[pol.id], (pol.enrollees.select { |e| !e.canceled?})
      end
    end

    def current_address_of(person, at_place)
      person.address_of(at_place)
    end

    def categorize_policies(pols)
      pols.partition { |pol| pol.coverage_type == "health" }
    end

    def most_recent_policies(pols)
      sorted = pols.sort_by { |pol| pol.policy_start }
      return sorted if sorted.length < 2
      most_recent = sorted.last
      sorted.select { |pol| policies_overlap?(most_recent, pol) }
    end

    def policies_overlap?(a, b)
      first, second = [a, b].sort_by { |pol| pol.policy_start }
      return true if first.policy_end.nil?
      (first.policy_end > second.policy_start)
    end

    def empty?
      @eligible_policies.empty?
    end

    def too_many_health_policies?
      categorize_policies(@eligible_policies).first.many?
    end

    def too_many_dental_policies?
      categorize_policies(@eligible_policies).last.many?
    end

    def too_many_active_policies?
      categorize_policies(@eligible_policies).any? { |pol_group| pol_group.length > 1}
    end

  end
end
