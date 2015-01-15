require 'spec_helper'

describe Listeners::EmployerDigestListener do
  let(:payload) { "" }
  let(:delivery_info) { double(:routing_key => routing_key) }
  let(:properties) { double(:headers => headers) }
  let(:channel) { double }
  let(:queue) { double }
  let(:csv) { [] }
  let(:headers) { double }
  let(:routing_key) { "" }

  subject { Listeners::EmployerDigestListener.new(channel, queue, csv) }

  it "should append data to the csv" do
    subject.on_message(delivery_info, properties, payload)
  end

end
