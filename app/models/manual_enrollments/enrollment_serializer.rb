require 'csv'

module ManualEnrollments
  class EnrollmentSerializer

    CV_XMLNS = {
      "xmlns" => 'http://openhbx.org/api/terms/1.0',
      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance"
    }

    def initialize
      @policy_id_generator = IdGenerator.new(45000)
      @person_id_generator = IdGenerator.new(10002000)     
    end

    def from_csv(file = "#{Padrino.root}/2015oe.csv")
      publisher = ManualEnrollments::EnrollmentPublisher.new
      File.open("#{Padrino.root}/enrollments.log", "a") do |f|
        CSV.foreach(file) do |row|
          next if row[2].blank? || ["Sponsor Name"].include?(row[2].strip)
          payload = generate_enrollment_cv(row)
          response = publisher.publish(payload)
          f.puts row
          f.puts response
          puts response.inspect
        end
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
            serialize_broker(@enrollment, xml)
            serialize_enrollees(@enrollment, xml)
            serialize_enrollment(@enrollment, xml)
          end
        end
      end
      # write_to_file builder.to_xml(:indent => 2)
      builder.to_xml(:indent => 2)
    end

    def serialize_broker(enrollment, xml)
      xml.broker do |xml|
        if enrollment.market != 'shop'
          xml.id do |xml|
            xml.id enrollment.broker_npn
          end
          xml.name enrollment.broker
        end
      end
    end

    def serialize_enrollment(enrollment, xml)
      xml.enrollment do |xml|
        serialize_plan(enrollment.plan, enrollment, xml)
      end
    end

    def serialize_plan(plan, enrollment, xml)
      xml.plan do |xml|
        xml.id do |xml|
          xml.id plan.hios_id
        end
        xml.coverage_type 'urn:openhbx:terms:v1:qhp_benefit_coverage#health'
        xml.plan_year '2015'
        xml.name plan.name
        xml.is_dental_only false
        enrollment.market == 'shop' ? serialize_shop_market(enrollment, xml) : serialize_individual_market(enrollment, xml)
        xml.premium_amount_total plan.premium_total.gsub(/\$/, '')
        xml.total_responsible_amount plan.responsible_amount.gsub(/\$/, '')
      end
    end

    def serialize_individual_market(enrollment, xml)
      xml.individual_market do |xml|
      end
    end

    def serialize_shop_market(enrollment, xml)
      xml.shop_market do |xml|
        xml.employer_link do |xml|
          xml.id do |xml|
            xml.id enrollment.fein
          end
          xml.name enrollment.employer_name.camelcase
        end
        xml.total_employer_responsible_amount enrollment.plan.employer_contribution.gsub(/\$/, '')
      end
    end

    def serialize_enrollees(enrollment, xml)
      xml.enrollees do |xml|
        enrollment.enrollees.each do |enrollee|
          xml.enrollee do |xml|
            serialize_member(enrollee, xml)
            xml.is_subscriber enrollee.is_subscriber
            xml.benefit do |xml|
              xml.begin_date '20150101'
              xml.premium_amount enrollee.premium.gsub(/\$/, '')
            end
          end
        end
      end
    end

    def serialize_member(enrollee, xml)
      xml.member do |xml|
        id = @person_id_generator.unique_identifier
        serialize_person_id(enrollee, xml, id)
        serialize_person(enrollee, xml, id)
        serialize_relationships(enrollee, xml)
        serialize_demographics(enrollee, xml)
      end      
    end

    def serialize_person(enrollee, xml, id)
      xml.person do |xml|
        serialize_person_id(enrollee, xml, id)
        serialize_names(enrollee, xml)
        serialize_address(enrollee, xml)
        serialize_email(enrollee, xml)
        serialize_phone(enrollee, xml)
      end
    end

    def serialize_relationships(enrollee, xml)
      xml.person_relationships do |xml|
        xml.relationship do |xml|
          xml.subject_individual do |xml|
            xml.id @person_id_generator.current
          end
          xml.relationship_uri 'urn:openhbx:terms:v1:individual_relationship#' + (enrollee.is_subscriber ? 'self' : enrollee.relationship).downcase
          xml.object_individual do |xml|
            xml.id @subscriber_id
          end
        end
      end
    end

    def serialize_demographics(enrollee, xml)
      xml.person_demographics do |xml|
        xml.ssn format_ssn(enrollee.ssn) if !enrollee.ssn.blank?
        xml.sex 'urn:openhbx:terms:v1:gender#' + enrollee.gender.downcase if !enrollee.gender.blank?
        xml.birth_date format_date(enrollee.dob) if !enrollee.dob.blank?
      end
    end

    def serialize_person_id(enrollee, xml, id)
      xml.id do |xml|
        if enrollee.is_subscriber
          @subscriber_id = id
        end
        xml.id id
      end    
    end

    def serialize_names(enrollee, xml)
      xml.person_name do |xml|
        xml.person_surname enrollee.last_name
        xml.person_given_name enrollee.first_name
        xml.person_middle_name enrollee.middle_name if !enrollee.middle_name.blank?
      end
    end

    def serialize_address(enrollee, xml)
      if enrollee.address_1.blank?
        # puts "----------found match"
        enrollee = @enrollment.subscriber
      end
      xml.addresses do |xml|
        xml.address do |xml|
          xml.type 'urn:openhbx:terms:v1:address_type#home'
          xml.address_line_1 enrollee.address_1
          xml.address_line_2 enrollee.address_2 if !enrollee.address_2.blank?
          xml.location_city_name enrollee.city
          xml.location_state_code enrollee.state
          xml.postal_code enrollee.zip
        end
      end
    end

    def serialize_email(enrollee, xml)
      xml.emails do |xml|
        if !enrollee.email.blank?
          xml.email do |xml|
            xml.type 'urn:openhbx:terms:v1:email_type#home'
            xml.email_address enrollee.email
          end
        end
      end
    end

    def serialize_phone(enrollee, xml)
      xml.phones do |xml|
        if !enrollee.phone.blank?
          xml.phone do |xml|
            xml.type 'urn:openhbx:terms:v1:phone_type#home'
            xml.full_phone_number enrollee.phone.gsub(/-/,'')
          end
        end
      end
    end

    def write_to_file(xml_string)
      File.open("#{Padrino.root}/enrollments/enrollment_#{@policy_id_generator.current}.xml", 'w') do |file|
        file.write xml_string
      end
    end

    def format_date(date)
      date = Date.strptime(date,'%m/%d/%Y')
      date.strftime('%Y%m%d')
    end

    private

    def format_ssn(ssn)
      ssn.gsub!(/-/,'')
      (9 - ssn.size).times{ ssn = prepend_zero(ssn) }
      ssn
    end

    def prepend_zero(ssn)
      '0' + ssn
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
