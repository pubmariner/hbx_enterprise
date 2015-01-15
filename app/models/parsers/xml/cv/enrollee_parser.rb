module Parsers
  module Xml
    module Cv
      class EnrolleeParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'enrollee'
        namespace 'cv'

        element :begin_date, String, tag: "enrollee/cv:benefit/cv:begin_date"
        element :premium_amount, String, tag: "enrollee/cv:benefit/cv:premium_amount"

        has_one :member, Parsers::Xml::Cv::IndividualParser, tag: "member"
      end
    end
  end
end