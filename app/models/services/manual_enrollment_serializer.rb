require 'csv'

module Services
  class ManualEnrollmentSerializer

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

    def from_csv
      CSV.foreach("#{Padrino.root}/2015oe.csv") do |row|
        next if row[1].nil? || ["EMPLOYER", "Name"].include?(row[1].strip)
        to_cv(row)
        break
      end
    end

    def to_cv(row)
      enrollment = ManualEnrollmentRow.new(row)
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
        end
        xml['proc'].is_subscriber enrollee.is_subscriber
      end
    end

    def serialize_person(enrollee, xml)
      xml['proc'].person do |xml|
        xml['proc'].id
        xml['proc'].person_name do |xml|
          xml['proc'].person_surname enrollee.last_name
          xml['proc'].person_given_name enrollee.first_name
        end
        if enrollee.is_subscriber
          serialize_contact_information(enrollee, xml)
        end
      end
    end

    def serialize_contact_information(enrollee, xml)
      xml['proc'].addresses do |xml|
        xml['proc'].address do |xml|
          xml['proc'].type 'home'
          xml['proc'].address_line_1
          xml['proc'].address_line_2
          xml['proc'].location_city_name
          xml['proc'].location_state
          xml['proc'].location_postal_code
        end
      end
      xml['proc'].emails do |xml|
        xml['proc'].email enrollee.email
      end
      xml['proc'].phones do |xml|
        xml['proc'].phone enrollee.phone
      end   
    end
  end

  class ManualEnrollmentRow

    def initialize(row)
      @row = row
    end

    def enrollees
      [ employee ] + dependents
    end

    def type
      @row[0]
    end

    def employer
     @row[1]
    end

    def effective_date
      @row[2]
    end

    def contact_info
      {
        email: @row[11],
        phone: @row[12],
        street_address: @row[13] 
      }
    end

    def employee
      fields = @row[3..10]
      OpenStruct.new({
        first_name: fields[0],
        middle_name: fields[1],
        last_name: fields[2],
        hbx_id: fields[3],
        ssn: fields[4],
        dob: fields[5],
        gender: fields[6],
        rate: fields[7],
        is_subscriber: true
        }.merge(contact_info))
    end

    def dependents
      individuals = [ ]
      current = 21
      8.times do |i|
        fields = @row[current..(current + 8)]
        current += 9
        next if fields.compact.empty? || fields[0].nil?
        individuals << OpenStruct.new({
          first_name: fields[0],
          middle_name: fields[1],
          last_name: fields[2],
          hbx_id: fields[3],
          ssn: fields[4],
          dob: fields[5],
          gender: fields[6],
          relationship: fields[7],
          rate: fields[8],
          is_subscriber: false
          })
      end
      individuals
    end

    def plan
      OpenStruct.new ({
        carrier: @row[14],
        plan: @row[15],
        hios_id: @row[16],
        metal_level: @row[17],
        total_premium: @row[18],
        er_pays: @row[19],
        ee_pays: @row[20]
        })
    end
  end
end