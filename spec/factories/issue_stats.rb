FactoryGirl.define do
  factory :issue_stat do
    board
    sequence :number do |n|
      n
    end
    closed_at nil

    trait :open do
      closed_at nil
    end

    trait :closed do
      closed_at Time.current
    end
  end
end
