require 'spec_helper'

describe Queries::PersonMemberQuery do

  let(:member_ids) { [1, 2] }

  subject { Queries::PersonMemberQuery.new(member_ids) }

  its(:query) { should eq({
    "members" => {
      "$elemMatch" => {
        "hbx_member_id" => { "$in" => member_ids }
      }
    }
  }) }
end
