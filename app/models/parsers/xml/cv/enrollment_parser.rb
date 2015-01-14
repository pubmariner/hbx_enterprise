module Parsers
  module Xml
    module Cv
      class EnrollmentParser
        include HappyMapper
        tag 'enrollment'

        has_many :enrollees, Parsers::Xml::Cv::EnrolleeParser, tag: "enrollees"
        has_one :enrollment_plan, Parsers::Xml::Cv::EnrollmentPlanParser, tag: "plan"
      end
    end
  end
end