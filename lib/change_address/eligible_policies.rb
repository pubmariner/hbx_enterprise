module ChangeAddress
  class EligiblePolicies
    include Enumerable
    def initialize(person)
      @person = person
      policies = Collections::Policies.new(person.policies)
      @policy_list = policies.is_or_will_be_active
      @health_policies = @policy_list.covering_health
      @dental_policies = @policy_list.covering_dental
      @too_many_health = too_many_policies?(@health_policies)
      @too_many_dental = too_many_policies?(@dental_policies)
      @eligible_policies = [@health_policies.most_recent, @dental_policies.most_recent].compact
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
      existing_address = current_address_of(@person, address_type)
      
      affected_enrollee_map = @eligible_policies.inject({}) do |m, policy|
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

    def empty?
      @eligible_policies.empty?
    end

    def too_many_policies?(pol)
      return false unless pol.many?
      pol.overlaps_policy(pol.most_recent).many?
    end

    def too_many_health_policies?
      @too_many_health
    end

    def too_many_dental_policies?
      @too_many_dental
    end

    def too_many_active_policies?
      too_many_health_policies? || too_many_dental_policies?
    end

  end
end
