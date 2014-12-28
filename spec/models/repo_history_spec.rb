RSpec.describe RepoHistory, type: :model do
  describe :validates do
    subject { RepoHistory.new }
    it { is_expected.to validate_presence_of :board }
    it { is_expected.to validate_presence_of :collected_on }
  end
end
