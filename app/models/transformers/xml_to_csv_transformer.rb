module Transformers
  class XmlToCsvTransformer
    def initialize(cv)
    end

    # returns 1 row for each policy
    def transform

    end

    def transform_single_policy(xml, is_shop)
      enrollment = Parsers::Xml::Cv::EnrollmentParser.parse(xml)
      builder = EnrollmentRowBuilder.new(enrollment, is_shop)
      builder.to_csv
    end
  end
end
