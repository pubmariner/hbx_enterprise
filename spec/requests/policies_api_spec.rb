require 'spec_helper'

def expect_policy_cv_xml(policy_xml, policy)
  broker_xml = policy_xml['broker']
  broker = policy.broker
  expect(broker_xml['npn_id']).to eq broker.npn
  expect(broker_xml['name']).to eq broker.name_full

  address_xml = broker_xml['address']
  address = broker.addresses.first
  expect(address_xml['address_type']).to eq address.address_type
  expect(address_xml['address_1']).to eq address.address_1
  expect(address_xml['address_2']).to eq address.address_2
  expect(address_xml['city']).to eq address.city
  expect(address_xml['state']).to eq address.state
  expect(address_xml['postal_code']).to eq address.zip
  expect(address_xml['country_code']).to eq 'US'
  # expect(address_xml['coordinates']).to eq address.address_type

  phone_xml = broker_xml['phone']
  phone = broker.phones.first
  expect(phone_xml['phone_type']).to eq phone.phone_type
  expect(phone_xml['phone_number']).to eq phone.phone_number

  email_xml = broker_xml['email']
  email = broker.emails.first
  expect(email_xml['email_type']).to eq email.email_type
  expect(email_xml['email_address']).to eq email.email_address

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
    
    expect_member_in_cv_xml(enrollee_xml['member'], enrollee.member)
  end


  expect(policy_xml['premium_amount_total']).to eq policy.pre_amt_tot.to_s
  # expect(policy_xml['hbx_uri']).to eq nil
  # expect(policy_xml['hbx_id']).to eq nil
  expect(policy_xml['total_responsible_amount']).to eq policy.tot_res_amt.to_s
  expect(policy_xml['total_employer_responsible_amount']).to eq policy.tot_emp_res_amt.to_s
  expect(policy_xml['carrier_to_bill']).to eq policy.carrier_to_bill.to_s  
  # expect(policy_xml['plan']).to eq nil
  expect(policy_xml['allocated_aptc']).to eq policy.allocated_aptc.to_s  
  expect(policy_xml['elected_aptc_percent']).to eq policy.elected_aptc.to_s 
  expect(policy_xml['applied_aptc']).to eq policy.applied_aptc.to_s  

end

describe 'Employers API' do
  before { sign_in_as_a_valid_user }

  describe 'retrieving a policy by primary key' do 
    let(:policy) { create :policy }

    before do
      # The following must be done because of the loose association between 
      #   Enrollee and Member using the hbx_member_id
      policy.enrollees.each do |e|
        person = create(:person)
        person.members.first.hbx_member_id = e.m_id
        person.save!
      end
    end
    before { get "/api/v1/policies/#{policy.id}" }

    it 'is successful (200)' do
      expect(response).to be_success
    end

    it 'responds with CV XML in body' do
      xml = Hash.from_xml(response.body)
      expect_policy_cv_xml(xml['policy'], policy)
    end
  end

  describe 'searching for policies by enrollment group id' do
    let(:policies) { create_list(:policy, 3) }
    before { get "/api/v1/policies?enrollment_group_id=#{policies.first.eg_id}" }

    it 'is successful (200)' do
      expect(response).to be_success
    end

    # it 'responds with CV XML in body' do
    #   xml = Hash.from_xml(response.body)
    #   employers_xml = xml['employers']
    #   expect_employer_cv_xml(employers_xml['employer'], employers.first)
    # end
  end
end