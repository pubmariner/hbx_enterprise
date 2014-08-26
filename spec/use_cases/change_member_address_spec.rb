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

end
