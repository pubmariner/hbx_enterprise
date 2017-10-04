module Parsers
  module Xml
    module Cv
      class EmployerProfileParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'employer_profile'
        namespace 'cv'

        element :business_entity_kind, String, tag: "business_entity_kind"
        has_many :plan_years, Parsers::Xml::Cv::PlanYearParser, tag: "plan_year"
        has_many :benefit_groups, Parsers::Xml::Cv::BenefitGroupParser, tag: "benefit_group"
        has_one :writing_agent, Parsers::Xml::Cv::WritingAgent, tag: "brokers/cv:broker_account/cv:writing_agent"
        has_one :broker_agency, Parsers::Xml::Cv::BrokerAgency, tag: "brokers/cv:broker_account/cv:broker_agency"
        has_many :brokers, Parsers::Xml::Cv::BrokerAccountParser, tag: "broker_account"


        def to_hash
          response = {
              business_entity_kind: business_entity_kind.split("#").last,
              plan_years: plan_years.map(&:to_hash),
              benefit_groups: benefit_groups.map(&:to_hash)
          }

          response[:broker_account] = brokers.map(&:to_hash) if brokers
          response[:writing_agent] = writing_agent.to_hash if writing_agent
          response[:broker_agency] = broker_agency.to_hash if broker_agency
          response
        end
      end
    end
  end
end