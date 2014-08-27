require "spec_helper"

def expect_address_to_change(person, request)
  expect(person.addresses.first.address_type).to eq request.to_hash[:type]
  expect(person.addresses.first.address_1).to eq request.to_hash[:address1]
  expect(person.addresses.first.address_2).to eq request.to_hash[:address2]
  expect(person.addresses.first.city).to eq request.to_hash[:city]
  expect(person.addresses.first.state).to eq request.to_hash[:state]
  expect(person.addresses.first.zip).to eq request.to_hash[:zip]
end

describe ChangeMemberAddress do
  subject(:change_address) { ChangeMemberAddress.new(transmitter, listener, person_repo)}
  let(:listener) { double(:fail => nil) }
  let(:transmitter) { double(execute: nil) }
  let(:person_repo) { double(find_for_member_id: person) }
  let(:person) { Person.new }
  
  let(:policy) { double(id: '12345', plan: plan, enrollees: [target_enrollee], active_enrollees: [target_enrollee]) }
  let(:plan) { double(coverage_type: coverage_type) }
  let(:coverage_type) { 'health'}

  let(:target_enrollee) { double(m_id: '1234', person: person, coverage_status: 'active') } 

  let(:request) do
    {
      :member_id => 1,
      :type => 'home',
      :address1 => '4321 cool drive',
      :address2 => '#999',
      :city => 'Seattle',
      :state => 'GA',
      :zip => '12345'
    }
  end

  let(:address) { Address.new(address_fields) }

  let(:address_fields) do
    {
      address_type: 'home', 
      address_1: '1234 awesome street', 
      address_2: '#123', 
      city: 'Atlanta', 
      state: 'GA', 
      zip: '12345'
    }
  end

  let(:transmit_request) do
    {
      policy_id: policy.id,
      operation: 'change',
      reason: 'change_of_location',
      affected_enrollee_ids: [target_enrollee.m_id],
      include_enrollee_ids: [target_enrollee.m_id],
      current_user: 'me@example.com' 
    }
  end

  before do
    person.stub(:active_policies) { [policy]}
    person.addresses << address
    person.save
  end

  it 'finds the person by member id' do
    expect(person_repo).to receive(:find_for_member_id).with(1)
    expect(listener).to receive(:success)
    change_address.execute(request)
  end

  it "finds the person's active policies"  do
    expect(person).to receive(:active_policies)
    expect(listener).to receive(:success)
    change_address.execute(request)
  end

  it 'finds active enrollees on policy' do
    expect(policy).to receive(:active_enrollees)
    expect(listener).to receive(:success)
    change_address.execute(request)
  end

  it 'finds people who share the same address' do
    people = change_address.people_with_members_address(policy, person)
    expect(people).to eq [person]
  end

  it 'changes address of person' do
    expect(listener).to receive(:success)
    change_address.execute(request)
    expect_address_to_change(person, request)
  end

  it 'transmits the changes' do
    expect(transmitter).to receive(:execute).with(transmit_request)
    expect(listener).to receive(:success)
    change_address.execute(request)
  end

  context 'when there are active enrollees that share original address' do
    let(:other_person) { Person.new }
    let(:other_enrollee) { double(m_id: '6666', person: other_person, coverage_status: 'active') }
    let(:matching_address) { Address.new(address_fields) }

    before do
      policy.enrollees << other_enrollee
      policy.active_enrollees << other_enrollee
      other_person.stub(:active_policies) { [policy]}
      other_person.addresses << matching_address
      person.save
    end
    it 'also changes their address' do
      expect(listener).to receive(:success)
      change_address.execute(request)
      expect_address_to_change(other_person, request)
    end
  end

  context 'when there is another active enrollee with different address' do
    let(:other_person) { Person.new }
    let(:other_enrollee) { double(m_id: '6666', person: other_person, coverage_status: 'active') }
    let(:different_address) { Address.new(address_type: 'home', 
      address_1: '1234 somethingelse', 
      address_2: '#654', 
      city: 'Atlanta', 
      state: 'GA', 
      zip: '12345') }

    before do
      policy.enrollees << other_enrollee
      policy.active_enrollees << other_enrollee
      other_person.stub(:active_policies) { [policy]}
      other_person.addresses << different_address
      person.save
    end

    it 'does not change their address' do
      expect(listener).to receive(:success)
      change_address.execute(request)
      expect(other_person.addresses.first.address_type).to eq different_address.address_type
      expect(other_person.addresses.first.address_1).to eq different_address.address_1
      expect(other_person.addresses.first.address_2).to eq different_address.address_2
      expect(other_person.addresses.first.city).to eq different_address.city
      expect(other_person.addresses.first.state).to eq different_address.state
      expect(other_person.addresses.first.zip).to eq different_address.zip
    end
  end
 
  context 'when member doesnt exist' do 
    let(:person_repo) { double(find_for_member_id: nil) }
    it 'notifies listener of no such member' do
      expect(listener).to receive(:no_such_member).with({:member_id => request[:member_id]})
      expect(listener).to receive(:fail)
      change_address.execute(request)
    end
  end

  #TODO: move?
  describe '#count_policies_by_coverage_type' do
    let(:policies) { [ double(plan: double(coverage_type: 'health')), double(plan: double(coverage_type: 'health')), double(plan: double(coverage_type: 'dental'))] }
    
    it 'returns the number of health policies' do 
      count = change_address.count_policies_by_coverage_type(policies, 'health')
      expect(count).to eq 2
    end

    it 'returns the number of dental policies' do 
      count = change_address.count_policies_by_coverage_type(policies, 'dental')
      expect(count).to eq 1
    end
  end

  context "when the member has more than one active health policy" do
    let(:coverage_type) { 'health' }
    let(:other_policy) { double(plan: double(coverage_type: coverage_type), enrollees: [other_enrollee]) } 
    let(:other_enrollee) { double(person: person) }

    before { person.stub(:active_policies) { [policy, other_policy]} }

    it 'notifies the listener of too many health policies' do 
      expect(listener).to receive(:too_many_health_policies)
      expect(listener).to receive(:fail)
      change_address.execute(request)
    end
  end

  context "when the member has more than one active dental policy" do
    let(:coverage_type) { 'dental' }
    let(:other_policy) { double(plan: double(coverage_type: coverage_type), enrollees: [other_enrollee]) }
    let(:other_enrollee) { double(person: person) }

    before { person.stub(:active_policies) { [policy, other_policy]} }

    it 'notifies the listener of too many dental policies' do 
      expect(listener).to receive(:too_many_dental_policies)
      expect(listener).to receive(:fail)
      change_address.execute(request)
    end
  end

  context "when the member has no active policies" do
    before { person.stub(:active_policies) { [] } }
    it 'notifies the listener that there are no policies' do
      expect(listener).to receive(:no_active_policies)
      expect(listener).to receive(:fail)
      change_address.execute(request)
    end
  end

  context "when member has one active dental and one active health policy" do
    let(:coverage_type) { 'health' }

    let(:other_policy) { double(id: '999', plan: double(coverage_type: 'dental'), enrollees: [other_enrollee], active_enrollees: [other_enrollee]) }
    let(:other_enrollee) { double(m_id: '999', person: person) }
    
    let(:other_transmit_request) do
      {
        policy_id: other_policy.id,
        operation: 'change',
        reason: 'change_of_location',
        affected_enrollee_ids: [other_enrollee.m_id],
        include_enrollee_ids: [other_enrollee.m_id],
        current_user: 'me@example.com' 
      }
    end
    before { person.stub(:active_policies) { [policy, other_policy]} }
    
    it 'should transmit the changes on both policies' do
      expect(transmitter).to receive(:execute).with(transmit_request)
      expect(transmitter).to receive(:execute).with(other_transmit_request)
      expect(listener).to receive(:success)

      change_address.execute(request)
    end
  end
