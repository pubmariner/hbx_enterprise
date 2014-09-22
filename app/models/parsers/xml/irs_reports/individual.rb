require 'net/http'


module Parsers::Xml::IrsReports
  class Individual

    def initialize(data_xml = nil)
     # parser = File.open(Rails.root.to_s + "/individual1.xml")

      # parser = Net::HTTP.get(URI.parse('http://localhost:3000/api/v1/people/53e6921beb899ad9ca014faf?user_token=1LGx9y5uvcsR-syqzTob'))
      # parser = Nokogiri::XML(xml_file)
      @root = data_xml
    end

    def name_first
      @root.at_xpath("n1:person/n1:name/n1:name_first").text
    end

    def name_middle
      @root.at_xpath("n1:person/n1:name/n1:name_middle").text
    end

    def name_last
      @root.at_xpath("n1:person/n1:name/n1:name_last").text
    end

    def name_suffix
      @root.at_xpath("n1:person/n1:name/n1:name_suffix").text
    end

    def ssn
      @root.at_xpath("n1:hbx_roles/n1:qhp_roles/n1:qhp_role/n1:ssn").text if @root.at_xpath("n1:hbx_roles/n1:qhp_roles/n1:qhp_role/n1:ssn")
    end

    def dob
      Date.parse(@root.at_xpath("n1:hbx_roles/n1:qhp_roles/n1:qhp_role/n1:dob").text).strftime("%Y-%m-%d")
    end

    def addresses
      addresses = []
      @root.xpath("n1:person/n1:addresses/n1:address").each do |ele|
        address = {
          address_1: ele.at_xpath('n1:address_1').text,
          city: ele.at_xpath('n1:city').text,
          state: ele.at_xpath('n1:state').text,
          postal_code: ele.at_xpath('n1:postal_code').text
        }
        address.merge({address_2: ele.at_xpath('n1:address_2').text}) if ele.at_xpath('n1:address_2')
        addresses << address
      end
      addresses
    end

    def employers
      employers = []
      @root.xpath("n1:hbx_roles/n1:employee_roles/n1:employee_role").each do |ele|
         employers << ele.at_xpath('n1:employer/n1:id').text
      end
      employers
    end
  end
end
