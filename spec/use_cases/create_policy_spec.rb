require 'spec_helper'

class PlanRepository
  def find(id)
    Plan.find(id)
  end
end

describe CreatePolicy do
  subject(:use_case) { CreatePolicy.new(plan_repo) }

  let(:request) {
    {
      plan_id: plan.id,
      carrier_id: carrier_id,
      employer_id: employer_id,
      broker_id: broker_id,
      responsible_party_id: responsible_party_id,
      credit: credit,
      carrier_to_bill: carrier_to_bill,
      enrollees: enrollees,
      transmit_to_carrier: transmit_to_carrier,
      household_id: household_id
    } 
  }

  let(:plan_repo) { double(find: plan) }
  let(:plan) { double(id: '1234', rate: premium)}
  let(:premium) { 22.0 }
  let(:carrier_id) { '4321' }
  let(:employer_id) { '1111' }
  let(:broker_id) { '2222' }
  let(:responsible_party_id) { '3333' }
  let(:credit) { 200.0 }
  let(:carrier_to_bill) { true }
  let(:enrollees){ [
      { 
        member_id: '1234',
        coverage_start: Date.new(2014, 1, 1),
        birth_date: Date.new(1980, 1, 1),
        relationship: 'self'
      }
    ]}
  let(:transmit_to_carrier) { true }
  let(:household_id) { '5555'}

  it 'saves a requested policy' do
    expect { use_case.execute(request) }.to change(Policy, :count).by 1
  end

  it 'associates policy with requested plan' do
    use_case.execute(request)
    expect(Policy.last.plan_id).to eq plan.id
  end

  it 'associates policy with requested carrier' do
    use_case.execute(request)
    expect(Policy.last.carrier_id).to eq carrier_id
  end

  it 'associates policy with household' do
    use_case.execute(request)
    expect(Policy.last.household_id).to eq household_id
  end

  context 'when employer is provided' do
    let(:employer_id) { '111' }
    it 'associates policy with an employer' do
      use_case.execute(request)
      expect(Policy.last.employer_id).to eq employer_id
    end

    it 'accepts credit as employer responsible amount' do
      use_case.execute(request)
      expect(Policy.last.tot_emp_res_amt.to_f.round(2)).to eq credit
    end
  end

  context 'when employer NOT provided' do
    let(:employer_id) { nil }
    it 'accepts credit as APTC' do
      use_case.execute(request)
      expect(Policy.last.applied_aptc.to_f.round(2)).to eq credit
    end
  end

  it 'associates policy with a broker' do
    use_case.execute(request)
    expect(Policy.last.broker_id).to eq broker_id
  end

  it 'associates policy with responsible party' do
    use_case.execute(request)
    expect(Policy.last.responsible_party_id).to eq responsible_party_id
  end

  it 'sets carrier to bill' do
    use_case.execute(request)
    expect(Policy.last.carrier_to_bill).to eq carrier_to_bill
  end

  it 'enrolls people in policy' do
    use_case.execute(request)
    policy = Policy.last
    policy.enrollees.each_with_index do |enrollee, index|
      expect(enrollee.m_id).to eq enrollees[index][:member_id]
      expect(enrollee.coverage_start).to eq enrollees[index][:coverage_start]
      expect(enrollee.rel_code).to eq enrollees[index][:relationship]
    end
  end

  it 'calculates premium rate for enrollees' do
    expect(plan).to receive(:rate).with(enrollees.first[:coverage_start], 
      enrollees.first[:coverage_start], 
      enrollees.first[:birth_date])
    use_case.execute(request)

    policy = Policy.last

    expect(policy.enrollees.first.pre_amt).to eq premium
  end

  # describe 'carrier transmission' do
  #   context 'when not specified to transmit' do
  #     let(:transmit_to_carrier) { false }
  #     it 'does not notify the carrier' do
  #       expect(carrier_notifier).not_to receive(:notify)
  #       use_case.execute(request)
  #     end
  #   end

  #   context 'when specified to transmit' do
  #     let(:transmit_to_carrier) { true }
  #     it 'notifies the carrier' do
  #       expect(carrier_notifier).to receive(:notify)
  #       use_case.execute(request)
  #     end
  #   end
  # end
 
  
end
