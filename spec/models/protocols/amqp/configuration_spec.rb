require "spec_helper"

module PAConfigurationMocking
  def mock_connection_object(expected_connection_string, expected_channel_object)
    Struct.new(:connection_url) do 

      def initialize(c_url)
        super(c_url)
        raise "Connection initialized with wrong URL" unless c_url == expected_connection_string
        @connection_started = false
      end

      def start
        @connection_started = true
      end

      def create_channel
        raise "Connection not started!" unless @connection_started
        expected_channel_object
      end
    end
  end

  module_function :mock_connection_object
end

describe Protocols::Amqp::Configuration do
  subject { Protocols::Amqp::Configuration }

  it "should have the connection url" do
    expect(subject.connection_url).not_to be_nil
  end

  it "should provide a connection when instructed" do
    channel_mock = double
    connection_object_mock = PAConfigurationMocking.mock_connection_object(
      subject.connection_url,
      channel_mock
    )
    expect(subject.connection(connection_object_mock)).to eq(channel_mock)
  end

  it "should provide a good default connection when asked", :integration => "amqp" do
    channel = subject.connection
    expect(channel).to be_kind_of(Bunny::Channel)
  end
end
