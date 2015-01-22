module Parsers
  module Xml
    module Cv
      class PolicyParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'enrollment'
        namespace 'cv'

        has_one :broker, Parsers::Xml::Cv::BrokerParser, tag: "broker"
        has_many :enrollees, Parsers::Xml::Cv::EnrolleeParser, tag: "enrollee"
        has_one :hbx_enrollment, Parsers::Xml::Cv::HbxEnrollmentParser, tag: "enrollment"
      end
    end
  end
end
