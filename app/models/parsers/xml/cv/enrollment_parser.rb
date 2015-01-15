module Parsers
  module Xml
    module Cv
      class EnrollmentParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'enrollment'
        namespace 'cv'

        has_many :enrollees, Parsers::Xml::Cv::EnrolleeParser, tag: "enrollees"
        has_one :hbx_enrollment, Parsers::Xml::Cv::HbxEnrollmentParser, tag: "enrollment"
      end
    end
  end
end