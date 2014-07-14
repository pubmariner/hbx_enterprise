FactoryGirl.define do
  factory :email do
    email_type 'home'
    sequence(:email_address) { |n| "example#{n}@example.com" }

    trait :without_email_type do
      email_type ' '
    end

    trait :without_email_address do
      email_address ' '
    end

    factory :invalid_email, traits: [:without_email_type, :without_email_address]
  end
end