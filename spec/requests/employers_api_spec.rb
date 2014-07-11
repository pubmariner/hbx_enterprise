require 'spec_helper'

def expect_employer_cv_xml(employer_xml, employer)
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

describe 'Employers API' do
  before { sign_in_as_a_valid_user }

  describe 'retrieving an employer by primary key' do 
    let(:employer) { create :employer }
    before { get "/api/v1/employers/#{employer.id}" }

    it 'is successful (200)' do
      expect(response).to be_success # 200 status-code
    end

    it 'responds with CV XML in body' do
      xml = Hash.from_xml(response.body)
      expect_employer_cv_xml(xml['employer'], employer)
    end
  end

  describe 'searching for employers by fein' do
    let(:employers) { create_list(:employer, 3) }
    before { get "/api/v1/employers?fein=#{employers.first.fein}" }

    it 'is successful (200)' do
      expect(response).to be_success
    end

    it 'responds with CV XML in body' do
      xml = Hash.from_xml(response.body)
      employers_xml = xml['employers']
      expect_employer_cv_xml(employers_xml['employer'], employers.first)
    end
  end
end