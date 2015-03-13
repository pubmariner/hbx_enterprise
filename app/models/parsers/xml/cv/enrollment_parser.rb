module Parsers
  module Xml
    module Cv
      class EnrollmentParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'enrollment'
        namespace 'cv'

        has_one :policy, Parsers::Xml::Cv::PolicyParser, tag: "policy"
      end
    end
  end
end