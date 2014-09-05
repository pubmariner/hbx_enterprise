class Person ; end
class DeleteAddress
  def initialize(transmitter, person_repo = Person)
    @person_repo = person_repo
    @transmitter = transmitter
  end
  
  def commit(request)
    person = @person_repo.find_by_id(request[:person_id])
    address = person.address_of(request[:type])
    if address.nil?
      return
    end

    person.save!
    transmit_request = {
      policy_id: ''
    }
    @transmitter.execute(transmit_request)
  end
end

describe DeleteAddress do
  subject { DeleteAddress.new(transmitter, person_repo) }
  let(:person_repo) { double(find_by_id: person) }
  let(:person) { double(save!: nil, address_of: address) }
  let(:address) { double }
  let(:transmitter) { double(execute: nil) }

  let(:transmit_request) do
    {
      policy_id: policy.id,
      # operation: 'change',
      # reason: 'change_of_location',
      # affected_enrollee_ids: affected_enrollees,
      # include_enrollee_ids: include_enrollee_ids,
      # current_user: 'me@example.com' 
    }
  end
  let(:affected_enrollees) { [] }
  let(:include_enrollee_ids) { [] }
  let(:policy) { double(id: '1234')}

  let(:request) do
    {
      person_id: '1'
    }
  end

  it 'finds the person' do
    expect(person_repo).to receive(:find_by_id).with(request[:person_id])
    subject.commit(request)
  end

  it 'looks for the address of type' do
    expect(person).to receive(:address_of).with(request[:address_type])
    subject.commit(request)
  end

  it 'removes the address' do
    expect(person).to receive(:save!)
    subject.commit(request)
  end

  it 'transmits the changes' do
    expect(transmitter).to receive(:execute).with(transmit_request)
    subject.commit(request)
  end

  context 'when address type does not exist' do
    let(:address) { nil }
    it 'does not update the person' do
      expect(person).not_to receive(:save!)
      subject.commit(request)
    end

    it 'does not transmit the changes' do
      expect(transmitter).not_to receive(:execute)
      subject.commit(request)
    end
  end

end


  # let(:address_to_be_removed) { 
  #     Address.new(address_type: requested_address_type, 
  #       address_1: '1234 A street', 
  #       address_2: '#321', 
  #       city: 'Atlanta', 
  #       state: 'GA', 
  #       zip: '12345') 
  #   }
  #   let(:addresses) { [existing_address, address_to_be_removed] }

  #   before { request[:addresses] = [existing_address_fields] }
