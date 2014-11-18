# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :board do
    name "MyString"
    type ""
  end

  factory :board_with_columns do
    after(:build) do |user, evaluator|
      columns [build(:column, board: self)]
    end
  end
end