end

# shared_examples "a failed execution" do |notify_msg, notify_args|

#   it "and should signal the error with :#{notify_msg} and fail" do
#     expect(listener).to receive(notify_msg).with(notify_args)
#     expect(listener).to receive(:fail)
#   end
# end 

# describe ChangeMemberAddress do
#     let(:listener) { double }

#     describe "with a non-existent member" do
#       it_behaves_like "a failed execution", :no_such_member, {}
#     end

#     describe "when the member has more than one active health policy" do
#       it_behaves_like "a failed execution", :too_many_health_policies, {}
#     end

#     describe "when the member has more than one active dental policy" do
#       it_behaves_like "a failed execution", :too_many_dental_policies, {}
#     end

#     describe "when the member has no active policies" do
#       it_behaves_like "a failed execution", :no_active_policies, {}
#     end

#     describe "with a member that has one active dental and one active health policy" do
#       it "should transmit the changes on both policies"
#     end

#     describe "with a member that has one active, one terminated, and one cancelled health policy" do
#       it "should only transmit changes to the active policy"
#     end

#     describe "with a single active health policy" do
#       describe "which has a spouse at the same address" do
#         it "should also update the spouse"
#       end 

#       describe "which has a child at a different address" do
#         it "should not update the child"
#       end 
#     end

# end
