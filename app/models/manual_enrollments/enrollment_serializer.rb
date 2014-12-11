require 'csv'

module ManualEnrollments
  class EnrollmentSerializer

    CV_XMLNS = {
      "xmlns:pln" => "http://dchealthlink.com/vocabularies/1/plan",
      "xmlns:ins" => "http://dchealthlink.com/vocabularies/1/insured",
      "xmlns:car" => "http://dchealthlink.com/vocabularies/1/carrier",
      "xmlns:con" => "http://dchealthlink.com/vocabularies/1/contact",
      "xmlns:bt" => "http://dchealthlink.com/vocabularies/1/base_types",
      "xmlns:emp" => "http://dchealthlink.com/vocabularies/1/employer",
      "xmlns:proc" => "http://dchealthlink.com/vocabularies/1/process",
      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
      "xsi:schemaLocation" =>"http://dchealthlink.com/vocabularies/1/process process.xsd      http://dchealthlink.com/vocabularies/1/insured insured.xsd      http://dchealthlink.com/vocabularies/1/plan plan.xsd      http://dchealthlink.com/vocabularies/1/employer employer.xsd     http://dchealthlink.com/vocabularies/1/carrier carrier.xsd     http://dchealthlink.com/vocabularies/1/contact contacts.xsd     http://dchealthlink.com/vocabularies/1/base_types.xsd base_types.xsd"
    }

    def from_csv(file = "#{Padrino.root}/2015oe.csv")
      CSV.foreach(file) do |row|
        next if row[1].nil? || ["EMPLOYER", "Name"].include?(row[1].strip)
        build_cv(row)
        break
      end
    end

    def build_cv(row)
      enrollment = EnrollmentParser.new(row)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml['proc'].enrollment(CV_XMLNS) do |xml|
          xml['proc'].type 'renewal'
          xml['proc'].market 'shop'
          xml['proc'].policy do |xml|
            xml['proc'].id '10000001'
            xml['proc'].enrollees do |xml|
              enrollment.enrollees.each{ |enrollee| serialize_enrollee(enrollee, xml) }
            end
            serialize_enrollment(enrollment.plan, xml)
          end
        end
      end
      builder.to_xml(:indent => 2)
    end

    def serialize_enrollment(plan, xml)
      xml['proc'].enrollment do |xml|
      end
    end

    def serialize_enrollee(enrollee, xml)
      xml['proc'].enrollee do |xml|
        xml['proc'].member do |xml|
           serialize_person(enrollee, xml)
           serialize_demographics(enrollee, xml)
        end
        xml['proc'].is_subscriber enrollee.is_subscriber
      end
    end

    def serialize_person(enrollee, xml)
      xml['proc'].person do |xml|
        xml['proc'].id
        serialize_person_name(enrollee, xml)
        serialize_address(enrollee, xml)
        serialize_email(enrollee, xml)
        serialize_phone(enrollee, xml)
      end
    end

    def serialize_demographics(enrollee, xml)
      xml['proc'].person_demograhics do |xml|
        xml['proc'].ssn enrollee.ssn unless enrollee.ssn.blank?
        xml['proc'].sex enrollee.gender unless enrollee.gender.blank?
      end
    end

    def serialize_person_name(enrollee, xml)
      xml['proc'].person_name do |xml|
        xml['proc'].person_surname enrollee.last_name
        xml['proc'].person_given_name enrollee.first_name
      end      
    end

    def serialize_address(enrollee, xml)
      xml['proc'].addresses do |xml|
        if !enrollee.address_1.blank?
          xml['proc'].address do |xml|
            xml['proc'].type 'home'
            xml['proc'].address_line_1 enrollee.address_1
            xml['proc'].address_line_2 enrollee.address_2
            xml['proc'].location_city_name enrollee.city
            xml['proc'].location_state enrollee.state
            xml['proc'].location_postal_code enrollee.zip
          end
        end
      end
    end

    def serialize_email(enrollee, xml)
      xml['proc'].emails do |xml|
        if !enrollee.email.blank?
          xml['proc'].email do |xml|
            xml['proc'].type 'home'
            xml['proc'].email_address enrollee.email
          end
        end
      end
    end

    def serialize_phone(enrollee, xml)
      xml['proc'].phones do |xml|
        if !enrollee.phone.blank?
          xml['proc'].phone do |xml|
            xml['proc'].type 'home'
            xml['proc'].phone_number enrollee.phone
          end
        end
      end   
    end
  end
end