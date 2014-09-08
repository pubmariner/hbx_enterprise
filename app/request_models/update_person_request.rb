class UpdatePersonRequest
  def self.from_form(person_id, form, current_user)
    request = {
      person_id: person_id,
      current_user: current_user,
      addresses: []
    }

    form_addresses = form['addresses_attributes']
    form_addresses.each_value do |form_addr|
      request[:addresses] << {
        address_type: form_addr['address_type'],
        address_1: form_addr['address_1'],
        address_2: form_addr['address_2'],
        city: form_addr['city'],
        state: form_addr['state'],
        zip: form_addr['zip']
      }
    end
    
    request
  end
end
