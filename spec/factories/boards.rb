FactoryGirl.define do
  factory :board do
    name 'test_board'
    type "Boards::KanbanBoard"
    github_id 123

    trait :with_columns do
      ignore do
        number_of_columns 1
      end
      after(:build) do |board, evaluator|
        board.columns = evaluator.number_of_columns.times.each_with_object([]) do |n, columns|
          columns << FactoryGirl.build(:column, board: board, name: "column_#{n}")
        end
      end
    end
  end
end
