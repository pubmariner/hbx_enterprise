require "spec_helper"

describe LegacyEmployerXmlAdapter do

  let(:xml) {File.read("spec/data/parsers/employer_legacy_digest_transformer_test_data.xml")}
  let(:subject) {LegacyEmployerXmlAdapter.new(xml)}
  it 'should do something' do
      expect(subject.create_output).to be_a Hash
  end
end