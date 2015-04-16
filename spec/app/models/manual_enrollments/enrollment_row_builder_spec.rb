require "spec_helper"

module ManualEnrollments
  describe EnrollmentRowBuilder do

    subject { EnrollmentRowBuilder.new }

    context '#sort_enrollees_by_rel' do
      
      let(:spouse) { double(member: double(relationship_uri: "urn:openhbx:terms:v1:individual_relationship#Spouse")) }
      let(:child) { double(member: double(relationship_uri: "urn:openhbx:terms:v1:individual_relationship#Child")) }
      let(:son) { double(member: double(relationship_uri: "urn:openhbx:terms:v1:individual_relationship#Son")) }
      let(:dependent) { double(member: double(relationship_uri: "urn:openhbx:terms:v1:individual_relationship#Dependent")) }
      let(:subscriber) { double(member: double(relationship_uri: "urn:openhbx:terms:v1:individual_relationship#Self")) }
      let(:no_rel) { double(member: double(relationship_uri: nil)) }

      context 'when dependent, spouse not ordered properly' do
        let(:enrollees) { [spouse, child, subscriber] }
        it 'should return them in correct order with subscriber first' do
          expect(subject.sort_enrollees_by_rel(enrollees)).to eq([subscriber, spouse, child])
        end
      end

      context 'when relationship not one of child, spouse, self' do
        let(:enrollees) { [child, son, spouse, dependent, subscriber] }
        it 'should return enrollees in correct order by putting unknown rel at the end' do
          expect(subject.sort_enrollees_by_rel(enrollees)).to eq([subscriber, spouse, child, son, dependent])
        end
      end

      context 'when relationship empty' do
        let(:enrollees) { [son, no_rel, child, spouse, subscriber] }
        it 'should return enrollees in correct order by putting empty at the end' do
          expect(subject.sort_enrollees_by_rel(enrollees)).to eq([subscriber, spouse, child, son, no_rel])
        end
      end
    end
  end
end