module Parsers
class IndividualCvParser

  attr_reader :parser

  def initialize(xml)
    @parser = Parsers::Xml::Cv::IndividualParser.parse(xml)
  end
end
end