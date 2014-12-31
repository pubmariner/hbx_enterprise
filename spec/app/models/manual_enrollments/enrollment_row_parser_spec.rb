require "spec_helper"

module ManualEnrollments
  describe EnrollmentRowParser do


    let(:subscriber) { double(ssn: 342323212) }

    context 'Enrollment Validator' do 
      context 'when having duplicate ssns' do 
        let(:enrollees) { [subscriber, dependent1] }
        let(:dependent1) { double(ssn: 342323212) }
        it 'should return false' do
          subject = EnrollmentRowParser.new(double)
          allow(subject).to receive(:enrollees).and_return(enrollees)
          allow(subject).to receive(:validate_relationships).and_return(true)
          expect(subject.valid?).to eq(false)
          expect(subject.errors).to eq(['duplicate ssns 342323212.'])
        end
      end

      context 'when no ssns' do 
        let(:enrollees) { [subscriber, dependent1, dependent2] }
        let(:dependent1) { double(ssn: nil) }
        let(:dependent2) { double(ssn: nil) }
        it 'should return true' do
          subject = EnrollmentRowParser.new(double)
          allow(subject).to receive(:enrollees).and_return(enrollees)
          allow(subject).to receive(:validate_relationships).and_return(true)
          expect(subject.valid?).to eq(true)
        end
      end

      context 'when no duplicate ssns' do
        let(:enrollees) { [subscriber, dependent1] }
        let(:dependent1) { double(ssn: 342323214) }
        it 'should return true' do
          subject = EnrollmentRowParser.new(double)
          allow(subject).to receive(:enrollees).and_return(enrollees)
          allow(subject).to receive(:validate_relationships).and_return(true)
          expect(subject.valid?).to eq(true)
        end
      end

      context 'when relationship is empty' do
        let(:enrollees) { [subscriber] }
        let(:subscriber) { double(ssn: 342323212, relationship: nil) }
        it 'should return false' do
          subject = EnrollmentRowParser.new(double)
          allow(subject).to receive(:enrollees).and_return(enrollees)
          allow(subject).to receive(:validate_ssns).and_return(true)
          expect(subject.valid?).to eq(false)
          expect(subject.errors).to eq(['relationship empty'])
        end
      end

      context 'when relationship not one of self, spouse, child' do
        let(:enrollees) { [subscriber, dependent1] }
        let(:subscriber) { double(ssn: 342323212, relationship: 'self') }
        let(:dependent1) { double(relationship: 'sibling') }
        it 'should return false' do
          subject = EnrollmentRowParser.new(double)
          allow(subject).to receive(:enrollees).and_return(enrollees)
          allow(subject).to receive(:validate_ssns).and_return(true)
          expect(subject.valid?).to eq(false)
          expect(subject.errors).to eq(['invalid relationship'])
        end
      end

      context 'when relationship is child' do
        let(:enrollees) { [subscriber, dependent1] }
        let(:subscriber) { double(ssn: 342323212, relationship: 'self') }
        let(:dependent1) { double(relationship: 'child') }
        it 'should return true' do
          subject = EnrollmentRowParser.new(double)
          allow(subject).to receive(:enrollees).and_return(enrollees)
          allow(subject).to receive(:validate_ssns).and_return(true)
          expect(subject.valid?).to eq(true)
          expect(subject.errors).to eq([])
        end
      end
    end
  end
end