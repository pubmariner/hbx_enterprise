# require 'spec_helper'

# NAMESPACES = {
#   n1: 'http://openhbx.org/api/terms/1.0'
# }

# module Parsers::Xml
#   class Name
#     def initialize(xml)
#       @xml = xml
#     end

#     def prefix
#       @xml.at_xpath('./n1:name_prefix', NAMESPACES).text
#     end

#     def first
#     end

#     def middle
#     end

#     def last
#     end

#     def full
#     end
#   end

#   class Individual

#     def initialize(xml)
#       @xml = xml
#     end

#     def name
#       Name.new(@xml.at_xpath('./n1:person/n1:name', NAMESPACES))
#     end
#   end
# end

# describe 'People API' do
#   before { sign_in_as_a_valid_user }

#   describe 'retrieving an individual by primary key' do
#     let(:person) { create :person }
#     before { get "/api/v1/people/#{person.id}" }

#     it 'is successful (200)' do
#       expect(response).to be_success
#     end

#     it 'responds with CV XML in body' do
#       xml = Hash.from_xml(response.body)
#       doc = Nokogiri::XML(response.body)
      
#       ##writing parsers at the same time/
#       # i = Parsers::Xml::Individual.new(doc.at_xpath('/n1:individual'))
#       # expect(i.name.prefix).to eq person.name_pfx
      
#       ##straight up
#       # name = doc.at_xpath('/n1:individual/n1:person/n1:name', NAMESPACES)
#       # expect(name.at_xpath('./n1:name_prefix', NAMESPACES).text).to eq person.name_pfx
#       # expect(name.at_xpath('./n1:name_first', NAMESPACES).text).to eq person.name_first
#       # expect(name.at_xpath('./n1:name_middle', NAMESPACES).text).to eq person.name_middle
#       # expect(name.at_xpath('./n1:name_last', NAMESPACES).text).to eq person.name_last
#       # expect(name.at_xpath('./n1:name_full', NAMESPACES).text).to eq person.name_full

#       # addresses = doc.xpath('/n1:individual/n1:person/n1:addresses/n1:address', NAMESPACES)
#       # addresses.each_with_index do |addr, index|
#       #   address = person.addresses[index]
#       #   type = addr.at_xpath('./n1:address_type', NAMESPACES).text
#       #   expect(type).to eq "urn:openhbx:terms:v1:address_type##{address.address_type}"

#       #   line_one = addr.at_xpath('./n1:address_1', NAMESPACES).text
#       #   expect(line_one).to eq address.address_1

#       #   line_two = addr.at_xpath('./n1:address_2', NAMESPACES).text
#       #   expect(line_two).to eq address.address_2

#       #   city = addr.at_xpath('./n1:city', NAMESPACES).text
#       #   expect(city).to eq address.city

#       #   state = addr.at_xpath('./n1:state', NAMESPACES).text
#       #   expect(state).to eq address.state

#       #   zip = addr.at_xpath('./n1:postal_code', NAMESPACES).text
#       #   expect(zip).to eq address.zip

#       #   country_code = addr.at_xpath('./n1:country_code', NAMESPACES).text
#       #   expect(country_code).to eq 'US'
#       # end
#       expect_person_xml(xml['individual'], person)
#     end
#   end

#   describe 'searching for individuals by hbx member id' do
#     let(:people) { create_list(:person, 2) }

#     before { get "/api/v1/people?hbx_id=#{people.first.members.first.hbx_member_id}" }
#     it 'is successful (200)' do
#       expect(response).to be_success
#     end

#     it 'responds with CV XML in body' do
#       xml = Hash.from_xml(response.body)
#       individuals_xml = xml['individuals']

#       expect_person_xml(individuals_xml['individual'], people.first)
#     end
#   end
# end
