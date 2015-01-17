FactoryGirl.define do
  factory :issue_stat do
    board
    sequence :number do |n|
      n
    end
    closed_at nil
  end
end
