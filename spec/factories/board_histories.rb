FactoryGirl.define do
  factory :board_history do
    board nil
    data [{ issues: 0, issues_cumulative: 0 }]
    collected_on Date.today
  end
end
