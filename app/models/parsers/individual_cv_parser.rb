module Parsers
  class IndividualCvParser

    attr_accessor :premium_amount

    attr_reader :parser

    def initialize(xml, id_mapper, dcas_person)
      @parser = Parsers::Xml::Cv::IndividualParser.parse(xml)
      @id_mapper = id_mapper
      @dcas_person = dcas_person
      @premium_amount = {}
    end

    def address
      result = {}

      @parser.person.addresses.map do |address|
        if address.type.split("#").last.eql? "home"
          result[:address_line_1] = address.address_line_1
          result[:address_line_2] = address.address_line_2
          result[:city] = address.location_city_name
          result[:state] = address.location_state_code
          result[:zip] = address.location_postal_code
          result[:type] = address.type
          result[:location_state_code] = address.location_state_code
        end
      end

      result
    end

    def phone
      result = {}

      @parser.person.phones.map do |phone|
        if phone.type.split("#").last.eql? "home"
          result[:country_code] = phone.country_code
          result[:area_code] = phone.area_code
          result[:extension] = phone.extension
          result[:phone_number] = phone.phone_number
          result[:full_phone_number] = phone.full_phone_number
          result[:is_preferred] = phone.is_preferred
          result[:type] = phone.type
        end
      end
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
      email_value = nil
      @parser.person.emails.map do |email|
        if email.type.split("#").last.eql? "home"
          email_value = email.email_address
        end
      end
      email_value
    end

    def relationships
      @dcas_person.relationships
    end
  end
end
