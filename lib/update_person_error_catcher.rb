class UpdatePersonErrorCatcher
  def initialize(person)
    @person = person
    @current_address = 0
  end

  def home_address_not_present
    @person.errors << "Home addresses is required."
  end

  def set_current_address(idx)
    @current_address = idx
  end

  def too_many_addresses_of_type(details)
    @person.errors << "Too many #{details[:address_type]} addresses. Only #{details[:max]} allowed."
  end

  def no_such_person(details)
    @person.errors << "No such person (id: #{details[:person_id]}"
  end

  def invalid_address(errors)
    errors.each_pair do |k, v|
      err_list = Array(v)
      err_list.each do |err|
        @person.addresses[@current_address].errors.add(k, err)
      end
    end
  end

  def no_active_policies(details)
    @person.errors << "No active policies."
  end

  def too_many_health_policies
    @person.errors << "Too many health policies."
  end

  def too_many_dental_policies
    @person.errors << "Too many dental policies"
  end

  def responsible_party_on_policy
    @person.errors << "Policy has a responsible party."
  end

  def has_errors?
    !@person.errors.empty?
  end
end

