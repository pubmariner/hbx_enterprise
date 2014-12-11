require 'csv'

module ManualEnrollments
  class EnrollmentSerializer

    CV_XMLNS = {
      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance"
    }

    def from_csv(file = "#{Padrino.root}/2015oe.csv")
      @policy_id_generator = IdGenerator.new(1000000)
      @person_id_generator = IdGenerator.new(30000)
      CSV.foreach(file) do |row|
        next if row[1].blank? || ["employer name"].include?(row[1].strip)
        generate_enrollment_cv(row)
      end
    end

    def generate_enrollment_cv(row)
      @enrollment = EnrollmentRowParser.new(row)
      @enrollment_plan = @enrollment.plan
      return if @enrollment.subscriber.nil?
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.enrollment(CV_XMLNS) do |xml|
          xml.type 'renewal'
          xml.market 'shop'
          xml.policy do |xml|
            xml.id do |xml|
              xml.id @policy_id_generator.unique_identifier
            end
            serialize_enrollees(xml)
            serialize_enrollment(xml)
          end
        end
      end
      write_to_file builder.to_xml(:indent => 2)
    end

    def serialize_enrollment(xml)
      xml.enrollment do |xml|
        serialize_plan(xml)
        @enrollment.shop_market? ? serialize_shop_market(xml) : serialize_individual_market(xml)
        xml.premium_amount_total @enrollment_plan.premium_total.gsub(/\$/, '')
        xml.total_responsible_amount @enrollment_plan.responsible_amount.gsub(/\$/, '')
      end
    end

    def serialize_individual_market(xml)
      xml.individual_market do |xml|
      end
    end

    def serialize_shop_market(xml)
      xml.shop_market do |xml|
        xml.employer_link do |xml|
          xml.id do |xml|
            xml.id @enrollment.fein
          end
          xml.name @enrollment.employer_name
        end
        xml.total_employer_responsible_amount @enrollment_plan.employer_contribution.gsub(/\$/, '')
      end
    end

    def serialize_plan(xml)
      xml.plan do |xml|
        xml.id do |xml|
          xml.id @enrollment_plan.hios_id
        end
        xml.coverage_type 'health'
        xml.plan_year '2015'
        xml.name @enrollment_plan.name
        xml.is_dental_only false
      end
    end

    def serialize_enrollees(xml)
      xml.enrollees do |xml|
        @enrollment.enrollees.each do |enrollee| 
          xml.enrollee do |xml|
            xml.member do |xml|
              serialize_person(enrollee, xml)
              serialize_demographics(enrollee, xml)
            end
            xml.is_subscriber enrollee.is_subscriber
          end
        end
      end
    end

    def serialize_person(enrollee, xml)
      xml.person do |xml|
        xml.id do |xml|
          xml.id @person_id_generator.unique_identifier
        end
        xml.person_name do |xml|
          xml.person_surname enrollee.last_name
          xml.person_given_name enrollee.first_name
          xml.person_middle_name enrollee.middle_name unless enrollee.middle_name.blank?
        end
        serialize_address(enrollee, xml)
        serialize_email(enrollee, xml)
        serialize_phone(enrollee, xml)
      end
    end

    def serialize_demographics(enrollee, xml)
      xml.person_demograhics do |xml|
        xml.ssn enrollee.ssn unless enrollee.ssn.blank?
        xml.sex enrollee.gender unless enrollee.gender.blank?
      end
    end

    def serialize_address(enrollee, xml)
      xml.addresses do |xml|
        if !enrollee.address_1.blank?
          xml.address do |xml|
            xml.type 'home'
            xml.address_line_1 enrollee.address_1
            xml.address_line_2 enrollee.address_2 unless enrollee.address_2.blank?
            xml.location_city_name enrollee.city
            xml.location_state enrollee.state
            xml.location_postal_code enrollee.zip
          end
        end
      end
    end

    def serialize_email(enrollee, xml)
      xml.emails do |xml|
        if !enrollee.email.blank?
          xml.email do |xml|
            xml.type 'home'
            xml.email_address enrollee.email
          end
        end
      end
    end

    def serialize_phone(enrollee, xml)
      xml.phones do |xml|
        if !enrollee.phone.blank?
          xml.phone do |xml|
            xml.type 'home'
            xml.phone_number enrollee.phone
          end
        end
      end   
    end

    def write_to_file(xml_string)
      File.open("#{Padrino.root}/enrollments/enrollment_#{@policy_id_generator.current}.xml", 'w') do |file|
        file.write xml_string
      end
    end
  end

  class IdGenerator
    attr_reader :current

    def initialize(start)
      @current = start
    end

    def unique_identifier
      @current += 1
    end
  end
end