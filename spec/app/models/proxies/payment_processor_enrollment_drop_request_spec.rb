require "spec_helper"

RSpec.describe Proxies::PaymentProcessorEnrollmentDropRequest do
  describe "which successfully uploads the file" do
    subject { Proxies::PaymentProcessorEnrollmentDropRequest.new }

    let(:upload_location) do
      "#{ExchangeInformation.pp_sftp_enrollment_path}/adds/#{uuid}_add.xml"
    end
    let(:payload) { "" }
    let(:uuid) { "acebedf1234234"}
    let(:parsed_xml) { double }
    let(:action_node) { double(:text => "add") }
    let(:net_ssh_instance) do
      double(
        sftp: double(
          connect!: sftp_instance
        )
      )
    end
    let(:sftp_instance) { 
      double(close_channel: :ok)
    }
    let(:iod_payload) { double }

    before(:each) do
      allow(SecureRandom).to receive(:uuid).and_return(uuid)
      allow(Nokogiri).to receive(:XML).with(payload).and_return(parsed_xml)
      allow(parsed_xml).to receive(:xpath).with("//proc:operation/proc:type", {
        :proc => "http://dchealthlink.com/vocabularies/1/process"
      }).and_return([action_node])
      allow(Net::SSH).to receive(:start).with(
        ExchangeInformation.pp_sftp_host,
        ExchangeInformation.pp_sftp_username,
        :password => ExchangeInformation.pp_sftp_password
      ).and_yield(net_ssh_instance)
      allow(StringIO).to receive(:new).with(payload).and_return(iod_payload)
      allow(sftp_instance).to receive(:upload!).with(iod_payload, upload_location)
    end

    it "returns success and the file path" do
      expect(subject.request(payload)).to eq ["200", upload_location]
    end
  end

end