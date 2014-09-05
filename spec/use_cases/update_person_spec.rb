# require 'ostruct'
# class Address
#   def self.new(args)
#     OpenStruct.new({:address_type => nil, :address_1 => nil, :address_2 => nil, :city => nil, :state => nil, :zip => nil}.merge(args))
#   end
# end

# class Person
#   def self.new(args)
#     OpenStruct.new({:addresses => nil}.merge(args))
#   end
# end

# require './app/use_cases/update_person'
require 'spec_helper'
module TestBarrier

  describe UpdatePerson do
    subject(:update_person) { UpdatePerson.new(listener, person_repo, address_changer, change_address_request_factory) }
    let(:listener) { double(has_errors?: false) }
    let(:person_repo) { double(find: person) }
    let(:change_address_request_factory) { double(for_member: change_address_request) }
    
    let(:change_address_request) do
      {
        member_id: "1",
        type: request[:address_type],
        address1: request[:address_1],
        address2: request[:address_2],
        city: request[:city],
        state: request[:state],
        zip: request[:zip],
        current_user: request[:current_user]
      }
    end

    let(:address_changer) { double(execute: nil) }
    let(:person) { Person.new(name_first: 'Joe', name_last: 'Dirt', addresses: addresses) }
    let(:addresses) { [existing_address] }
    let(:existing_address) do 
      Address.new(existing_address_fields) 
    end

    let(:existing_address_fields) { 
      { 
        address_type: existing_address_type, 
        address_1: '1234 A street', 
        address_2: '#321', 
        city: 'Atlanta', 
        state: 'GA', 
        zip: '12345'
      }
    }

    let(:existing_address_type) { 'home' }

    let(:request) do
      {
        person_id: '1234',
        current_user: 'me@example.com',
        addresses: [
          {
            address_type: requested_address_type,
            address_1: '666 Halo Street',
            address_2: '#777',
            city: 'Orlando',
            state: 'FL',
            zip: '98765'
          }
        ]
      }
    end
    let(:requested_address_type) { 'home' }

    it 'finds the person' do
      expect(person_repo).to receive(:find).with(request[:person_id])
      subject.execute(request)
    end

    it 'saves the person' do
      expect(person).to receive(:save!)
      subject.execute(request)
    end

    context 'request includes address whose type doesnt exist yet' do
      let(:requested_address_type) { 'work' }
      before { request[:addresses] << existing_address_fields }

      it 'adds the address to person' do
        subject.execute(request)
        expect(person.addresses.last.address_type).to eq request[:addresses].first[:address_type]
        expect(person.addresses.last.address_1).to eq request[:addresses].first[:address_1]
        expect(person.addresses.last.address_2).to eq request[:addresses].first[:address_2]
        expect(person.addresses.last.city).to eq request[:addresses].first[:city]
        expect(person.addresses.last.state).to eq request[:addresses].first[:state]
        expect(person.addresses.last.zip).to eq request[:addresses].first[:zip]
      end
    end

    # context 'requested address type exists' do
    #   let(:existing_address_type) { 'home' }

    #   let(:requested_address_type) { existing_address_type }

    #   it 'changes the address' do
    #     subject.execute(request)

    #     expect(person.addresses.first.address_type).to eq request[:addresses].first[:address_type]
    #     expect(person.addresses.first.address_1).to eq request[:addresses].first[:address_1]
    #     expect(person.addresses.first.address_2).to eq request[:addresses].first[:address_2]
    #     expect(person.addresses.first.city).to eq request[:addresses].first[:city]
    #     expect(person.addresses.first.state).to eq request[:addresses].first[:state]
    #     expect(person.addresses.first.zip).to eq request[:addresses].first[:zip]
    #   end
    # end

    context 'existing address type is missing from request' do
      let(:existing_address_type) { 'home' }
      let(:requested_address_type) { 'work' }
      let(:address_to_be_removed) { 
        Address.new(address_type: requested_address_type, 
          address_1: '1234 A street', 
          address_2: '#321', 
          city: 'Atlanta', 
          state: 'GA', 
          zip: '12345') 
      }
      let(:addresses) { [existing_address, address_to_be_removed] }

      before { request[:addresses] = [existing_address_fields] }

      it 'deletes the address' do
        subject.execute(request)
        address_of_type = person.addresses.detect { |a| a.address_type == address_to_be_removed.address_type }
        expect(address_of_type).to be_nil
      end
    end

    context 'when the home address changes' do
      let(:existing_address_type) { 'home' }
      let(:requested_address_type) { 'home' }

      it 'builds a change address request' do
        expect(change_address_request_factory).to receive(:for_member)
        subject.execute(request)
      end

      it 'invokes the address changer' do
        expect(address_changer).to receive(:execute).with(change_address_request, listener)
        subject.execute(request)
      end
    end

    context 'when non-home address changes' do 
      # let(:existing_address_type) { 'work' }
      # let(:requested_address_type) { 'work' }

      let(:existing_address_type) { 'home' }
      let(:requested_address_type) { 'work' }
      let(:address_to_be_changed) { 
        Address.new(work_address_fields) 
      }
      let(:addresses) { [existing_address, address_to_be_changed] }
      let(:work_address_fields) {
        {
          address_type: requested_address_type, 
          address_1: '1234 A street', 
          address_2: '#321', 
          city: 'Atlanta', 
          state: 'GA', 
          zip: '12345'
        }
      }
      before { request[:addresses] = [existing_address_fields, work_address_fields ] }

      it 'does not build a change address request' do
        expect(change_address_request_factory).not_to receive(:from_update_person_request)
        subject.execute(request)
      end

      it 'does not invoke the address changer' do
        expect(address_changer).not_to receive(:execute)
        subject.execute(request)
      end
    end
    
    context 'when request doesnt have a home address' do
      let(:listener) { double(home_address_not_present: nil, has_errors?: true) }
      before { request[:addresses] = [{ address_type: 'work' }, { address_type: 'mailing' }] }
      it 'notifies the listener' do
        expect(listener).to receive(:home_address_not_present)
        subject.execute(request)
      end

      it 'does not save the person' do
        subject.execute(request)
      end
    end

    context 'when request contains more than one address with the same type' do
      let(:listener) { double(:too_many_addresses_of_type, has_errors?: true) }
      before { request[:addresses] = [{ address_type: 'home' }, { address_type: 'home' }]}

      it 'notifies the listener' do
        expect(listener).to receive(:too_many_addresses_of_type).with({address_type: 'home', max: 1})

        subject.execute(request)
      end
    end

    context 'when listener has received errors' do
      let(:listener) { double(has_errors?: true)}
      it 'does not save' do
        expect(person).not_to receive(:save!)
        subject.execute(request)
      end
      it 'does not invoke the address changer' do
        expect(address_changer).not_to receive(:execute)
        subject.execute(request)
      end
    end
  end
end
