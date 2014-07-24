module Parsers
  module Edi
    module Etf
      class Category
        def initialize(category)
          @loop = category
        end

        def name
          @loop["N1"][2]
        end

        def value
          @loop['REF'][2]
        end
      end
    end
  end
end
