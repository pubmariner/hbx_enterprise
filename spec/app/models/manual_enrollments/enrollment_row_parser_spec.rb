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
          expect(subject.valid?).to eq(false)
          expect(subject.errors).to eq(["People having duplicate ssns 342323212."])
        end
      end

      context 'when no ssns' do 
        let(:enrollees) { [subscriber, dependent1, dependent2] }
        let(:dependent1) { double(ssn: nil) }
        let(:dependent2) { double(ssn: nil) }
        it 'should return true' do
          subject = EnrollmentRowParser.new(double)
          allow(subject).to receive(:enrollees).and_return(enrollees)
          expect(subject.valid?).to eq(true)
        end
      end

      context 'when ssns empty' do 
        let(:enrollees) { [subscriber, dependent1, dependent2] }
        let(:dependent1) { double(ssn: '') }
        let(:dependent2) { double(ssn: '') }
        it 'should return true' do
          subject = EnrollmentRowParser.new(double)
          allow(subject).to receive(:enrollees).and_return(enrollees)
          expect(subject.valid?).to eq(true)
        end
      end

      context 'when no duplicate ssns' do
        let(:enrollees) { [subscriber, dependent1] }
        let(:dependent1) { double(ssn: 342323214) }
        it 'should return true' do
          subject = EnrollmentRowParser.new(double)
          allow(subject).to receive(:enrollees).and_return(enrollees)
          expect(subject.valid?).to eq(true)
        end
      end
    end
  end
end