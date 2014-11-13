module Parsers
  class PersonParser
    def initialize(node, id_map)
      @xml = node
      @id_mapper = id_map
    end

    def namespaces
      {
          :ax2114 => "http://struct.adapter.planmanagement.curam/xsd/preview8"
      }
    end

    def surname
      Maybe.new(@xml.at_xpath("ax2114:lastName", namespaces)).text.value
    end

    def given_name
      Maybe.new(@xml.at_xpath("ax2114:firstName", namespaces)).text.value
    end

    def middle_name
      Maybe.new(@xml.at_xpath("ax2114:middleName", namespaces)).text.value
    end

    def full_name
      given_name + " " + middle_name + " " + surname
    end

    def address
      result = {}
      result[:address_line_1] = Maybe.new(@xml.at_xpath("ax2114:address/ax2114:addressLine1", namespaces)).text.value
      result[:address_line_2] = Maybe.new(@xml.at_xpath("ax2114:address/ax2114:addressLine2", namespaces)).text.value

      if Maybe.new(@xml.at_xpath("ax2114:address/ax2114:suiteNumber", namespaces)).text.value.present?
        result[:address_line_2] = result[:address_line_2] + " Apt " + Maybe.new(@xml.at_xpath("ax2114:address/ax2114:suiteNumber", namespaces)).text.value
      end

      result[:city] = Maybe.new(@xml.at_xpath("ax2114:address/ax2114:city", namespaces)).text.value

      state = Maybe.new(@xml.at_xpath("ax2114:address/ax2114:state", namespaces)).text.value.downcase
      if state.eql? "dc"
        result[:location_state] = "urn:openhbx:terms:v1:us_state#district_of_columbia"
      else
        result[:location_state] = "urn:openhbx:terms:v1:us_state#{state}"
      end

      result[:zip] = Maybe.new(@xml.at_xpath("ax2114:address/ax2114:zip", namespaces)).text.value
      result
    end

    def phone
      result = {}
      result[:country_code] = Maybe.new(@xml.at_xpath("ax2114:phoneNumber/ax2114:countryCode", namespaces)).text.value
      result[:area_code] = Maybe.new(@xml.at_xpath("ax2114:phoneNumber/ax2114:areaCode", namespaces)).text.value
      result[:extension] = Maybe.new(@xml.at_xpath("ax2114:phoneNumber/ax2114:extension", namespaces)).text.value
      result[:phone_number] = Maybe.new(@xml.at_xpath("ax2114:phoneNumber/ax2114:phoneNumber", namespaces)).text.value
      result[:full_phone_number] = "#{result[:country_code]}#{result[:area_code]}#{result[:phone_number]}"
      result[:full_phone_number] = "#{result[:full_phone_number]}x#{result[:extension]}" if result[:extension].present?
      result
    end

    def sex
      gender = Maybe.new(@xml.at_xpath("ax2114:gender", namespaces)).text.value

      case gender.downcase
        when "sx1"
          return "urn:openhbx:terms:v1:gender#male"
        when "sx2"
          return "urn:openhbx:terms:v1:gender#female"
        else
          return "urn:openhbx:terms:v1:gender#unknown"
      end
    end

    def native_american
      Maybe.new(@xml.at_xpath("ax2114:nativeAmerican", namespaces)).text.value
    end

    def ssn
      Maybe.new(@xml.at_xpath("ax2114:ssn", namespaces)).text.value
    end

    def is_primary_contact
      Maybe.new(@xml.at_xpath("ax2114:isPrimaryContact", namespaces)).text.downcase.value
    end

    def birth_date
      Maybe.new(@xml.at_xpath("ax2114:dateOfBirth", namespaces)).text.value
    end

    def subscriber?
      "true" == is_primary_contact
    end

    def begin_date
      Maybe.new(@xml.at_xpath("ax2114:coverageStartDate", namespaces)).text.value
    end

    def end_date
      Maybe.new(@xml.at_xpath("ax2114:coverageEndDate", namespaces)).text.value
    end

    def person_id
      Maybe.new(@xml.at_xpath("ax2114:personID", namespaces)).text.value
    end

    def hbx_id
      @id_mapper[person_id]
    end

    def self.build(xml_node, id_map)
      self.new(xml_node, id_map)
    end

    def premium_amount
      @premium
    end

    def premium_amount=(premium)
      @premium = premium
    end

    def relationships
      return [] if subscriber?
      rels = []
      @xml.xpath("ax2114:relationship", namespaces).each do |node|
         sub_id = node.at_xpath("ax2114:relatedPersonID",namespaces).text
         rel_code = node.at_xpath("ax2114:relationshipType",namespaces).text
         rels << OpenStruct.new(
           :subject_individual => hbx_id,
           :object_individual => @id_mapper[sub_id],
           :relationship_uri => rel_code
         )
      end
      rels
    end

    def email
      Maybe.new(@xml.at_xpath("ax2114:emailAddress", namespaces)).text.value
    end

  end
end
