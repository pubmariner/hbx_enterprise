module CanonicalVocabulary
  class MaintenanceSerializer

    CV_XMLNS = {
      "xmlns:pln" => "http://dchealthlink.com/vocabularies/1/plan",
      "xmlns:ins" => "http://dchealthlink.com/vocabularies/1/insured",
      "xmlns:car" => "http://dchealthlink.com/vocabularies/1/carrier",
      "xmlns:con" => "http://dchealthlink.com/vocabularies/1/contact",
      "xmlns:bt" => "http://dchealthlink.com/vocabularies/1/base_types",
      "xmlns:emp" => "http://dchealthlink.com/vocabularies/1/employer",
      "xmlns:proc" => "http://dchealthlink.com/vocabularies/1/process",
      "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
      "xsi:schemaLocation" =>"http://dchealthlink.com/vocabularies/1/process process.xsd      http://dchealthlink.com/vocabularies/1/insured insured.xsd      http://dchealthlink.com/vocabularies/1/plan plan.xsd      http://dchealthlink.com/vocabularies/1/employer employer.xsd     http://dchealthlink.com/vocabularies/1/carrier carrier.xsd     http://dchealthlink.com/vocabularies/1/contact contacts.xsd     http://dchealthlink.com/vocabularies/1/base_types.xsd base_types.xsd"
    }

    def initialize(policy, op, reas, m_ids, include_m_ids, opts={})
      @options = opts
      @operation = op
      @policy = policy
      @reason = reas
      @member_ids = m_ids
      @included_members_ids = include_m_ids
    end

    def serialize
      en_ser = CanonicalVocabulary::EnrollmentSerializer.new(@policy, @included_members_ids, @options)
      builder = Nokogiri::XML::Builder.new do |xml|
        xml['proc'].Operation(CV_XMLNS) do |xml|
          xml['proc'].operation do |xml|
            xml['proc'].type(@operation)
            xml['proc'].reason(@reason)
            xml['proc'].affected_members do |xml|
              @member_ids.each do |m|
                xml['proc'].member_id(m)
              end
            end
          end
          xml['proc'].payload do |xml|
            en_ser.builder(xml)
          end
        end
      end
      builder.to_xml(:indent => 2)
    end
  end
end
