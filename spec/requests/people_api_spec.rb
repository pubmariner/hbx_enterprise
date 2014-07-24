require 'spec_helper'

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

      expect_person_xml(xml['individual'], person)
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

      expect_person_xml(individuals_xml['individual'], people.first)
    end
  end
end
