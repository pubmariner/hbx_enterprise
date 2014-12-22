module Parsers
  class IndividualCvParser

    attr_accessor :premium_amount

    attr_reader :parser

    def initialize(xml, id_mapper, dcas_person)
      @parser = Parsers::Xml::Cv::IndividualParser.parse(xml)
      @id_mapper = id_mapper
      @dcas_person = dcas_person
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

    def birth_date
      @parser.person_demographics.birth_date
    end

    def subscriber?
      @dcas_person.subscriber?
    end

    def is_primary_contact
      @dcas_person.is_primary_contact
    end

    def begin_date
      @dcas_person.begin_date
    end

    def end_date
      @dcas_person.end_date
    end

    def person_id
      @parser.person.id
    end

    def hbx_id
      @dcas_person.hbx_id
    end

    def email
      @parser.person.emails.map do |email|
        email.email_address
      end
    end

    def relationships
      @dcas_person.relationships
    end
  end
end
