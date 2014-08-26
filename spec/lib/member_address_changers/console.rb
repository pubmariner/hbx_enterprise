require 'spec_helper'

shared_examples "a failed console import" do |expected_error|

  it "should print the expected error" do
    expect(subject).to receive(:puts).with(expected_error)
    subject.fail
  end

end

describe MemberAddressChangers::Console do
  subject { MemberAddressChangers::Console.new(12354) }

  describe "with a non-existant member" do
    before do
      subject.no_such_member(:member_id => 12354)
    end

    it_behaves_like "a failed console import", "Member 12354 does not exist"
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

  describe "when successful" do
    it "should display the successful member id" do
      expect(subject).to receive(:puts).with("Member 12354 address changed successfully!")
      subject.success
    end
  end
end
