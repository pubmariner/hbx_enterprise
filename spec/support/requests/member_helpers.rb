module Requests
  def expect_member_in_cv_xml(member_xml, member)
    
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
end