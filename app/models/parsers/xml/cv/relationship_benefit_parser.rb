module Parsers
  module Xml
    module Cv
      class RelationshipBenefitParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'relationship_benefit'
        namespace 'cv'

        element :relationship, String, tag: "relationship"
        element :offered, String, tag: "offered"
        element :contribution_percent, String, tag: "contribution_percent"

        def to_hash
          {
              relationship: relationship,
              offered: offered,
              contribution_percent: contribution_percent,
          }
        end
      end
    end
  end
end