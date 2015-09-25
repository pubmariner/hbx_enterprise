module Parsers
  module Xml
    module Cv
      class EmployerProfileParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'employer_profile'
        namespace 'cv'

        element :business_entity_kind, String, tag: "business_entity_kind"
        has_many :brokers, Parsers::Xml::Cv::BrokerParser, tag: "broker"
        has_many :plan_years, Parsers::Xml::Cv::PlanYearParser, tag: "plan_year"
        has_many :benefit_groups, Parsers::Xml::Cv::BenefitGroupParser, tag: "benefit_group"

        def to_hash
          {
              business_entity_kind: business_entity_kind.split("#").last,
              brokers: brokers.map(&:to_hash),
              plan_years: plan_years.map(&:to_hash),
              benefit_groups: benefit_groups.map(&:to_hash)
          }
        end
      end
    end
  end
end