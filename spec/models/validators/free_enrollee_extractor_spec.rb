require 'spec_helper'

describe Validators::FreeEnrolleeExtractor do
  let(:ceiling) { 5 }
  context 'when there are not enough enrollees' do
    let(:enrollees) { [double]}
    it 'returns none' do
      free_enrollees = Validators::FreeEnrolleeExtractor.new(ceiling).extract_from!(enrollees)
      expect(free_enrollees).to eq []
    end
  end
  context 'when there are more than 5 enrollees' do
    let(:free_one) { double(age: 1) }
    let(:free_two) { double(age: 2) }
    # let(:enrollees) { }
    it 'excludes the 5 oldest enrollees' do
      enrollees = [free_one, free_two, double(age: 40), double(age: 30), double(age: 20), double(age: 10), double(age: 9)]
      free_enrollees = Validators::FreeEnrolleeExtractor.new(ceiling).extract_from!(enrollees)
      expect(free_enrollees).to include free_one
      expect(free_enrollees).to include free_two
      expect(enrollees.count).to eq 5
    end
  end

end
