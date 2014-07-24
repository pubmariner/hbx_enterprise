module Requests
  def expect_person_xml(individual_xml, person)
    # expect(individual_xml['authority_hbx_member_uri']).to eq nil
    # expect(individual_xml['authority_hbx_member_id']).to eq nil
    person_xml = individual_xml['person']
    name = person_xml['name']
    expect(name['name_prefix']).to eq(person.name_pfx)
    expect(name['name_first']).to eq(person.name_first)
    expect(name['name_middle']).to eq(person.name_middle)
    expect(name['name_last']).to eq(person.name_last)
    expect(name['name_full']).to eq(person.name_full)
    # expect(person_xml['job_title']).to eq(nil)
    # expect(person_xml['department']).to eq(nil)

    addresses_xml = person_xml['addresses']['address']
    addresses_xml.each_with_index do |address_xml, index|
      expect_address_xml(address_xml, person.addresses[index])
    end

    phones_xml = person_xml['phones']['phone']
    phones_xml.each_with_index do |phone_xml, index|
      expect_phone_xml(phone_xml, person.phones[index])
    end

    emails_xml = person_xml['emails']['email']
    emails_xml.each_with_index do |email_xml, index|
      expect_email_xml(email_xml, person.emails[index])
    end

    member_roles = individual_xml['member_roles']['member_role']
    member_roles.each_with_index do |member_xml, index|
      member = person.members[index]

      expect_member_xml(member_xml, member)
    end
  end

  def expect_employer_xml(employer_xml, employer)
    expect(employer_xml['name']).to eq employer.name
    expect(employer_xml['fein']).to eq employer.fein
    expect(employer_xml['hbx_uri']).to eq employer_url(employer)
    expect(employer_xml['hbx_id']).to eq employer.hbx_id
    expect(employer_xml['sic_code']).to eq employer.sic_code
    expect(employer_xml['fte_count']).to eq employer.fte_count.to_s
    expect(employer_xml['pte_count']).to eq employer.pte_count.to_s
    expect(employer_xml['open_enrollment_start']).to eq employer.open_enrollment_start.strftime("%Y-%m-%d")
    expect(employer_xml['open_enrollment_end']).to eq employer.open_enrollment_end.strftime("%Y-%m-%d")
    expect(employer_xml['plan_year_start']).to eq employer.plan_year_start.strftime("%Y-%m-%d")
    expect(employer_xml['plan_year_end']).to eq employer.plan_year_end.strftime("%Y-%m-%d")
  end

  def expect_policy_xml(policy_xml, policy)
    broker_xml = policy_xml['broker']
    broker = policy.broker
    expect(broker_xml['npn_id']).to eq broker.npn
    expect(broker_xml['name']).to eq broker.name_full

    expect_address_xml(broker_xml['address'], broker.addresses.first)
    expect_phone_xml(broker_xml['phone'], broker.phones.first)
    expect_email_xml(broker_xml['email'], broker.emails.first)

    enrollees_xml = policy_xml['enrollees']['enrollee']
    policy.enrollees.each_with_index do |enrollee, index|
      enrollee_xml = enrollees_xml[index]
      expect(enrollee_xml['premium_amount']).to eq enrollee.pre_amt.to_s
      expect(enrollee_xml['disabled']).to eq enrollee.ds.to_s
      expect(enrollee_xml['benefit_status']).to eq enrollee.ben_stat
      expect(enrollee_xml['employment_status']).to eq enrollee.emp_stat
      expect(enrollee_xml['relationship']).to eq enrollee.rel_code
      expect(enrollee_xml['carrier_assigned_member_id']).to eq enrollee.c_id
      expect(enrollee_xml['carrier_assigned_policy_id']).to eq enrollee.cp_id
      expect(enrollee_xml['coverage_start_date']).to eq enrollee.coverage_start.strftime("%Y-%m-%d")
      expect(enrollee_xml['coverage_end_date']).to eq enrollee.coverage_end.strftime("%Y-%m-%d")
      expect(enrollee_xml['coverage_status']).to eq enrollee.coverage_status

      expect_member_xml(enrollee_xml['member'], enrollee.member)
    end

    expect(policy_xml['premium_amount_total']).to eq policy.pre_amt_tot.to_s
    # expect(policy_xml['hbx_uri']).to eq nil
    # expect(policy_xml['hbx_id']).to eq nil
    expect(policy_xml['total_responsible_amount']).to eq policy.tot_res_amt.to_s
    expect(policy_xml['total_employer_responsible_amount']).to eq policy.tot_emp_res_amt.to_s
    expect(policy_xml['carrier_to_bill']).to eq policy.carrier_to_bill.to_s

    plan_xml = policy_xml['plan']
    plan = policy.plan
    expect(plan_xml['hios_plan_id']).to eq plan.hios_plan_id
    expect(plan_xml['coverage_type']).to eq plan.coverage_type
    # expect(plan_xml['hbx_uri']).to eq ''
    # expect(plan_xml['hbx_id']).to eq ''
    # expect(plan_xml['csr']).to eq ''
    expect(plan_xml['ehb']).to eq plan.ehb.to_s

    carrier_xml = plan_xml['carrier']
    carrier = plan.carrier
    expect(carrier_xml['carrier_name']).to eq carrier.name
    # expect(plan_xml['carrier']['hbx_uri']).to eq ''
    expect(carrier_xml['hbx_id']).to eq carrier.hbx_carrier_id

    expect(policy_xml['allocated_aptc']).to eq policy.allocated_aptc.to_s
    expect(policy_xml['elected_aptc_percent']).to eq policy.elected_aptc.to_s
    expect(policy_xml['applied_aptc']).to eq policy.applied_aptc.to_s

  end

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
