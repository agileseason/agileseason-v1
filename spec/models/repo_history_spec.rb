RSpec.describe RepoHistory, type: :model do
  describe 'validations' do
    subject { RepoHistory.new }
    it { is_expected.to validate_presence_of :board }
    it { is_expected.to validate_presence_of :collected_on }
    it { is_expected.to validate_uniqueness_of :collected_on }
  end
end
