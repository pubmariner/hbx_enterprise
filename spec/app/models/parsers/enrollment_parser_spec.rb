require "spec_helper"

describe Parsers::Xml::Cv::EnrollmentParser do
  let(:enrollment) {
    f = File.open(File.join(Padrino.root, "spec", "data", "parsers", "shop_enrollment.xml"))
    f.read
  }

  subject {
    Parsers::Xml::Cv::EnrollmentParser.parse(enrollment, :single => true)
  }


  it 'should return enrollees' do 
    expect(subject.enrollees.size).to eq(3)
    expect(subject.enrollees[0]).to be_a_kind_of(Parsers::Xml::Cv::EnrolleeParser)
  end

  it 'should return hbx enrollment' do
    expect(subject.hbx_enrollment).to_not be_nil
    expect(subject.hbx_enrollment).to be_a_kind_of(Parsers::Xml::Cv::HbxEnrollmentParser)
  end
end