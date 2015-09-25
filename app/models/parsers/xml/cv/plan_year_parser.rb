module Parsers
  module Xml
    module Cv
      class PlanYearParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'plan_year'
        namespace 'cv'

        element :plan_year_start, String, tag: "plan_year_start"
        element :plan_year_end, String, tag: "plan_year_end"
        element :fte_count, String, tag: "fte_count"
        element :pte_count, String, tag: "pte_count"
        element :open_enrollment_start, String, tag: "open_enrollment_start"
        element :open_enrollment_end, String, tag: "open_enrollment_end"
        has_many :elected_plans, Parsers::Xml::Cv::ElectedPlanParser, tag: "elected_plan"

        def to_hash
          {
              plan_year_start: plan_year_start,
              plan_year_end: plan_year_end,
              fte_count: fte_count,
              pte_count: pte_count,
              open_enrollment_start: open_enrollment_start,
              open_enrollment_end: open_enrollment_end,
              elected_plans:elected_plans.map(&:to_hash)
          }
        end
      end
    end
  end
end