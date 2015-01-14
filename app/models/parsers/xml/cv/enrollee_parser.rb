module Parsers
  module Xml
    module Cv
      class EnrolleeParser
        include HappyMapper
        tag 'enrollee'

        has_many :member, Parsers::Xml::Cv::IndividualParser, tag: "member"
      end
    end
  end
end