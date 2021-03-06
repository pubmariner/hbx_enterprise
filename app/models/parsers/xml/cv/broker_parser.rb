module Parsers
  module Xml
    module Cv
      class BrokerParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'broker'
        namespace 'cv'

        element :broker_npn, String, tag: "id/cv:id"        
        element :name, String, tag: "name"

        def to_hash
          {
              npn: broker_npn,
              name: name
          }
        end
      end
    end
  end
end