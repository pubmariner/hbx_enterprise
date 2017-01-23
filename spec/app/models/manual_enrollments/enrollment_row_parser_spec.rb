require "spec_helper"

module ManualEnrollments
  describe EnrollmentRowParser do

    subject { EnrollmentRowParser.new(enrollment) }

    let(:enrollment) { ['renewal', 'ivl'] }
    let(:subscriber) { double(ssn: '342323212') }

    it 'should return market' do
      expect(subject.market).to eq('ivl')
    end

    it 'should return market type' do
      expect(subject.market_type).to eq('Individual')
    end

    it 'should check for individual market' do 
      expect(subject.individual_market?).to eq(true)
    end

    context 'market type validation' do
      context 'when market information missing' do 
        let(:enrollment) { ['renewal', '']}

        it 'returns error' do 
          subject.validate_market
          expect(subject.valid).to eq(false)
          expect(subject.errors).to eq(["Market type should be shop or ivl or individual."])
        end
      end

      context 'when market information is present' do
        let(:enrollment) { ['renewal', 'shop']}

        it 'should pass' do 
          subject.validate_market
          expect(subject.valid).to eq(true)
          expect(subject.errors).to eq([])
          expect(subject.individual_market?).to eq(false)
        end
      end
    end

    context 'ssn validation' do
      context 'when having duplicate ssns' do 

        let(:enrollees) { [subscriber, dependent1] }
        let(:dependent1) { double(ssn: '342323212') }

        it 'should return false' do
          allow(subject).to receive(:enrollees).and_return(enrollees)
          subject.validate_ssns
          expect(subject.valid).to eq(false)
          expect(subject.errors).to eq(['duplicate ssns 342323212.'])
        end
      end

      context 'when no ssns' do 
        let(:enrollees) { [subscriber, dependent1, dependent2] }
        let(:dependent1) { double(ssn: nil) }
        let(:dependent2) { double(ssn: nil) }
        it 'should return true' do
          allow(subject).to receive(:enrollees).and_return(enrollees)
          subject.validate_ssns
          expect(subject.valid).to eq(true)
        end
      end

      context 'when no duplicate ssns' do
        let(:enrollees) { [subscriber, dependent1] }
        let(:dependent1) { double(ssn: '342323214') }
        it 'should return true' do
          allow(subject).to receive(:enrollees).and_return(enrollees)
          subject.validate_ssns
          expect(subject.valid).to eq(true)
        end
      end
    end

    context 'relationship validation' do

      context 'when relationship is empty' do
        let(:enrollees) { [subscriber] }
        let(:subscriber) { double(relationship: nil) }
        it 'should error out' do
          allow(subject).to receive(:enrollees).and_return(enrollees)
          subject.validate_relationships
          expect(subject.valid).to eq(false)
          expect(subject.errors).to include('relationship is empty or wrong')
        end
      end

      context 'when relationship not one of self, spouse, child' do
        let(:enrollees) { [subscriber, dependent1] }
        let(:subscriber) { double(relationship: 'self') }
        let(:dependent1) { double(relationship: 'sibling') }
        it 'should error out' do
          allow(subject).to receive(:enrollees).and_return(enrollees)
          subject.validate_relationships
          expect(subject.valid).to eq(false)
          expect(subject.errors).to eq(['relationship is empty or wrong'])
        end
      end

      context 'when subscriber missing' do
        let(:enrollees) { [ spouse ] }
        let(:spouse) { double(relationship: 'spouse') }

        it 'should error out' do
          allow(subject).to receive(:enrollees).and_return(enrollees)
          subject.validate_relationships
          expect(subject.valid).to eq(false)
          expect(subject.errors).to eq(['no enrollee with relationship as self'])
        end
      end

      context 'when more than one subscriber/spouse present' do
        let(:enrollees) { [ subscriber, spouse, spouse_dup] }
        let(:subscriber) { double(relationship: 'self') }
        let(:spouse) { double(relationship: 'spouse') }
        let(:spouse_dup) { double(relationship: 'spouse') }

        it 'should error out' do
          allow(subject).to receive(:enrollees).and_return(enrollees)
          subject.validate_relationships
          expect(subject.valid).to eq(false)
          expect(subject.errors).to eq(['more than one subscriber/spouse'])
        end
      end

      context 'when relationships are correct' do
        let(:enrollees) { [subscriber, dependent1] }
        let(:subscriber) { double(relationship: 'self') }
        let(:dependent1) { double(relationship: 'child') }
        it 'should pass validation' do
          allow(subject).to receive(:enrollees).and_return(enrollees)
          subject.validate_relationships
          expect(subject.valid).to eq(true)
          expect(subject.errors).to eq([])
        end
      end
    end

    context 'date format validation' do
      context 'when benefit begin date is invalid i.e, 2 digit year format' do
        let(:enrollees) { [subscriber] }
        let(:subscriber) { double(ssn: '342323212', relationship: nil) }
        let(:benefit_begin_date) { '8/8/91'}
        it 'should return false' do
          allow(subject).to receive(:enrollees).and_return(enrollees)
          allow(subject).to receive(:benefit_begin_date).and_return(benefit_begin_date)

          subject.validate_benefit_begin
          expect(subject.valid).to eq(false)
          expect(subject.errors).to eq(['wrong benefit begin date'])
        end
      end

      context 'when dob is invalid format i.e, 2 digit year' do
        let(:enrollees) { [subscriber, dependent1] }
        let(:subscriber) { double(ssn: '342323212', relationship: 'self', dob: "12/02/1983") }
        let(:dependent1) { double(relationship: 'sibling', dob: "01/02/78") }

        it 'should return false' do
          allow(subject).to receive(:enrollees).and_return(enrollees)

          subject.validate_dob     
          expect(subject.valid).to eq(false)
          expect(subject.errors).to eq(['wrong DOB format'])
        end
      end

      context 'when dates are in correct format i.e, 4 digit year' do
        let(:enrollees) { [subscriber, dependent1] }
        let(:subscriber) { double(ssn: '342323212', relationship: 'self', dob: "12/02/1983") }
        let(:dependent1) { double(relationship: 'child', dob: "01/02/2008") }
        let(:benefit_begin_date) { '08/08/2008'}

        it 'should return true' do
          allow(subject).to receive(:enrollees).and_return(enrollees)
          allow(subject).to receive(:benefit_begin_date).and_return(benefit_begin_date)
          subject.validate_benefit_begin
          subject.validate_dob
          expect(subject.valid).to eq(true)
          expect(subject.errors).to eq([])
        end
      end
    end


    context '#sort_enrollees_by_rel' do

      let(:spouse) { double(relationship: 'spouse') }
      let(:child1) { double(relationship: 'child') }
      let(:child2) { double(relationship: 'child') }
      let(:sibling) { double(relationship: 'sibling') }
      let(:subscriber) { double(relationship: "self") }
      let(:no_rel) { double(relationship: nil) }

      context 'when dependent, spouse not sorted properly' do
        let(:enrollees) { [spouse, child1, subscriber] }
        it 'should return them in correct order with subscriber first' do
          expect(subject.sort_enrollees_by_rel(enrollees)).to eq([subscriber, spouse, child1])
        end
      end

      context 'when relationship is not child, spouse, self' do
        let(:enrollees) { [child1, sibling, spouse, child2, subscriber] }
        it 'should sort enrollees by putting unknown relationships at the end' do
          expect(subject.sort_enrollees_by_rel(enrollees)).to eq([subscriber, spouse, child2, child1, sibling])
        end
      end

      context 'when relationship empty' do
        let(:enrollees) { [sibling, no_rel, child1, spouse, subscriber] }
        it 'should sort enrollees by putting empty relationship at the end' do
          expect(subject.sort_enrollees_by_rel(enrollees)).to eq([subscriber, spouse, child1, sibling, no_rel])
        end
      end

      context 'when enrollees in the correct order' do 
        let(:enrollees) { [subscriber, spouse, child1]}
        it 'should return them as is' do 
          expect(subject.sort_enrollees_by_rel(enrollees)).to eq(enrollees)
        end
      end
    end
  end
end
