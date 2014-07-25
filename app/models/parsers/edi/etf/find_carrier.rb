module Parsers
  module Edi
    class FindCarrier
      def initialize(listener, i_cache)
        @listener = listener
        @import_cache = i_cache
      end

      def by_fein(fein)
        carrier = @import_cache.lookup_carrier_fein(fein)
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
