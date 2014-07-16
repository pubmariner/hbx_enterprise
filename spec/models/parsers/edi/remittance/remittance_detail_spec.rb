require './app/models/parsers/edi/remittance/remittance_detail'
describe Parsers::Edi::Remittance::RemittanceDetail do
  subject(:remittance_detail) { Parsers::Edi::Remittance::RemittanceDetail.new(raw_loop) }

  let(:payment_type) { 'PREM' }
  let(:coverage_period) { '20140701-20140731' }
  let(:amount) { '666.66' }
  let(:raw_loop) do  
    { 
      'RMR' => ['','', payment_type, '', amount],
      'DTM' => ['', '', '', '', '', '', coverage_period] 
    }
  end

  it 'exposes the payment type' do
    expect(remittance_detail.payment_type).to eq payment_type
  end

  it 'exposes the coverage period' do
    expect(remittance_detail.coverage_period).to eq coverage_period
  end

  it 'exposes the payment amount' do
    expect(remittance_detail.payment_amount).to eq amount

  end
end
