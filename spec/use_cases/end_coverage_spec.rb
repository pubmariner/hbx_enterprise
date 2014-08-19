require 'spec_helper'

describe EndCoverage do
  subject(:end_coverage) { EndCoverage.new(listener, action_factory, policy_repo) }
  let(:request) do 
    { 
      policy_id: policy.id, 
      affected_enrollee_ids: affected_enrollee_ids,
      coverage_end: coverage_end,
      operation: operation,
      reason: 'death',
      current_user: current_user,
      action: 'transmit'
    } 
  end

  let(:action_request) do
    {
      policy_id: policy.id,
      operation: request[:operation],
      reason: request[:reason],
      affected_enrollee_ids: request[:affected_enrollee_ids],
      include_enrollee_ids: enrollees.map(&:m_id)
    }
  end

  let(:affected_enrollee_ids) { [subscriber.m_id, member.m_id] }
  let(:coverage_end) { Date.new(2014, 1, 14)}
  let(:operation) { 'cancel' }
  let(:current_user) { 'joe@example.com' }

  let(:policy_repo) { double(find: policy) }
  let(:policy) { Policy.create!(eg_id: '1', enrollees: enrollees, pre_amt_tot: premium_total) }
  let(:premium_total) { 1000.00 }
  let(:enrollees) { [ subscriber, member ]}
  let(:subscriber) { Enrollee.new(rel_code: 'self', coverage_start: coverage_start, pre_amt: 100.00, ben_stat: 'active', emp_stat: 'active',  m_id: '1') }
  let(:member) { Enrollee.new(rel_code: 'child', pre_amt: 200.00, ben_stat: 'active', emp_stat: 'active',  m_id: '2') }
  let(:listener) { double }

  let(:action_factory) { double(create_for: action) }
  let(:action) { double(execute: nil) }
  let(:coverage_start) { Date.new(2014, 1, 2)}

  it 'finds the policy' do
    expect(policy_repo).to receive(:find).with(policy.id)
    end_coverage.execute(request)
  end

  it 'labels policy as updated by user' do
    end_coverage.execute(request)
    expect(policy.updated_by).to eq current_user
  end

  it 'creates a resulting action' do
    expect(action_factory).to receive(:create_for).with(request[:action], listener)
    end_coverage.execute(request)
  end

  it 'invokes the resulting action' do
    expect(action).to receive(:execute).with(action_request)
    end_coverage.execute(request)
  end

  context 'when subscriber\'s coverage ends' do
    let(:affected_enrollee_ids) { [ subscriber.m_id ] }
    
    before { end_coverage.execute(request) }

    it 'affects all enrollees' do
      policy.enrollees.each do |e|
        expect(e.coverage_status).to eq 'inactive'
        expect(e.coverage_end).to eq request[:coverage_end]
      end
    end

    context 'by cancelation' do
      let(:operation) { 'cancel' }
      let(:coverage_start) { Date.new(2014, 1, 2)}
      let(:coverage_end) { coverage_start }

      it 'adjusts premium total to be the sum of all enrollees\' premiums' do
        sum = 0
        policy.enrollees.each do |e|
          sum += e.pre_amt
        end
        expect(policy.pre_amt_tot.to_f).to eq sum.to_f
      end

      it 'updates policy status' do
        expect(policy.aasm_state).to eq 'canceled'
      end
    end

    context 'by termination' do
      let(:operation) { 'terminate' }
      let(:coverage_start) { Date.new(2014, 1, 2)}
      let(:coverage_end) { Date.new(2014, 1, 14)}

      context 'when member\'s coverage ended previously' do
        let(:member) { Enrollee.new(rel_code: 'child', pre_amt: 200.00, coverage_status: 'inactive', coverage_end:  Date.new(1990, 1, 1), ben_stat: 'active', emp_stat: 'active',  m_id: '2') }

        it 'new policy premium total doesnt include member' do
          sum = 0
          policy.enrollees.each do |e|
            sum += e.pre_amt if e.coverage_end == subscriber.coverage_end
          end

          expect(policy.pre_amt_tot.to_f).to eq sum.to_f
        end
      end
      it 'updates policy status' do
        expect(policy.aasm_state).to eq 'terminated'
      end
    end
  end

  context 'when a member\'s coverage is ended' do
    let(:affected_enrollee_ids) { [member.m_id] }

    it 'doesn\'t end the subscribers coverage' do
      end_coverage.execute(request)
      expect(subscriber.coverage_status).to eq 'active'
    end

    it 'ends the member\'s coverage' do
      end_coverage.execute(request)
      expect(member.coverage_status).to eq 'inactive'
      expect(member.coverage_end).to eq request[:coverage_end]
    end

    it 'deducts member\'s premium from policy\'s total'  do
      end_coverage.execute(request)
      expect(policy.pre_amt_tot.to_f).to eq (premium_total - member.pre_amt)
    end
  end
end
