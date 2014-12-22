module Parsers
  module Xml
    module Cv
      class IndividualParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'individual'
        namespace 'cv'

        has_one :person, Parsers::Xml::Cv::PersonParser, tag: 'person'
        has_one :person_demographics, Parsers::Xml::Cv::PersonDemographicsParser, tag: 'person_demographics'
        element :is_subscriber, String, tag: 'is_subscriber'
        element :is_primary_applicant, String, tag: 'is_primary_applicant'

      end
    end
  end
end