module Parsers
  module Xml
    module Cv
      class BrokerParser
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'enrollment'
        namespace 'cv'

      end
    end
  end
end