module Parsers
  module Xml
    module Cv
      class BrokerAgency
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'broker_agency'
        namespace 'cv'

        element :npn, String, tag: "npn"
        element :id, String, tag: "id/cv:id"

        def to_hash
          {
              npn: npn,
              id: id,
          }
        end
      end
    end
  end
end