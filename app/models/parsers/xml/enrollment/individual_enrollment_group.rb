module Parsers::Xml::Enrollment
  class IndividualEnrollmentGroup < EnrollmentGroup
    def credit
      @plan.at_xpath('./ins:aptc_amount', NAMESPACES).text.to_f.round(2)
    end
    
    def enrollees
      enrollees = @parser.xpath('./ins:subscriber | ./ins:member', NAMESPACES)
      enrollees.collect { |e| IndividualEnrollee.new(e) }
    end
  end
end
