module Parsers
  class EnrollmentEventParser
    XMLNS = {
      "de" => "http://xmlns.dc.gov/DCAS/Event/Notifications/V1"
    }

    PROPERTIES = {
      "PERSON_UPDATE" => ["urn:openhbx:requests:v1:individual#update", "update"],
      "INDIVIDUAL_DISENROLLMENT" => ["urn:openhbx:requests:v1:individual#withdraw_qhp", "withdraw_qhp"],
    }

    class EnrollmentEvent
      def initialize(xml)
        @xml = xml
        raise(StandardError.new("Unknown event!")) unless PROPERTIES.has_key?(event_type)
      end

      def event_type
        @xml.xpath("//de:EligibilityEventOperation", XMLNS).first.text.strip
      end

      def event_uri
        PROPERTIES[event_type].first
      end

      def routing_key
        PROPERTIES[event_type].last
      end

      def timestamp
        @xml.xpath("//de:EventDate", XMLNS).first.text.strip + "T05:00:00"
      end

      def person_id
        @xml.xpath("//de:EventID", XMLNS).first.text.strip
      end
    end

    def parse(input)
      EnrollmentEvent.new(Nokogiri::XML(input))
    end
 end
end
