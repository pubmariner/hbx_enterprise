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

        it 'should return error' do 
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
        let(:subscriber) { double(ssn: '342323212', relationship: nil) }
        it 'should return false' do
          allow(subject).to receive(:enrollees).and_return(enrollees)
          subject.validate_relationships
          expect(subject.valid).to eq(false)
          expect(subject.errors).to eq(['relationship is empty or wrong'])
        end
      end

      context 'when relationship not one of self, spouse, child' do
        let(:enrollees) { [subscriber, dependent1] }
        let(:subscriber) { double(ssn: '342323212', relationship: 'self') }
        let(:dependent1) { double(relationship: 'sibling') }
        it 'should return false' do
          allow(subject).to receive(:enrollees).and_return(enrollees)
          subject.validate_relationships
          expect(subject.valid).to eq(false)
          expect(subject.errors).to eq(['relationship is empty or wrong'])
        end
      end

      context 'when relationship is child' do
        let(:enrollees) { [subscriber, dependent1] }
        let(:subscriber) { double(ssn: '342323212', relationship: 'self') }
        let(:dependent1) { double(relationship: 'child') }
        it 'should return true' do
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
  end
end