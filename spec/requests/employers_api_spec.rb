# require 'spec_helper'

# describe 'Employers API' do
#   before { sign_in_as_a_valid_user }

#   describe 'retrieving an employer by primary key' do
#     let(:employer) { create :employer }
#     before { get "/api/v1/employers/#{employer.id}" }

#     it 'is successful (200)' do
#       expect(response).to be_success
#     end

#     it 'responds with CV XML in body' do
#       xml = Hash.from_xml(response.body)
#       expect_employer_xml(xml['employer'], employer)
#     end
#   end

#   describe 'searching for employers by fein' do
#     let(:employers) { create_list(:employer, 3) }
#     before { get "/api/v1/employers?fein=#{employers.first.fein}" }

#     it 'is successful (200)' do
#       expect(response).to be_success
#     end

#     it 'responds with CV XML in body' do
#       xml = Hash.from_xml(response.body)
#       employers_xml = xml['employers']
#       expect_employer_xml(employers_xml['employer'], employers.first)
#     end
#   end

#   describe 'searching for employers by hbx_id' do
#     let(:employers) { create_list(:employer, 3) }
#     before { get "/api/v1/employers?hbx_id=#{employers.first.hbx_id}" }

#     it 'is successful (200)' do
#       expect(response).to be_success
#     end

#     it 'responds with CV XML in body' do
#       xml = Hash.from_xml(response.body)
#       employers_xml = xml['employers']
#       expect_employer_xml(employers_xml['employer'], employers.first)
#     end
#   end
# end
