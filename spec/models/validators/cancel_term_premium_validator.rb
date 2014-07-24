require 'spec_helper'

describe Validators::CancelTermPremiumTotalValidator do
  subject(:validator) { Validators::CancelTermPremiumTotalValidator.new(change_request, listener) }
  let(:change_request) { double }
  let(:listener) { double }

  describe 'expected total amount' do
    context 'when subscriber is affected' do
      before do
        change_request.stub(:subscriber_affected?) { true }
        change_request.stub(:enrollee_premium_sum) { 222.22 }
      end
      its 'calculated as sum of all enrollee amounts' do
        expect(validator.expected_total).to eq 222.22
      end
    end
  end
  context 'when subscriber is not affected' do
    before do
        change_request.stub(:subscriber_affected?) { false }
        change_request.stub(:enrollee_premium_sum) { 222.22 }
        change_request.stub(:affected_enrollees_sum) { 22.22 }
      end

    it 'calculates expected amount is adjusted by affected enrollees sum' do
      expect(validator.expected_total).to eq 200.00
    end
  end
  context 'when total premium is incorrect' do
    before do
      change_request.stub(:subscriber_affected?) { true }
      change_request.stub(:enrollee_premium_sum ) { 325.251 }
      change_request.stub(:premium_amount_total) { 666.66 }
    end
    it 'notifies listener' do
      expect(listener).to receive(:group_has_incorrect_premium_total).with({provided: 666.66, expected: 325.25})
      expect(validator.validate).to eq false
    end
  end

  context 'when total premium is correct' do
    before do
      change_request.stub(:subscriber_affected?) { true }
      change_request.stub(:enrollee_premium_sum ) { 325.251 }
      change_request.stub(:premium_amount_total) { 325.25 }
    end
    it 'does not notify listener' do
      expect(listener).not_to receive(:group_has_incorrect_premium_total)
      expect(validator.validate).to eq true
    end
  end
end
