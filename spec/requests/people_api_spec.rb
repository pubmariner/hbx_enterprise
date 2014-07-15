require 'spec_helper'

def expect_individual_cv_xml(individual_xml, person)
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

describe 'People API' do
  before { sign_in_as_a_valid_user }

  describe 'retrieving an individual by primary key' do 
    let(:person) { create :person }
    before { get "/api/v1/people/#{person.id}" }

    it 'is successful (200)' do
      expect(response).to be_success
    end

    it 'responds with CV XML in body' do
      xml = Hash.from_xml(response.body)

      expect_individual_cv_xml(xml['individual'], person)
    end
  end

  describe 'searching for individuals by hbx member id' do
    let(:people) { create_list(:person, 2) }

    before { get "/api/v1/people?hbx_id=#{people.first.members.first.hbx_member_id}" }
    it 'is successful (200)' do
      expect(response).to be_success
    end

    it 'responds with CV XML in body' do
      xml = Hash.from_xml(response.body)
      individuals_xml = xml['individuals']
      
      expect_individual_cv_xml(individuals_xml['individual'], people.first)
    end
  end
end