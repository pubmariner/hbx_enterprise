module Parsers
  module Xml
    module Cv
      class IndividualParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'individual'
        namespace 'cv'

        element :relationship_uri, String, tag: "person_relationships/cv:person_relationship/cv:relationship_uri"

        has_one :person, Parsers::Xml::Cv::PersonParser, tag: 'person'
        has_one :person_demographics, Parsers::Xml::Cv::PersonDemographicsParser, tag: 'person_demographics'
      end
    end
  end
end