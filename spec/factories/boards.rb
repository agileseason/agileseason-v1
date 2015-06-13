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
        number_of_columns 2
      end
      after(:build) do |board, evaluator|
        board.columns = evaluator.number_of_columns.times.each_with_object([]) do |n, columns|
          columns << FactoryGirl.build(:column, board: board, name: "column_#{n + 1}", order: n + 1)
        end
      end
    end

    trait :set_columns do
      transient do
        names ['To Do']
      end
      after(:build) do |board, evaluator|
        n = 0
        board.columns = evaluator.names.map do |name|
          n += 1
          FactoryGirl.build(:column, board: board, name: name, order: n)
        end
      end
    end

    trait :public do
      after(:build) do |board|
        board.public = true
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
