require 'csv'

module ManualEnrollments
  class EnrollmentRowParser
     
    PLAN_FIEDLS = %W(plan hios_id premium_total employer_contribution responsible_amount)
    DEPENDENT_FIELDS = %W(relationship ssn dob gender premium first_name middle_name last_name email phone address_1 address_2 city state zip)
    SUBSCRIBER_FIEDLS = %W(ssn dob gender premium first_name middle_name last_name email phone address_1 address_2 city state zip)

    def initialize(row)
      @row = row
    end

    def employer
      @row[1].strip
    end

    def fein
      @row[2].strip
    end

    def enrollees
      [ subscriber ] + dependents
    end

    def plan
      fields = @row[3..7]
      OpenStruct.new(build_fields_hash(fields, PLAN_FIEDLS))
    end

    def subscriber
      fields = @row[8..20]
      OpenStruct.new(build_fields_hash(fields, SUBSCRIBER_FIEDLS).merge({is_subscriber: true}))
    end

    def dependents
      individuals = [ ]
      current = 21
      8.times do |i|
        fields = @row[current..(current + 8)]
        current += 14
        next if fields.compact.empty? || fields[0].nil?
        individuals << OpenStruct.new(build_fields_hash(fields, DEPENDENT_FIELDS).merge({is_subscriber: false}))
      end
      individuals
    end

    private

    def build_fields_hash(fields, columns)
      counter = 0
      columns.inject({}) do |data, column|
        data[column] = fields[counter].strip
        counter += 1
        data
      end
    end
  end
end