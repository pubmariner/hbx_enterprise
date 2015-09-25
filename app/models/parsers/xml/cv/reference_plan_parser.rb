module Parsers
  module Xml
    module Cv
      class ReferencePlanParser
        include HappyMapper
        register_namespace "cv", "http://openhbx.org/api/terms/1.0"
        tag 'reference_plan'
        namespace 'cv'

        element :id, String, tag: "id/cv:id"
        element :coverage_type, String, tag: "coverage_type"
        element :name, String, tag: "name"
        element :active_year, String, tag: "active_year"
        element :is_dental_only, String, tag: "is_dental_only"
        has_one :carrier, Parsers::Xml::Cv::CarrierParser, tag: 'carrier'

        def to_hash

          response = {
              coverage_type: coverage_type,
              name: name,
              active_year: active_year,
              is_dental_only: is_dental_only
          }

          response[:carrier] = carrier.to_hash if carrier
          response[:id] = id.split('#').last
          response[:id] = response[:id].split('/').last
          response
        end
      end
    end
  end
end

