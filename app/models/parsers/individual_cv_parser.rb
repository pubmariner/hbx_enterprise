module Parsers
  class IndividualCvParser

    attr_accessor :premium_amount

    attr_reader :parser

    def initialize(xml)
      @parser = Parsers::Xml::Cv::IndividualParser.parse(xml)
    end

    def address
      result = {}
      result[:address_line_1] = @parser.person.addresses.first.address_line_1
      result[:address_line_2] = @parser.person.addresses.first.address_line_2
      result[:city] = @parser.person.addresses.first.location_city_name
      result[:state] = @parser.person.addresses.first.location_state_code
      result[:zip] = @parser.person.addresses.first.location_postal_code
      result
    end

    def phone
      result = {}
      result[:country_code] = @parser.person.phones.first.country_code
      result[:area_code] = @parser.person.phones.first.area_code
      result[:extension] = @parser.person.phones.first.extension
      result[:phone_number] = @parser.person.phones.first.phone_number
      result[:full_phone_number] = @parser.person.phones.first.full_phone_number
      result[:is_preferred] = @parser.person.phones.first.is_preferred
      result[:type] = @parser.person.phones.first.type
      result
    end

    def surname
      @parser.person.name_last
    end

    def given_name
      @parser.person.name_first
    end

    def middle_name
      @parser.person.name_middle
    end

    def full_name
      @parser.person.name_full
    end

    def sex
      @parser.person_demographics.sex
    end

    def ssn
      @parser.person_demographics.ssn
    end

    def is_primary_contact
      Maybe.new(@xml.at_xpath("ax2114:isPrimaryContact", namespaces)).text.downcase.value
    end

    def birth_date
      @parser.person_demographics.birth_date
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
      @parser.person.id
    end

    def hbx_id
      @id_mapper[person_id]
    end
  end
end