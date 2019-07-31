require 'spec_helper'

describe Listeners::PaymentProcessorEnrollmentDropListener do
  let(:queue) { double }
  let(:connection) { double(:create_channel => reply_channel) }
  let(:reply_exchange) { double }
  let(:reply_channel) do
    double(
      :close => true,
      :confirm_select => true,
      :default_exchange => reply_exchange,
      :wait_for_confirms => true
    )
  end
  let(:connection) { double(:create_channel => reply_channel) }
  let(:channel) { double(:connection => connection) }
  let(:reply_exchange) { double }
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
  let(:parsed_event) { double(:event_type => event_type, :event_uri => event_uri, :routing_key => routing_key, :timestamp => timestamp, :person_id => person_id) }  #
  let(:location) { "/fake_location/file" }
  let(:body) { double }
  # Fake class from app/models/amqp/event_broadcaster.rb line 12
  let(:outex_double) do
    class Outex
      def publish(payload, props)
        true
      end
    end
    Outex.new
  end

  subject { Listeners::PaymentProcessorEnrollmentDropListener.new(channel, queue) }

  before do
    allow(reply_channel).to receive(:fanout).with(
      ExchangeInformation.event_publish_exchange,
      :durable => true
    ).and_return(outex_double)
  end

  describe "#send_uploaded_notification" do
    let(:event_type) { "PERSON_UPDATE" }
    let(:event_uri) { "urn:openhbx:requests:v1:individual#update" }
    let(:routing_key) { "individual.update" }

    it "should successfully send the uploaded notification" do
      expect(subject.send_uploaded_notification(headers, location, body)).to eq(true)
    end
  end
end
