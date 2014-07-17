require 'spec_helper'

describe Validators::PremiumResponsibleValidator do
  subject(:validator) { Validators::PremiumResponsibleValidator.new(enrollment_group, listener) }
  
  let(:enrollment_group) { double(premium_amount_total: premium_amount_total, credit: credit, total_responsible_amount: total_responsible_amount) }
  let(:premium_amount_total) { 347.64 }
  let(:credit) { 252.1 }
  let(:total_responsible_amount) { 95.54 }
  let(:listener) { double }
  
  context 'when responsible amount is correct' do
    it 'does not notify the listener' do
      expect(listener).not_to receive(:invalid_responsible_amount)
      validator.validate
      expect(validator.validate).to eq true
    end
  end
  
  context 'when responsible amount is incorrect' do
    let(:total_responsible_amount) { 6666.66 }

    it 'notifies the listener' do
      expect(listener).to receive(:group_has_incorrect_responsible_amount).with({provided: total_responsible_amount, expected: 95.54})
      expect(validator.validate).to eq false
    end
  end

  
end
