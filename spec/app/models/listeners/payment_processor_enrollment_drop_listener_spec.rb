require 'spec_helper'

describe Listeners::PaymentProcessorEnrollmentDropListener do
  let(:queue) { double }
  let(:connection) { double }
  let(:channel) { double(:connection => connection) }
  let(:delivery_info) { double(:delivery_tag => delivery_tag) }
  let(:properties) { double(:headers => headers) }
  let(:headers) do
    { :submitted_timestamp => submitted_timestamp }
  end
  let(:submitted_timestamp) { double }
  let(:location) { "/fake_location/file" }
  let(:payload) { "" }
  let(:current_time) { Time.now }
  let(:delivery_tag) { double }

  let(:event_broadcaster) do
    instance_double(
      Amqp::EventBroadcaster
    )
  end

  let(:proxy) do
    instance_double(Proxies::PaymentProcessorEnrollmentDropRequest)
  end

  subject { Listeners::PaymentProcessorEnrollmentDropListener.new(channel, queue) }

  before(:each) do
    allow(Proxies::PaymentProcessorEnrollmentDropRequest).to receive(:new).and_return(proxy)
    allow(Amqp::EventBroadcaster).to receive(:new).with(connection).and_return(event_broadcaster)
  end

  describe "which uploads successfully" do
    before :each do
      allow(proxy).to receive(:request).with(payload).and_return(["200", location])
      allow(Time).to receive(:now).and_return(current_time)
      allow(event_broadcaster).to receive(:broadcast).with(
        shared_log_properties.merge({
          :routing_key => "info.application.hbx_enterprise.payment_processor_enrollment_drop_listener.policy_uploaded",
        }),
        payload
      )
      allow(event_broadcaster).to receive(:broadcast).with(
        shared_log_properties.merge({
          :routing_key => "info.application.hbx_enterprise.payment_processor_enrollment_drop_listener.service_response",
        }),
        {
          policy_xml: payload,
          service_response: location
        }.to_json
      )
      allow(event_broadcaster).to receive(:broadcast).with(
        expected_broadcast_properties,
        payload
      )
      allow(channel).to receive(:acknowledge).with(delivery_tag, false)
    end

    let(:shared_log_properties) do
      {
        :timestamp => current_time.to_i,
        :headers => headers.merge({
          :return_status => "200"
        })
      }
    end

    let(:expected_broadcast_properties) do
      {
        :timestamp => current_time.to_i,
        :routing_key => "info.events.payment_processor_transaction.transmitted",
        :headers => headers.merge({
          :return_status => "200",
          :upload_location => location
        })
      }
    end

    it "acks the message" do
      expect(channel).to receive(:acknowledge).with(delivery_tag, false)
      subject.on_message(delivery_info, properties, payload)
    end

    it "logs successful processing" do
      expect(event_broadcaster).to receive(:broadcast).with(
        shared_log_properties.merge({
          :routing_key => "info.application.hbx_enterprise.payment_processor_enrollment_drop_listener.policy_uploaded",
        }),
        payload
      )
      subject.on_message(delivery_info, properties, payload)
    end

    it "logs the service response" do
      expect(event_broadcaster).to receive(:broadcast).with(
        shared_log_properties.merge({
          :routing_key => "info.application.hbx_enterprise.payment_processor_enrollment_drop_listener.service_response",
        }),
        {
          policy_xml: payload,
          service_response: location
        }.to_json
      )
      subject.on_message(delivery_info, properties, payload)
    end

    it "sends the uploaded notification" do
      expect(event_broadcaster).to receive(:broadcast).with(
        expected_broadcast_properties,
        payload
      )
      subject.on_message(delivery_info, properties, payload)
    end
  end
end
