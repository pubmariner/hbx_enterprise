require 'spec_helper'

describe Parsers::Edi::FindPlan do
  context 'plan doesn\'t exist' do
    it 'notifies listener of plan not found by fein' do
      listener = double
      find_plan = Parsers::Edi::FindPlan.new(listener)

      expect(listener).to receive(:plan_not_found)
      expect(find_plan.by_hios_id('6666')).to be_nil
    end
  end

  context 'plan exists' do
    it 'notifies listener of plan found by fein' do
      plan = create :plan

      listener = double
      find_plan = Parsers::Edi::FindPlan.new(listener)

      expect(listener).to receive(:plan_found)
      expect(find_plan.by_hios_id(plan.hios_plan_id)).to eq plan
    end
  end

end
