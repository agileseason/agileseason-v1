FactoryGirl.define do
  factory :subscription do
    user
    board nil
    date_to 1.month.since
    cost 3.99
  end
end
