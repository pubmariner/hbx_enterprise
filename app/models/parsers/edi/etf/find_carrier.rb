module Parsers
  module Edi
    class FindCarrier
      def initialize(listener)
        @listener = listener
      end

      def by_fein(fein)
        carrier = Carrier.for_fein(fein)
        if(carrier)
          @listener.carrier_found(carrier)
          carrier
        else
          @listener.carrier_not_found(fein)
          nil
        end
      end
    end
  end
end
