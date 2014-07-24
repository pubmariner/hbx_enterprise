require 'spec_helper'

describe 'Policy API' do
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
      expect_policy_xml(xml['policy'], policy)
    end
  end

  describe 'searching for policies by enrollment group id' do
    let(:policies) { create_list(:policy, 3) }

    before do
      # The following must be done because of the loose association between
      #   Enrollee and Member using the hbx_member_id
      policies.each do |policy|
        policy.enrollees.each do |e|
          person = create(:person)
          person.members.first.hbx_member_id = e.m_id
          person.save!
        end
      end
    end

    before { get "/api/v1/policies?enrollment_group_id=#{policies.first.eg_id}" }

    it 'is successful (200)' do
      expect(response).to be_success
    end

    it 'responds with CV XML in body' do
      xml = Hash.from_xml(response.body)
      policies_xml = xml['policies']
      expect_policy_xml(policies_xml['policy'], policies.first)
    end
  end
end
