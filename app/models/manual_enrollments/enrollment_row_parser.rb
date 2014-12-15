require 'csv'

class String
  def scrub_utf8
    self.gsub(/[^\x00-\x7F]+/, "")
  end
end
  
module ManualEnrollments
  class EnrollmentRowParser
     
    PLAN_FIEDLS = %W(plan hios_id premium_total employer_contribution responsible_amount)
    DEPENDENT_FIELDS = %W(relationship ssn dob gender premium first_name middle_name last_name email phone address_1 address_2 city state zip)
    SUBSCRIBER_FIEDLS = %W(ssn dob gender premium first_name middle_name last_name email phone address_1 address_2 city state zip)

    def initialize(row)
      @row = row
    end

    def type
      @row[0].to_s.strip.scrub_utf8
    end

    def market
      # @row[1].to_s.strip.scrub_utf8
      'shop'
    end

    def employer_name
      @row[2].to_s.strip.scrub_utf8
    end

    def fein
      @row[3].to_s.strip.scrub_utf8
    end

    def broker
      @row[4].to_s.strip.scrub_utf8
    end

    def broker_npn
      @row[5].to_s.strip.scrub_utf8
    end

    def enrollees
      [ subscriber ] + dependents
    end

    def plan
      fields = @row[6..10]
      OpenStruct.new(build_fields_hash(fields, PLAN_FIEDLS))
    end

    def subscriber
      fields = @row[11..24]
      return if fields.compact.empty?
      OpenStruct.new(build_fields_hash(fields, SUBSCRIBER_FIEDLS).merge({is_subscriber: true}))
    end

    def dependents
      individuals = [ ]
      current = 25
      8.times do |i|
        fields = @row[current..(current + 14)]
        current += 15
        next if fields.compact.empty? || fields[0].nil?
        individuals << OpenStruct.new(build_fields_hash(fields, DEPENDENT_FIELDS).merge({is_subscriber: false}))
      end
      individuals
    end

    private

    def build_fields_hash(fields, columns)
      counter = 0
      columns.inject({}) do |data, column|
        data[column] = fields[counter].to_s.strip.scrub_utf8
        counter += 1
        data
      end
    end
  end
end