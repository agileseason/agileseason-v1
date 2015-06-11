FactoryGirl.define do
  factory :activity do
    user
    board nil
    data nil
  end

  factory :archive_activity, parent: :activity, class: 'Activities::ArchiveActivity' do
    type 'Activities::ArchiveActivity'
  end

  factory :column_changed_activity, parent: :activity, class: 'Activities::ColumnChangedActivity' do
    type 'Activities::ColumnChangedActivity'
  end

  factory :change_due_date_acivity, parent: :activity, class: 'Activities::ChangeDueDate' do
    type 'Activities::ChangeDueDate'
  end
end
