module Parsers
  module Xml
    module Cv
      class IndividualParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'individual'
        namespace 'cv'

        element :id, String, :tag => 'id/cv:id'
        element :relationship_uri, String, tag: "person_relationships/cv:person_relationship/cv:relationship_uri"
        has_one :person, Parsers::Xml::Cv::PersonParser, tag: 'person'
        has_one :person_demographics, Parsers::Xml::Cv::PersonDemographicsParser, tag: 'person_demographics'
        has_many :broker_roles, Parsers::Xml::Cv::BrokerRolesParser, :tag => 'broker_role'

        def to_hash
          response = {
              person: person.to_hash,
              person_demographics: person_demographics.to_hash
          }
          response[:id] = id.split('#').last if id
          response[:relationship_uri] = relationship_uri.split('#').last if relationship_uri
          response[:broker_roles] = broker_roles.map(&:to_hash) if broker_roles
          response
        end
      end
    end
  end
end