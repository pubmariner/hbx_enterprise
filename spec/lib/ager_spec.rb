require './lib/ager'

describe Ager do
  let(:birth_date) { Date.new(1980,2,25) }
  let(:ager) { Ager.new(birth_date) }

  it 'calculates the age as of a given date' do
    #same date as birth
    expect(ager.age_as_of(birth_date)).to eq 0

    # years later on birthday
    expect(ager.age_as_of(Date.new(1990,2,25))).to eq 10

    # days before birthday
    expect(ager.age_as_of(Date.new(1990,2,24))).to eq 9
    expect(ager.age_as_of(Date.new(1991,2,23))).to eq 10

    # months before birthday
    expect(ager.age_as_of(Date.new(1990,1,25))).to eq 9
    expect(ager.age_as_of(Date.new(1991,1,25))).to eq 10

    # month after birthday
    expect(ager.age_as_of(Date.new(1990,3,1))).to eq 10
  end
end
