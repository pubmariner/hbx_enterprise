class ChangeMemberAddress
  def initialize(transmitter, person_repo = Person, address_repo = Address)
    @person_repo = person_repo
    @address_repo = address_repo
    @transmitter = transmitter
  end

  def execute(request, listener)
    if !validate(request, listener)
      listener.fail
    else
      commit(request)
      listener.success
    end
  end

  def validate(request, listener)
    person = @person_repo.find_by_id(request[:person_id])

    failed = false
    if(person.nil?)
      listener.no_such_person({:person_id => request[:person_id]})
      return false
    end
    
    new_address = @address_repo.new(
      address_type: request[:type], 
      address_1: request[:address1], 
      address_2: request[:address2], 
      city: request[:city], 
      state: request[:state], 
      zip: request[:zip]
    )

    unless new_address.valid?
      listener.invalid_address(new_address.errors.to_hash)
      return false
    end

    active_policies = person.active_policies
    future_active_policies = person.future_active_policies

    if(active_policies.empty? && future_active_policies.empty?)
      listener.no_active_policies(member_id: request[:member_id])
      failed = true
    end

    policies = active_policies + future_active_policies

    if (count_policies_by_coverage_type(policies, 'health') > 1)
      listener.too_many_health_policies(member_id: request[:member_id])
      failed = true
    end

    if (count_policies_by_coverage_type(policies, 'dental') > 1)
      listener.too_many_dental_policies(member_id: request[:member_id])
      failed = true
    end


    policies.each do |ap|
      if ap.has_responsible_person?
        listener.responsible_party_on_policy(:policy_id => ap.id)
        failed = true
      end
    end

    !failed
  end

  def current_address_of(person, at_place)
    person.address_of(at_place)
  end

  def commit(request)
    new_address = @address_repo.new(
      address_type: request[:type], 
      address_1: request[:address1], 
      address_2: request[:address2], 
      city: request[:city], 
      state: request[:state], 
      zip: request[:zip]
    )

    person = @person_repo.find_by_id(request[:person_id])

    existing_address = current_address_of(person, request[:type])

    if new_address.match(existing_address)
      return
    end

=begin
    active_policies = person.active_policies
    future_active_policies = person.future_active_policies

    policies = active_policies + future_active_policies

    # rules for selecting affected enrollees per policy
    affected_enrollee_map = policies.inject({}) do |m, policy|
      m[policy.id] = policy.active_enrollees.select do |enrollee|
        enrollee_address = current_address_of(enrollee.person, request[:type])
        existing_address.nil? ? enrollee_address.nil? : existing_address.match(enrollee_address)
      end
      m
    end
    # efs = ChangedAddressAffectedPolicyEnumerator.new(policies, address_type, current_address)
    # efs.each_affected_policy do |policy, affected_enrollees, included_enrolees|

    # end
=end
    propagaterythingamabob = AddressChangePropagator.new(person, request[:type])

    propagaterythingamabob.each_affected_group do |policy, affected_enrollees, included_enrollees|
      people = affected_enrollees.map { |e| e.person }

      people.each do |person|
        person.update_address(Address.new(new_address.attributes))
      end

      # TODO: Operation/Reason constant cleanup
      transmit_request = {
        policy_id: policy.id,
        operation: 'change',
        reason: 'change_of_location',
        affected_enrollee_ids: affected_enrollees.map(&:m_id),
        include_enrollee_ids: included_enrollees.map(&:m_id),
        current_user: request[:current_user]
      }

      if(request[:transmit] && ['home', 'mailing'].include?(request[:type]))
        @transmitter.execute(transmit_request)
      end
    end
  end
  
  def count_policies_by_coverage_type(policies, type)
    count = 0
    policies.count do |policy|
      policy.plan.coverage_type == type
    end
  end
end
