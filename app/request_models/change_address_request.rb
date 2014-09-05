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
end
