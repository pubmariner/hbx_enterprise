module Parsers
  module Edi
    class TsrParser
      include Singleton

      attr_reader :parser
      def initialize
        @parser = X12::Parser.new("999.xml")
      end
    end
  end
end
