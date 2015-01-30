FactoryGirl.define do
  factory :issue_stat do
    board nil
    sequence :number do |n|
      n
    end
    closed_at nil

    trait :open do
      closed_at nil
    end

    trait :closed do
      transient do
        wip 1
      end

      after(:build) do |issue_stat, evaluator|
        issue_stat.closed_at = Time.current unless issue_stat.closed_at
        issue_stat.created_at = issue_stat.closed_at - evaluator.wip.days unless issue_stat.created_at
        issue_stat.updated_at = issue_stat.created_at unless issue_stat.updated_at
      end
    end
  end
end
