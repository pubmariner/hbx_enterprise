require 'spec_helper'

shared_examples "a failed console import" do |expected_errors|

  it "should print the expected error" do
    Array(expected_errors).each do |err|
      expect(subject).to receive(:puts).with(err)
    end
    subject.fail
  end

end

describe MemberAddressChangers::Console do
  let(:request) { OpenStruct.new(:member_id => 12354) }
  subject { MemberAddressChangers::Console.new(request) }

  describe "with a non-existant member" do
    before do
      subject.no_such_member(:member_id => 12354)
    end

    it_behaves_like "a failed console import", "Member 12354 does not exist"
  end

  describe "with a policy that has a responsible party" do
    before do
      subject.responsible_party_on_policy(:policy_id => "123547")
    end

    it_behaves_like "a failed console import", "Policy 123547 has a responsible party"
  end

  describe "when the member has more than one active health policy" do
    before do
      subject.too_many_health_policies(:member_id => 12354)
    end

    it_behaves_like "a failed console import", "Member 12354 has too many active health policies"
  end

  describe "when the member has more than one active dental policy" do
    before do
      subject.too_many_dental_policies(:member_id => 12354)
    end

    it_behaves_like "a failed console import", "Member 12354 has too many active dental policies"
  end

  describe "when the member has no active policies" do
    before do
      subject.no_active_policies(:member_id => 12354)
    end

    it_behaves_like "a failed console import", "Member 12354 has no active policies"
  end

  describe "when the address is invalid" do
    before do
      subject.invalid_address({:zip_code => ["can't be blank"], :address1 => ["can't be blank"]})
    end

    it_behaves_like "a failed console import", [
      "Address invalid: zip_code can't be blank",
      "Address invalid: address1 can't be blank"]
  end

  describe "when successful" do
    it "should display the successful member id" do
      expect(subject).to receive(:puts).with("Member 12354 address changed successfully!")
      subject.success
    end
  end
end
