module Parsers
  module Xml
    module Cv
      class ShopMarketParser
        include HappyMapper
        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        namespace 'cv'
        tag 'shop_market'

        element :employer_fein, String, tag: "employer_link/cv:id/cv:id"
        element :employer_name, String, tag: "employer_link/cv:name"
        element :employer_responsible_amount, String, tag: "total_employer_responsible_amount"
      end
    end
  end
end