FactoryGirl.define do
  factory :activity do
    user nil
    board nil
    data nil
  end

  factory :archive_activity, parent: :activity, class: 'Activities::ArchiveActivity' do
    type 'Activities::ArchiveActivity'
  end

  factory :column_changed_activity, parent: :activity, class: 'Activities::ColumnChangedActivity' do
    type 'Activities::ColumnChangedActivity'
  end
end
