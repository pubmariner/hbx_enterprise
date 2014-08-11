require "spec_helper"

describe Protocols::Amqp::Configuration do
  subject { Protocols::Amqp::Configuration }

  it "should have the connection url" do
    expect(subject.connection_url).not_to be_nil
  end

end
