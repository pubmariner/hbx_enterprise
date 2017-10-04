module Parsers
  module Xml
    module Cv
      class BrokerAccountParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'broker_account'
        namespace 'cv'

        element :start_on, String, tag: "start_on"
        element :end_on, String, tag: "end_on"
        element :npn, String, tag: "npn",  tag: "writing_agent/cv:npn"


        def to_hash
          {
              start_on: start_on,
              end_on: end_on,
              npn: npn
          }
        end
      end
    end
  end
end