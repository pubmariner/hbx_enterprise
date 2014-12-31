require 'spec_helper'

describe EnrollmentVerifier do

  before(:each) do

  end

  context "valid xml" do
    it 'should test the xml against the schema' do
      @xml_path = File.join(PADRINO_ROOT, 'spec', 'data', 'lib', 'enrollment.xml')
      @xml = File.read(@xml_path)
      expect(EnrollmentVerifier.is_valid_xml?(@xml)).to eq(true)
    end
  end

  context "invalid xml" do
    it 'should test the xml against the schema' do
      @xml_path = File.join(PADRINO_ROOT, 'spec', 'data', 'lib', 'invalid_enrollment.xml')
      @xml = File.read(@xml_path)
      expect(EnrollmentVerifier.is_valid_xml?(@xml)).to eq(false)
    end
  end

end