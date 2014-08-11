require "spec_helper"

describe Protocols::Amqp::Configuration do
  subject { Protocols::Amqp::Configuration }

  it "should have the connection url" do
    expect(subject.connection_url).not_to be_nil
  end

  it "should yield a connection when instructed" do
    channel_mock = double
    bunny_mock = double(:create_channel => channel_mock)
    allow(Bunny).to accept(:new).with(subject.connection_url).and_return(bunny_mock)
    expect(bunny_mock).to receive(:start)
    expect(subject.connection).to eq(channel_mock)
  end

end
