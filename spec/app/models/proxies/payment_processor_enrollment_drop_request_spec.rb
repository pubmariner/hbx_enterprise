require "spec_helper"

describe Proxies::PaymentProcessorEnrollmentDropRequest do
  subject { Proxies::PaymentProcessorEnrollmentDropRequest.new }
  let(:f_path) { "/fake_location/file"}
  let(:payload) { double }

  before do
    allow(subject).to receive(:resolve_path).with(payload).and_return(f_path)
    allow(subject).to receive(:upload_file).with(payload, f_path).and_return(nil)
  end

  it "returns the proper file path" do
    expect(subject.request(payload)).to eq ["200", f_path]
  end
end
