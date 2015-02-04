FactoryGirl.define do
  factory :activity do
    user nil
    board nil
    data nil
  end

  factory :archive_activity, parent: :activity, class: 'Activities::ArchiveActivity' do
    type 'Activities::ArchiveActivity'
  end
end
