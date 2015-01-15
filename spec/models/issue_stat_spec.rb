RSpec.describe IssueStat, type: :model do
  context :validates do
    subject { IssueStat.new }
    it { is_expected.to validate_presence_of :number }
  end
end
