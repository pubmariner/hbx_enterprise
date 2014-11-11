module Parsers
    class PersonParser
      def initialize(node)
        @xml = node
      end

      def namespaces
        {
            :ax2114 => "http://struct.adapter.planmanagement.curam/xsd/preview8"
        }
      end

      def person_surname
        Maybe.new(@xml.at_xpath("ax2114:lastName", namespaces)).text.value
      end

      def person_given_name
        Maybe.new(@xml.at_xpath("ax2114:firstName", namespaces)).text.value
      end

      def address
        result = {}
        result[:address_line_1] = Maybe.new(@xml.at_xpath("ax2114:address/ax2114:addressLine1", namespaces)).text.value
        result[:address_line_2] =         Maybe.new(@xml.at_xpath("ax2114:address/ax2114:addressLine2", namespaces)).text.value
        result[:city] =  Maybe.new(@xml.at_xpath("ax2114:address/ax2114:city", namespaces)).text.value

        state =  Maybe.new(@xml.at_xpath("ax2114:address/ax2114:state", namespaces)).text.value.downcase
        if state.eql? "dc"
          result[:location_state] = "urn:openhbx:terms:v1:us_state#district_of_columbia"
        else
          result[:location_state] = "urn:openhbx:terms:v1:us_state#{state}"
        end

        result[:zip] =  Maybe.new(@xml.at_xpath("ax2114:address/ax2114:zip", namespaces)).text.value
        result
      end

      def phone
        result = {}
        result[:country_code] =  Maybe.new(@xml.at_xpath("ax2114:phoneNumber/ax2114:countryCode", namespaces)).text.value
        result[:area_code] = Maybe.new(@xml.at_xpath("ax2114:phoneNumber/ax2114:areaCode", namespaces)).text.value
        result[:extension] = Maybe.new(@xml.at_xpath("ax2114:phoneNumber/ax2114:extension", namespaces)).text.value
        result[:phone_number] = Maybe.new(@xml.at_xpath("ax2114:phoneNumber/ax2114:phoneNumber", namespaces)).text.value
        result[:full_phone_number] = Maybe.new(@xml.at_xpath("ax2114:phoneNumber/ax2114:phoneNumber", namespaces)).text.value
        result[:extension] = Maybe.new(@xml.at_xpath("ax2114:phoneNumber/ax2114:extension", namespaces)).text.value
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
        Maybe.new(@xml.at_xpath("ax2114:isPrimaryContact", namespaces)).text.value
      end

      def birth_date
        Maybe.new(@xml.at_xpath("ax2114:dateOfBirth", namespaces)).text.value
      end


      def self.build(xml_node)
        self.new(xml_node)
      end
    end
end
