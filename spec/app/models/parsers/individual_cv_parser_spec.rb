require 'spec_helper'

describe Parsers::IndividualCvParser do

  before(:all) do
    @xml = File.read("/Users/CitadelFirm/Downloads/projects/hbx/hbx_enterprise/spec/data/parsers/individual_cv.xml")
    @individual_cv_parser = Parsers::IndividualCvParser.new(@xml)
  end

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
end