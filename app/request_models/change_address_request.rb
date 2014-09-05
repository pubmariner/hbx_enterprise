class ChangeAddressRequest
  def self.from_csv_request(csv_request)
    person = Person.find_by_member_id(csv_request[:member_id])
    person_id = person.nil? ? nil : person.id
    {
      :person_id => person_id,
      :type => csv_request[:type],
      :address1 => csv_request[:address1],
      :address2 => csv_request[:address2],
      :city => csv_request[:city],
      :state => csv_request[:state],
      :zip => csv_request[:zip],
      :current_user => csv_request[:current_user],
      :transmit => (csv_request[:transmit] == 'yes')
    }
  end

  def self.from_person_update_request(person_address_request, opts = {})
    map_address_attributes(person_address_request).merge(opts)
  end

  def self.map_address_attributes(address_attributes)
    map = {
      :address_1 => :address1,
      :address_2 => :address2,
      :address_type => :type
    }
    result = {}
    address_attributes.each_pair do |k, v|
      if map.keys.include?(k.to_sym)
        result[map[k.to_sym]] = v
      else
        result[k] = v
      end
    end
    result
  end
end
