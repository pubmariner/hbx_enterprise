require 'csv'

class String
  def scrub_utf8
    self.gsub(/[^\x00-\x7F]+/, "").gsub(/\?/, '')
  end
end
  
module ManualEnrollments
  class EnrollmentRowParser
     
    PLAN_FIELDS = %W(name qhp_id csr_info csr_variant hios_id premium_total employer_contribution responsible_amount)
    ENROLLEE_FIELDS = %W(ssn dob gender premium first_name middle_name last_name email phone address_1 address_2 city state zip relationship)
    
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
      validate_benefit_begin
      validate_dob
      validate_address
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
      valid_relations = ['self','spouse','child']

      if enrollees.detect{|x| x.relationship.blank? || !valid_relations.include?(x.relationship.downcase) }
        @valid = false
        @errors << 'relationship is empty or wrong'
      end

      relationships = enrollees.map{|enrollee| enrollee.relationship.to_s.downcase}

      if ['self', 'spouse'].detect{|rel| relationships.count(rel) > 1}
        @valid = false
        @errors << 'more than one subscriber/spouse'
      end

      if relationships.count('self').zero?
        @valid = false
        @errors << 'no enrollee with relationship as self'
      end
    end

    def validate_benefit_begin
      regex = /\d{1,2}\/\d{1,2}\/\d{4}/
      if benefit_begin_date !~ regex
        @valid = false
        @errors << 'wrong benefit begin date'
      end
    end

    def validate_dob
      regex = /\d{1,2}\/\d{1,2}\/\d{4}/
      if enrollees.detect { |enrollee| enrollee.dob !~ regex }
        @valid = false
        @errors << 'wrong DOB format'        
      end
    end

    def validate_address
      if subscriber.address_1.blank?
        @valid = false
        @errors << 'address of the subscriber missing'   
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

    def plan
      fields = @row[7..14]
      OpenStruct.new(build_fields_hash(fields, PLAN_FIELDS))
    end

    def subscriber
      enrollees.first
    end

    def enrollees
      pos = 15
      members = []
      9.times do |i|
        elements = @row[pos..(pos + 14)]
        pos += 15
        next if elements.blank?
        if [0, 1, 4, 6].detect{|index| !elements[index].blank?}
          members << OpenStruct.new(build_fields_hash(elements, ENROLLEE_FIELDS))
        end
      end
      sort_enrollees_by_rel(members)
    end

    def dependents
      sub, *deps = enrollees
      @dependents ||= deps
    end

    def sort_enrollees_by_rel(enrollees)
      relationships = ['self', 'spouse', 'child']

      enrollees.select{ |enrollee|
        relationships.include?(relationship(enrollee))
      }.sort_by{ |enrollee|
          relationships.index(relationship(enrollee))
      } + enrollees.reject{ |enrollee|
        relationships.include?(relationship(enrollee))
      }
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

    def relationship(enrollee)
      return if enrollee.relationship.blank?
      enrollee.relationship.downcase
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
