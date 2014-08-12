class CreatePolicyRequestFactory
  def self.from_form(form)
    request = {
        plan_id: form[:plan_id],
        carrier_id: form[:carrier_id],
        employer_id: form[:employer_id],
        broker_id: nil,
        responsible_party_id: nil,
        credit: form[:credit],
        carrier_to_bill: (form[:carrier_to_bill] == "1"),
        transmit_to_carrier: (form[:transmit_to_carrier] == "1")
    }

    enrollees = []
    form[:people_attributes].each_pair do |index, value|
      if(value[:include_selected] == "1")
        enrollee = {
           member_id: value[:hbx_member_id],
           coverage_start: form[:coverage_start],
           birth_date: value[:birth_date],
           relationship: value[:relationship]
        }
        enrollees << enrollee
      end
    end
    request[:enrollees] = enrollees

    request
  end
end
