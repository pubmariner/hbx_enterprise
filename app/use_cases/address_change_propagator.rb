class AddressChangePropagator

  def initialize(person, address_type)
    @person = person 
    @existing_address = current_address_of(person, address_type) # get persons address by type
    @policies = person.active_policies # get persons active_policies
    
    @affected_enrollee_map = @policies.inject({}) do |m, policy|
      if(policy.subscriber.person == @person)
        m[policy.id] = policy.active_enrollees.select do |enrollee|
          enrollee_address = current_address_of(enrollee.person, address_type)
          @existing_address.nil? ? enrollee_address.nil? : @existing_address.match(enrollee_address)
        end
      else
        m[policy.id] = policy.active_enrollees.select { |e| e.person == @person}
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
