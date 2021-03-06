require "spec_helper"

module ManualEnrollments
  describe EnrollmentRowBuilder do

    subject { EnrollmentRowBuilder.new(nil, false) }

    context '#sort_enrollees_by_rel' do

      let(:spouse) { double(member: double(relationship_uri: "urn:openhbx:terms:v1:individual_relationship#Spouse", is_subscriber: false)) }
      let(:child) { double(member: double(relationship_uri: "urn:openhbx:terms:v1:individual_relationship#Child", is_subscriber: false)) }
      let(:son) { double(member: double(relationship_uri: "urn:openhbx:terms:v1:individual_relationship#Son"), is_subscriber:false) }
      let(:dependent) { double(member: double(relationship_uri: "urn:openhbx:terms:v1:individual_relationship#Dependent"), is_subscriber:false) }
      let(:subscriber) { double(member: double(relationship_uri: "urn:openhbx:terms:v1:individual_relationship#Self"), is_subscriber: true) }
      let(:no_rel) { double(member: double(relationship_uri: nil), is_subscriber: false) }

      context 'when dependent, spouse not sorted properly' do
        let(:enrollees) { [spouse, child, subscriber] }
        it 'should return them in correct order with subscriber first' do
          expect(subject.sort_enrollees_by_rel(enrollees)).to eq([subscriber, spouse, child])
        end
      end

      context 'when relationship is not child, spouse, self' do
        let(:enrollees) { [child, son, spouse, dependent, subscriber] }
        it 'should sort enrollees by putting unknown relationships at the end' do
          expect(subject.sort_enrollees_by_rel(enrollees)).to eq([subscriber, spouse, child, son, dependent])
        end
      end

      context 'when relationship empty' do
        let(:enrollees) { [son, no_rel, child, spouse, subscriber] }
        it 'should sort enrollees by putting empty relationship at the end' do
          expect(subject.sort_enrollees_by_rel(enrollees)).to eq([subscriber, spouse, child, son, no_rel])
        end
      end

      context 'when enrollees in the correct order' do 
        let(:enrollees) { [subscriber, spouse, child]}
        it 'should return them as is' do 
          expect(subject.sort_enrollees_by_rel(enrollees)).to eq(enrollees)
        end
      end
    end
  end
end
