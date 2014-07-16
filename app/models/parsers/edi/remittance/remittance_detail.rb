module Parsers
  module Edi
    module Remittance
      class RemittanceDetail

        def initialize(l2300)
          @loop = l2300
        end

        def payment_type
          @loop["RMR"][2]
        end

        def coverage_period
          @loop["DTM"][6]
        end

        def payment_amount
          @loop["RMR"][4]
        end
      end
    end
  end
end
