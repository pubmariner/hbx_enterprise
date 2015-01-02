=begin
    class EnrollmentVerifier

      POLICY_SCHEMA = File.join(PADRINO_ROOT, 'cv', 'policy.xsd')

      def self.is_valid_xml?(xml)
        begin
          xsd = Nokogiri::XML::Schema(File.read(POLICY_SCHEMA))
          doc = Nokogiri::XML(xml)

          xsd.validate(doc).each do |error|
            puts error.message
          end

          if xsd.validate(doc).size == 0 #the number of errors
            return true
          else
            return false
          end
        rescue Exception=>e
          puts e.message
          false
        end
      end

      #TODO to be implemented
      def self.is_root_valid?(xml)
        true
      end
    end
=end

class EnrollmentValidator < DocumentValidator

  POLICY_SCHEMA = File.join(PADRINO_ROOT, 'cv', 'policy.xsd')

  def initialize(xml)
    schema = Nokogiri::XML::Schema(File.open(POLICY_SCHEMA))
    xml_doc = Nokogiri::XML(xml)
    super(xml_doc, schema)
  end

end
