FactoryGirl.define do
  factory :policy do
    sequence(:eg_id, 1111111111111111111) { |n| "#{n}" } 
  end
end
