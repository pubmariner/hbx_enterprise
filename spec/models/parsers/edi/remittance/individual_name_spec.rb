require './app/models/parsers/edi/remittance/individual_name'

describe Parsers::Edi::Remittance::IndividualName do
  subject(:individual_name) { Parsers::Edi::Remittance::IndividualName.new(raw_loop) }

  let(:enrollment_group_id) { '6666666' }
  let(:hios_plan_id) { '7777777' }

  let(:raw_loop) do
    {
      "REFs" => [
        ['', 'POL', enrollment_group_id],
        ['', 'TV', hios_plan_id]
      ]
    }
  end

  it 'exposes the enrollment group id' do
    expect(individual_name.enrollment_group_id).to eq enrollment_group_id
  end

  it 'exposes the hios plan id' do
    expect(individual_name.hios_plan_id).to eq hios_plan_id
  end
end
