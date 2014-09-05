class AddressChangePropagator

  def initialize(person, address_type)
    @person = person
    @existing_address = current_address_of(person, address_type)
    @policies = person.active_policies
    @affected_enrollee_map = @policies.inject({}) do |m, policy|
      m[policy.id] = policy.active_enrollees.select do |enrollee|
        enrollee_address = current_address_of(enrollee.person, request[:type])
        existing_address.nil? ? enrollee_address.nil? : @existing_address.match(enrollee_address)
      end
      m
    end
  end

  def current_address_of(person, at_place)
    person.address_of(at_place)
  end

  def each_affected_group
    @policies.each do |pol|
      yield pol, affected_enrollees_for(pol.id), pol.active_enrollees
    end
  end

  protected

  def affected_enrollees_for(p_id)
    @affected_enrollee_map[p_id]
  end

end