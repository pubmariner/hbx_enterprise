require "spec_helper"

describe Parsers::Xml::Cv::IndividualParser do
  let(:enrollment) {
    f = File.open(File.join(Padrino.root, "spec", "data", "parsers", "shop_enrollment.xml"))
    f.read
  }

  let(:relationship_uri1) { "urn:openhbx:terms:v1:individual_relationship#self" }
  let(:relationship_uri2) { "urn:openhbx:terms:v1:individual_relationship#child" }

  subject {
    Parsers::Xml::Cv::EnrollmentParser.parse(enrollment, :single => true)
  }

  let(:individual1) { subject.policy.enrollees[0].member }
  let(:individual2) { subject.policy.enrollees[1].member }

  it 'should have a plan and shop_market' do
    expect(individual1.person).to be_a_kind_of(Parsers::Xml::Cv::PersonParser)
    expect(individual1.person_demographics).to be_a_kind_of(Parsers::Xml::Cv::PersonDemographicsParser)
  end

  it 'should return relationships' do
    expect(individual1.relationship_uri).to eq(relationship_uri1)
    expect(individual2.relationship_uri).to eq(relationship_uri2)
  end
end