require 'spec_helper'

describe Listeners::EnrollmentEventTransformer do
  let(:queue) { double }
  let(:channel) { double(:acknowledge => nil) }
  let(:event_exchange) { double }
  let(:payload) { double }
  let(:delivery_info) { double(:delivery_tag => "") }
  let(:properties) { double }
  let(:expected_payload) { "" }
  let(:event_name) { "" }
  let(:expected_properties) { 
    { :routing_key => routing_key, :headers => headers }
  }
  let(:headers) { 
    { :event_name => event_uri, :hbx_id => "DC0", :submitted_timestamp => timestamp, :originating_service => "Curam",
      :authorization => "", :individual_url => hbx_member_id }
  }
  let(:individual_uri) { double }
  let(:event_parser) { double }
  let(:timestamp) { double }
  let(:hbx_member_id) { double }
  let(:parsed_event) { double(:event_type => event_type, :event_uri => event_uri, :routing_key => routing_key, :timestamp => timestamp, :person_id => person_id) }
  let(:id_finder) { double }
  let(:person_id) { double }

  before :each do
    allow(event_parser).to receive(:parse).with(payload).and_return(parsed_event)
    allow(id_finder).to receive(:from_person_id).with(person_id).and_return(hbx_member_id)
  end

  subject { Listeners::EnrollmentEventTransformer.new(channel, queue, event_exchange, id_finder, event_parser) }

  describe "for an individual update event" do
    let(:event_type) { "PERSON_UPDATE" }
    let(:event_uri) { "urn:openhbx:requests:v1:individual#update" }
    let(:routing_key) { "update" }

    it "should re-broadcast the event" do
      expect(event_exchange).to receive(:publish).with(expected_payload, expected_properties)
      subject.on_message(delivery_info, properties, payload)
    end
  end

  describe "for an individual's disenrollment" do
    let(:event_type) { "INDIVIDUAL_DISENROLLMENT" }
    let(:event_uri) { "urn:openhbx:requests:v1:individual#withdraw_qhp" }
    let(:routing_key) { "withdraw_qhp" }

    it "should re-broadcast the event" do
      expect(event_exchange).to receive(:publish).with(expected_payload, expected_properties)
      subject.on_message(delivery_info, properties, payload)
    end
  end
end
