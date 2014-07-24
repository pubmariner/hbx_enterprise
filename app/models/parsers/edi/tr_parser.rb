module Parsers
  module Edi
    class TrParser
      include Singleton

      attr_reader :parser
      def initialize
        @parser = X12::Parser.new("TA1.xml")
      end
    end
  end
end
