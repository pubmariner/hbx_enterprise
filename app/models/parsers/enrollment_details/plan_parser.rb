module Parsers
  module EnrollmentDetails
    class PlanParser

      def initialize(node)
        @xml = node
        @market = ""
        @broker = {}
      end

      def market=(market_type)
        @market = market_type
      end

      def market
        @market
      end

      def broker=(broker)
        @broker = broker
      end

      def broker
        @broker
      end

      def has_broker?
        !@broker.empty?
      end

      def plan_name
        @xml.at_xpath("plan/plan-name").text
      end

      def hios_id
        @xml.at_xpath("plan/plan-id").text
      end

      def dental?
        Maybe.new(@xml.at_xpath("plan/product-line")).text.downcase.value == "dental"
      end

      def premium_total
        Maybe.new(@xml.at_xpath("plan/premium")).text.value
      end

      def carrier_display_name
        Maybe.new(@xml.at_xpath("plan/plan-carrier/carrier-name")).text.value
      end

      def carrier_active
        true
      end

      def benefit_coverage_name_type
        "urn:openhbx:terms:v1:benefit_coverage##{Maybe.new(@xml.at_xpath("plan/product-line")).text.downcase.value}"
      end

      def metal_level
        "urn:openhbx:terms:v1:plan_metal_level##{Maybe.new(@xml.at_xpath("plan/plan-tier")).text.downcase.value}"
      end

      def ehb_percent
        Maybe.new(@xml.at_xpath("plan/ehb-percent")).text.value
      end

      def person_premiums_with_person_ids
        results = {}
        @xml.xpath("plan/person-premiums/person-premium").each do |node|
          person_id = node.at_xpath("person-id").text
          value = node.at_xpath("premium").text
          results[person_id] = value
        end
        results
      end

      def person_premiums(idMapping = Services::IdMapping)
      results = {}
       person_premiums_with_person_ids.each do |person_id, premium|
          #results[Maybe.new(idMapping.from_person_id(person_id)).value] = premium
          results[idMapping.from_person_id(person_id)] = premium
       end
      results
      end

      def plan_year
        plan_id_year = Maybe.new(@xml.at_xpath("plan/plan-id-year")).text.value
        plan_id_year.split(//).last(4).join
      end


      def self.build(xml_node)
        self.new(xml_node)
      end
    end
  end
end
