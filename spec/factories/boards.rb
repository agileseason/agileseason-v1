FactoryGirl.define do
  factory :board do
    user nil
    name 'test board'
    type 'Boards::KanbanBoard'
    github_id 123
    github_name 'test-board-repo'
    github_full_name 'test/test-board-repo'
    settings nil

    trait :with_columns do
      transient do
        number_of_columns 1
      end
      after(:build) do |board, evaluator|
        board.columns = evaluator.number_of_columns.times.each_with_object([]) do |n, columns|
          columns << FactoryGirl.build(:column, board: board, name: "column_#{n + 1}", order: n + 1)
        end
      end
    end

    factory :kanban_board, parent: :board, class: 'Boards::KanbanBoard' do
      type 'Boards::KanbanBoard'
    end

    factory :scrum_board, parent: :board, class: 'Boards::ScrumBoard' do
      type 'Boards::ScrumBoard'
    end
  end
end
