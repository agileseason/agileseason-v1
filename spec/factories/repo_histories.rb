# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :repo_history do
    board
    collected_on "2014-12-07"
    lines 1
  end
end
