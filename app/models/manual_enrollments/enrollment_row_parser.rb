require 'csv'

class String
  def scrub_utf8
    self.gsub(/[^\x00-\x7F]+/, "").gsub(/\?/, '')
  end
end
  
module ManualEnrollments
  class EnrollmentRowParser
     
    PLAN_FIEDLS = %W(name qhp_id csr_info csr_variant hios_id premium_total employer_contribution responsible_amount)
    DEPENDENT_FIELDS = %W(ssn dob gender premium first_name middle_name last_name email phone address_1 address_2 city state zip relationship)
    SUBSCRIBER_FIEDLS = %W(ssn dob gender premium first_name middle_name last_name email phone address_1 address_2 city state zip relationship)

    attr_reader :errors, :valid

    def initialize(row)
      @row = row
      @errors = []
      @valid = true
    end

    def valid?
      validate_market
      validate_ssns
      validate_relationships
      validate_dates
      @valid
    end

    def validate_market
      market_types = ['shop', 'ivl', 'individual']

      if !market_types.include?(market)
        @valid = false
        @errors << "Market type should be #{market_types.join(' or ')}."
      end
    end

    def validate_ssns
      ssns = enrollees.select{|x| !x.ssn.blank?}.map{|x| format_ssn(x.ssn)}
      duplicate_ssns = ssns.select { |e| ssns.count(e) > 1 }.uniq
      if duplicate_ssns.any?
        @valid = false
        @errors << "duplicate ssns #{duplicate_ssns.join(',')}."
      end
    end

    def validate_relationships
      if enrollees.detect{|x| x.relationship.blank? }
        @valid = false
        @errors << 'relationship empty'
      elsif enrollees.detect{|x| !['self','spouse','child'].include?(x.relationship.downcase)}
        @valid = false
        @errors << 'invalid relationship'
      end
    end

    def validate_dates
      regex = /\d{1,2}\/\d{1,2}\/\d{4}/
      if benefit_begin_date =~ regex
        enrollees.each do |enrollee|
          if enrollee.dob !~ regex
            @valid = false
            @errors << 'wrong date format'
            break
          end
        end
      else
        @valid = false
        @errors << 'wrong date format'
      end
    end

    def type
      @row[0].to_s.strip.scrub_utf8
    end

    def market
      @row[1].to_s.strip.scrub_utf8.downcase
    end

    def market_type
      individual_market? ? "Individual" : "Shop"
    end

    def individual_market?
      ['ivl', 'individual'].include?(market)
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

    def benefit_begin_date
      @row[6].to_s.strip.scrub_utf8
    end

    def enrollees
      [ subscriber ] + dependents
    end

    def enrollment_group_id
      @row[153]
    end

    def timestamp
      @row[152]
    end

    def plan
      fields = @row[7..14]
      OpenStruct.new(build_fields_hash(fields, PLAN_FIEDLS))
    end

    def subscriber
      fields = @row[15..29]
      return if fields.compact.empty?
      OpenStruct.new(build_fields_hash(fields, SUBSCRIBER_FIEDLS).merge({is_subscriber: true}))
    end

    def dependents
      individuals = [ ]
      current = 30
      8.times do |i|
        fields = @row[current..(current + 14)]
        current += 15
        next if (fields[4].blank? && fields[6].blank?)
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

    def format_ssn(ssn)
      ssn.gsub!(/-/,'')
      (9 - ssn.size).times{ ssn = prepend_zero(ssn) }
      ssn
    end

    def prepend_zero(str)
      '0' + str
    end
  end
end
