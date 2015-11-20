module Parsers
  module Xml
    module Cv
      class WritingAgent
        include HappyMapper

        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'writing_agent'
        namespace 'cv'

        element :npn, String, tag: "npn"

        def to_hash
          {
              npn: npn,
          }
        end
      end
    end
  end
end