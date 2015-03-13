module Parsers
  module Xml
    module Cv
      class HbxEnrollmentParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'enrollment'
        namespace 'cv'

        element :premium_total_amount, String, tag: "premium_total_amount"
        element :total_responsible_amount, String, tag: "total_responsible_amount"

        has_one :plan, Parsers::Xml::Cv::EnrollmentPlanParser, tag: "plan"
        has_one :shop_market, Parsers::Xml::Cv::ShopMarketParser, tag: "shop_market"
        has_one :individual_market, Parsers::Xml::Cv::IndividualMarketParser, tag: "individual_market"
      end
    end
  end
end