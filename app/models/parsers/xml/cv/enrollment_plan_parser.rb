module Parsers
  module Xml
    module Cv
      class EnrollmentPlanParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'plan'
        namespace 'cv'

        element :id, String, tag: "id/cv:id"
        element :coverage_type, String, tag: "coverage_type"
        element :plan_year, String, tag: "plan_year"
        element :plan_year, String, tag: "plan_year"
        element :name, String, tag: "name"
        element :is_dental_only, Boolean, tag: "is_dental_only"
        element :premium_total_amount, String, tag: "premium_total_amount"
        element :total_responsible_amount, String, tag: "total_responsible_amount"
        
        # <shop_market>
        # <individual_market>
      end
    end
  end
end