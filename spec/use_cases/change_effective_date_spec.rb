require 'spec_helper'

describe ChangeEffectiveDate do
  subject(:change_effective_date) { ChangeEffectiveDate.new(policy_repo) }
  let(:policy_repo) { double(find: policy) }
  let(:policy) { double(enrollees: enrollees, save!: true)}
  let(:request) do
    {
      policy_id: '1234',
      effective_date: Date.today.next_month
    }
  end

  let(:enrollees) { [ subscriber ] }
  let(:subscriber) { Enrollee.new(coverage_start: Date.today) }
  let(:listener) { double(success: nil) }

  it 'finds the policy' do
    expect(policy_repo).to receive(:find).with(request[:policy_id])
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

  context "when policy doesn't exist" do
    let(:policy_repo) { double(find: nil) }
    let(:listener) { double(no_such_policy: nil, fail: nil) }

    it 'notifies the listener' do
      expect(listener).to receive(:no_such_policy)
      expect(listener).to receive(:fail)
      subject.execute(request, listener)
    end

    it "doesn't save the policy" do
      expect(policy).not_to receive(:save!)
      subject.execute(request, listener)
    end
  end

  context 'when enrollee is canceled' do
    let(:listener) { double(policy_inactive: nil, fail: nil)}
    let(:subscriber) { Enrollee.new(coverage_start: Date.today, coverage_end: Date.today) }
    
    it 'notifies the listener' do
      expect(listener).to receive(:policy_inactive)
      expect(listener).to receive(:fail)
      subject.execute(request, listener)
    end
    it 'doesnt save the policy' do
      expect(policy).not_to receive(:save!)
      subject.execute(request, listener)
    end
  end
  
  context 'when enrollee is terminated' do
    let(:listener) { double(policy_inactive: nil, fail: nil)}
    let(:subscriber) { Enrollee.new(coverage_start: Date.today, coverage_end: Date.today.next_month) }

    it 'notifies the listener' do
      expect(listener).to receive(:policy_inactive)
      expect(listener).to receive(:fail)
      subject.execute(request, listener)
    end
    it "doesn't save the policy" do
      expect(policy).not_to receive(:save!)
      subject.execute(request, listener)
    end
  end

  context 'when enrollee already has requested effective date' do
    let(:listener) { double(no_changes_needed: nil, fail: nil)}
    let(:subscriber) { Enrollee.new(coverage_start: request[:effective_date]) }

    it 'notifies the listener' do
      expect(listener).to receive(:no_changes_needed)
      expect(listener).to receive(:fail)
      subject.execute(request, listener)
    end

    it "doesn't save the policy" do
      expect(policy).not_to receive(:save!)
      subject.execute(request, listener)
    end
  end
end
