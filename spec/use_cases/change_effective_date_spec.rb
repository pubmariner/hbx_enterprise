require 'spec_helper'

describe ChangeEffectiveDate do
  subject(:change_effective_date) { ChangeEffectiveDate.new(transmitter, policy_repo) }
  let(:policy_repo) { double(where: double(first: policy)) }
  let(:policy) { double(id: '1234', enrollees: enrollees, save!: true, subscriber: subscriber)}
  let(:request) do
    {
      policy_id: '1234',
      effective_date: Date.today.next_month,
      current_user: current_user
    }
  end

  let(:enrollees) { [ subscriber, other_enrollee ] }
  let(:other_enrollee) { Enrollee.new(coverage_start: Date.today, m_id: "4231") }
  let(:subscriber) { Enrollee.new(coverage_start: Date.today, m_id: "5324", "rel_code" => "self") }
  let(:listener) { double(success: nil) }
  let(:transmitter) { double(execute: nil ) }
  let(:transmit_request) do
    {
      policy_id: policy.id,
      operation: 'change',
      reason: 'benefit_selection',
      affected_enrollee_ids: affected_enrollee_ids,
      include_enrollee_ids: affected_enrollee_ids,
      current_user: current_user 
    }
  end
  let(:affected_enrollee_ids) { [subscriber.m_id, other_enrollee.m_id] }

  let(:current_user) { 'me@example.com' }

  it 'finds the policy' do
    expect(policy_repo).to receive(:where).with({"_id" => request[:policy_id]})
    subject.execute(request, listener)
  end

  it 'changes all enrollees' do
    expect(policy).to receive(:save!)

    subject.execute(request, listener)
    
    enrollees.each do |enrollee|
      expect(enrollee.coverage_start).to eq request[:effective_date]
    end
  end

  it 'notifies listener' do
    expect(listener).to receive(:success)
    subject.execute(request, listener)
  end

  it 'transmits the changes' do
    expect(transmitter).to receive(:execute).with(transmit_request)
    subject.execute(request, listener)
  end

  context "when policy doesn't exist" do
    let(:policy_repo) { double(where: double(first: nil)) }
    let(:listener) { double(no_such_policy: nil, fail: nil) }

    it 'notifies the listener' do
      expect(listener).to receive(:no_such_policy).with(policy_id: request[:policy_id])
      expect(listener).to receive(:fail)
      subject.execute(request, listener)
    end

    it "doesn't save the policy" do
      expect(policy).not_to receive(:save!)
      subject.execute(request, listener)
    end
  end

  context 'when subscriber is canceled' do
    let(:listener) { double(policy_inactive: nil, fail: nil)}
    let(:subscriber) { Enrollee.new(coverage_start: Date.today, coverage_end: Date.today) }
    
    it 'notifies the listener' do
      expect(listener).to receive(:policy_inactive).with(policy_id: request[:policy_id])
      expect(listener).to receive(:fail)
      subject.execute(request, listener)
    end
    it "doesn't save the policy" do
      expect(policy).not_to receive(:save!)
      subject.execute(request, listener)
    end
  end
  
  context 'when subscriber is terminated' do
    let(:listener) { double(policy_inactive: nil, fail: nil)}
    let(:subscriber) { Enrollee.new(coverage_start: Date.today, coverage_end: Date.today.next_month) }

    it 'notifies the listener' do
      expect(listener).to receive(:policy_inactive).with(policy_id: request[:policy_id])
      expect(listener).to receive(:fail)
      subject.execute(request, listener)
    end
    it "doesn't save the policy" do
      expect(policy).not_to receive(:save!)
      subject.execute(request, listener)
    end
  end

  context 'when subscriber already has requested effective date' do
    let(:listener) { double(no_changes_needed: nil, fail: nil)}
    let(:subscriber) { Enrollee.new(coverage_start: request[:effective_date]) }

    it 'notifies the listener' do
      expect(listener).to receive(:no_changes_needed).with(policy_id: request[:policy_id])
      expect(listener).to receive(:fail)
      subject.execute(request, listener)
    end

    it "doesn't save the policy" do
      expect(policy).not_to receive(:save!)
      subject.execute(request, listener)
    end
  end

  context "when the other enrollee is cancelled" do
    let(:other_enrollee) { Enrollee.new(coverage_start: Date.today, coverage_end: Date.today, m_id: "4231") }

    let(:affected_enrollee_ids) { [subscriber.m_id] }
    it 'changes only the subscriber' do

      expect(policy).to receive(:save!)

      subject.execute(request, listener)

      expect(subscriber.coverage_start).to eq request[:effective_date]
      expect(other_enrollee.coverage_start).not_to eq request[:effective_date]
    end

    it 'notifies listener' do
      expect(listener).to receive(:success)
      subject.execute(request, listener)
    end

    it 'transmits the changes' do
      expect(transmitter).to receive(:execute).with(transmit_request)
      subject.execute(request, listener)
    end
  end

  context "when the other enrollee is terminated" do
    let(:other_enrollee) { Enrollee.new(coverage_start: Date.today, coverage_end: Date.today.next_month, m_id: "4231") }
    let(:listener) { double(ambiguous_terminations: nil, fail: nil) }
    it 'notifies the listener' do
      expect(listener).to receive(:ambiguous_terminations).with({:policy_id => request[:policy_id], :member_ids => [other_enrollee.m_id]})
      expect(listener).to receive(:fail)
      subject.execute(request, listener)
    end

    it "doesn't save the policy" do
      expect(policy).not_to receive(:save!)
      subject.execute(request, listener)
    end
  end

  context "when the other enrollee has a different coverage_start" do
    let(:other_enrollee) { Enrollee.new(coverage_start: Date.today.next_month, m_id: "4231") }
    let(:listener) { double(start_date_mismatch: nil, fail: nil) }

    it 'notifies the listener' do
      expect(listener).to receive(:start_date_mismatch).with({:policy_id => request[:policy_id], :coverage_start => [subscriber.coverage_start, other_enrollee.coverage_start]})
      expect(listener).to receive(:fail)
      subject.execute(request, listener)
    end

    it "doesn't save the policy" do
      expect(policy).not_to receive(:save!)
      subject.execute(request, listener)
    end
  end
end
