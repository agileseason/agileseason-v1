FactoryGirl.define do
  factory :user do
    email 'test@mail.com'
    github_username 'blackchstunt_test'
    utm {{ source: nil, campaign: nil, medium: nil }}
  end
end
