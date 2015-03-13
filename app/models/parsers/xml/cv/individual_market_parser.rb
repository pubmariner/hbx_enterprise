module Parsers
  module Xml
    module Cv
      class IndividualMarketParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'individual_market'
        namespace 'cv'

        element :is_carrier_to_bill, Boolean, tag: "is_carrier_to_bill"
        element :applied_aptc_amount, String, tag: "applied_aptc_amount"
      end
    end
  end
end