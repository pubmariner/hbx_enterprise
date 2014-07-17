module Parsers::Xml::Enrollment
  class EnrollmentGroup
    def initialize(parser)
      @parser = parser
      @plan = @parser.at_xpath('./ins:plan', NAMESPACES)
    end
    
    def hios_plan_id
      @plan.at_xpath('./pln:plan/pln:hios_plan_id', NAMESPACES).text
    end
    
    def premium_amount_total
      @plan.at_xpath('./ins:premium_amount_total', NAMESPACES).text.to_f
    end

    def premium_amount_total=(total)
      node = @plan.at_xpath('./ins:premium_amount_total', NAMESPACES)
      node.content = total
    end
    
    def enrollees
      enrollees = @parser.xpath('./ins:subscriber | ./ins:member', NAMESPACES)
      enrollees.collect { |e| Enrollee.new(e) }
    end

    def aptc
      @plan.at_xpath('./ins:aptc_amount').text.to_f
    end

    def credit
      raise NotImplementedError
    end

    def total_responsible_amount
      @plan.at_xpath('./ins:total_responsible_amount', NAMESPACES).text.to_f
    end

    def total_responsible_amount=(responsible_amount)
      node = @plan.at_xpath('./ins:total_responsible_amount', NAMESPACES)
      node.content = responsible_amount
    end

    def enrollee_premium_sum
      sum = 0
      enrollees.each { |e| sum += e.premium_amount}
      sum
    end
  end
end
