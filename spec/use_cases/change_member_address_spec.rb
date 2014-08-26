require "spec_helper"

shared_examples "a failed execution" do |notify_msg, notify_args|

  it "and should signal the error with :#{notify_msg} and fail" do
    expect(listener).to receive(notify_msg).with(notify_args)
    expect(listener).to receive(:fail)
  end
end 

describe ChangeMemberAddress do
    let(:listener) { double }

    describe "with a non-existant member" do
      it_behaves_like "a failed execution", :no_such_member, {}
    end

    describe "when the member has more than one active health policy" do
      it_behaves_like "a failed execution", :too_many_health_policies, {}
    end

    describe "when the member has more than one active dental policy" do
      it_behaves_like "a failed execution", :too_many_dental_policies, {}
    end

    describe "when the member has no active policies" do
      it_behaves_like "a failed execution", :no_active_policies, {}
    end

    describe "with a member that has one active dental and one active health policy" do
      it "should transmit the changes on both policies"
    end

    describe "with a member that has one active, one terminated, and one cancelled health policy" do
      it "should only transmit changes to the active policy"
    end

    describe "with a single active health policy" do
      describe "which has a spouse at the same address" do
        it "should also update the spouse"
      end 

      describe "which has a child at a different same address" do
        it "should not update the child"
      end 
    end

end
