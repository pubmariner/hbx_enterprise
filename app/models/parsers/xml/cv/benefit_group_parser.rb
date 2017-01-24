module Parsers
  module Xml
    module Cv
      class BenefitGroupParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'benefit_group'
        namespace 'cv'

        element :name, String, tag: "name"
        has_one :reference_plan, Parsers::Xml::Cv::ReferencePlanParser, tag: "reference_plan"
        has_many :relationship_benefits, Parsers::Xml::Cv::RelationshipBenefitParser, tag: "relationship_benefit"

        def to_hash
          {
              name: name,
#              reference_plan: reference_plan.to_hash,
              relationship_benefits:relationship_benefits.map(&:to_hash)
          }
        end
      end
    end
  end
end
