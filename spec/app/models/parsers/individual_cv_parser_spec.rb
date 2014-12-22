require 'spec_helper'

describe Parsers::IndividualCvParser do

  let(:dcas_object){
    double()
  }

  before :each do
    allow(dcas_object).to receive(:relationships).and_return({})
    allow(dcas_object).to receive(:begin_date).and_return("20141201")
    allow(dcas_object).to receive(:end_date).and_return("20141201")
  end

  before(:all) do
    @xml = File.read("/Users/CitadelFirm/Downloads/projects/hbx/hbx_enterprise/spec/data/parsers/individual_cv.xml")
    @individual_cv_parser = Parsers::IndividualCvParser.new(@xml, nil, nil)
  end



  subject {
    @individual_cv_parser = Parsers::IndividualCvParser.new(@xml, nil, dcas_object)
  }

  it 'initializes successfully' do
    expect(@individual_cv_parser.class).to eq(Parsers::IndividualCvParser)
  end

  it 'supports parse method' do
    expect(@individual_cv_parser.parser.nil?).to eq(false)
  end

  it 'parses person element' do
    expect(@individual_cv_parser.parser.person.nil?).to eq(false)
  end

  it 'parses person demographic element' do
    expect(@individual_cv_parser.parser.person_demographics.ssn.nil?).to eq(false)
    expect(@individual_cv_parser.parser.person_demographics.sex.nil?).to eq(false)
    expect(@individual_cv_parser.parser.person_demographics.birth_date.nil?).to eq(false)
    expect(@individual_cv_parser.parser.person_demographics.death_date.nil?).to eq(true)
    expect(@individual_cv_parser.parser.person_demographics.ethnicity.nil?).to eq(true)
    expect(@individual_cv_parser.parser.person_demographics.marital_status.nil?).to eq(true)
    expect(@individual_cv_parser.parser.person_demographics.citizen_status.nil?).to eq(false)
    expect(@individual_cv_parser.parser.person_demographics.is_state_resident.nil?).to eq(true)
    expect(@individual_cv_parser.parser.person_demographics.is_incarcerated.nil?).to eq(true)
  end

  it "parses addresses correctly" do
    expect(@individual_cv_parser.address[:address_line_1]).to eq("212 Nice Avenue NW")
    expect(@individual_cv_parser.address[:address_line_2]).to eq("")
    expect(@individual_cv_parser.address[:city]).to eq("Washington")
    expect(@individual_cv_parser.address[:state]).to eq("DC")
    expect(@individual_cv_parser.address[:zip]).to eq("20001")
  end

  it "parses phone number correctly" do

    expect(@individual_cv_parser.phone[:country_code]).to be_nil
    expect(@individual_cv_parser.phone[:area_code]).to be_nil
    expect(@individual_cv_parser.phone[:extension]).to be_nil
    expect(@individual_cv_parser.phone[:phone_number]).to be_nil
    expect(@individual_cv_parser.phone[:full_phone_number]).to eq("919-919-9199225652")
    expect(@individual_cv_parser.phone[:is_preferred]).to eq("true")
    expect(@individual_cv_parser.phone[:type]).to eq("urn:openhbx:terms:v1:phone_type#home")
  end

  it "returns email" do

  end

  it "returns begin and end dates from dcas_person" do
    expect(subject.begin_date).to eq("20141201")
    expect(subject.end_date).to eq("20141201")
  end

  it "returns relationships from dcas person" do
    expect(subject.relationships.class).to eq(Hash)
  end
end