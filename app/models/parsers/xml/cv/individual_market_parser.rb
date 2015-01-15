module Parsers
  module Xml
    module Cv
      class IndividualMarketParser
        include HappyMapper
        tag 'individual_market'

        element :is_carrier_to_bill, Boolean, tag: "is_carrier_to_bill"
        element :applied_aptc_amount, String, tag: "applied_aptc_amount"
      end
    end
  end
end