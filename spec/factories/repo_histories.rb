FactoryGirl.define do
  factory :repo_history do
    board
    collected_on Date.today
    lines 1
  end
end
