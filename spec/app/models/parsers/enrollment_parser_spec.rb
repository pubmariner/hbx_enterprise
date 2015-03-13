require "spec_helper"

describe Parsers::Xml::Cv::EnrollmentParser do
  let(:enrollment) {
    f = File.open(File.join(Padrino.root, "spec", "data", "parsers", "shop_enrollment.xml"))
    f.read
  }

  subject {
    Parsers::Xml::Cv::EnrollmentParser.parse(enrollment, :single => true)
  }


  it 'should return hbx enrollment' do
    expect(subject.policy).to_not be_nil
    expect(subject.policy).to be_a_kind_of(Parsers::Xml::Cv::PolicyParser)
  end
end