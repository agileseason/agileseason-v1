FactoryGirl.define do
  factory :board_history do
    board nil
    collected_on Date.today
  end
end
