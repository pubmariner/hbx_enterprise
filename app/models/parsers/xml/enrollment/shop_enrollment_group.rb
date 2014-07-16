module Parsers::Xml::Enrollment
  class ShopEnrollmentGroup < EnrollmentGroup
    def credit
      @plan.at_xpath('./ins:total_employer_responsibility_amount', NAMESPACES).text.to_f.round(2)
    end

    def enrollees
      enrollees = @parser.xpath('./ins:subscriber | ./ins:member', NAMESPACES)
      enrollees.collect { |e| ShopEnrollee.new(e, self.employer) }
    end

    def employer
      fein = @parser.xpath('./emp:employer/emp:fein').text
      Employer.find_for_fein(fein)
    end
  end
end
