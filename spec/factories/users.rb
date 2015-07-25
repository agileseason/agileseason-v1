FactoryGirl.define do
  factory :user do
    email 'test@mail.com'
    github_username 'blackchstunt_test'
    utm { { source: nil, campaign: nil, medium: nil } }

    trait :with_utm do
      utm { { source: 'test_source', campaign: 'test_campaign', medium: 'test_medium' } }
    end
  end
end
