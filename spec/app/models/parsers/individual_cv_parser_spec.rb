require 'spec_helper'

describe Parsers::IndividualCvParser do

  before(:all) do
    @xml = File.read("/Users/CitadelFirm/Downloads/projects/hbx/hbx_enterprise/spec/data/parsers/individual_cv.xml")
  end

  it 'initializes successfully' do
    individual_cv_parser = Parsers::IndividualCvParser.new(@xml)
    expect(individual_cv_parser.class).to eq(Parsers::IndividualCvParser)
  end

  it 'supports parse method' do
    individual_cv_parser = Parsers::IndividualCvParser.new(@xml)
    expect(individual_cv_parser.parser.nil?).to eq(false)
  end
end