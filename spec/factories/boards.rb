# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :board do
    name 'test_board'
    type "Boards::KanbanBoard"
    github_id 123

    trait :with_columns do
      after(:build) do |board|
        board.columns = [FactoryGirl.build(:column, board: board)] if board.columns.blank?
      end
    end
  end
end
