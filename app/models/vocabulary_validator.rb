class VocabularyValidator < DocumentValidator

  POLICY_SCHEMA = File.join(PADRINO_ROOT, 'vocabulary', 'vocabulary.xsd')

  def initialize(xml)
    schema = Nokogiri::XML::Schema(File.open(POLICY_SCHEMA))
    xml_doc = Nokogiri::XML(xml)
    super(xml_doc, schema)
  end

end
