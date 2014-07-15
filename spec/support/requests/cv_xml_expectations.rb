module Requests
  def expect_member_xml(member_xml, member)
    
    expect(member_xml['gender']).to eq "urn:dc0:terms:gender##{member.gender}"
    expect(member_xml['dob']).to eq member.dob
    expect(member_xml['ssn']).to eq member.ssn
    expect(member_xml['tobacco_user']).to eq member.hlh.downcase
    expect(member_xml['language']).to eq member.lui
    # expect(member_xml['hbx_uri']).to eq ''
    expect(member_xml['hbx_id']).to eq member.hbx_member_id

    person_xml = member_xml['person']
    name = person_xml['name']
    person = member.person
    expect(name['name_prefix']).to eq(person.name_pfx) 
    expect(name['name_first']).to eq(person.name_first) 
    expect(name['name_middle']).to eq(person.name_middle) 
    expect(name['name_last']).to eq(person.name_last)
    expect(name['name_full']).to eq(person.name_full)
    # expect(person_xml['job_title']).to eq(nil)
    # expect(person_xml['department']).to eq(nil)

    # expect(member_xml['relationship']).to eq nil
  end

  def expect_address_xml(address_xml, address)
    expect(address_xml['address_type']).to eq address.address_type
    expect(address_xml['address_1']).to eq address.address_1
    expect(address_xml['address_2']).to eq address.address_2
    expect(address_xml['city']).to eq address.city
    expect(address_xml['state']).to eq address.state
    expect(address_xml['postal_code']).to eq address.zip
    expect(address_xml['country_code']).to eq 'US'
    # expect(address_xml['coordinates']).to eq address.address_type
  end

  def expect_phone_xml(phone_xml, phone)
    expect(phone_xml['phone_type']).to eq phone.phone_type
    expect(phone_xml['phone_number']).to eq phone.phone_number
    expect(phone_xml['extension']).to eq phone.extension
  end

  def expect_email_xml(email_xml, email)
    expect(email_xml['email_type']).to eq email.email_type
    expect(email_xml['email_address']).to eq email.email_address
  end
end