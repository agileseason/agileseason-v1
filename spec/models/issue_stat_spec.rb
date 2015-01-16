RSpec.describe IssueStat, type: :model do
  describe :validates do
    subject { IssueStat.new }
    it { is_expected.to validate_presence_of :number }
    describe 'issue_stat should be uniq for github issue' do
      it { is_expected.to validate_uniqueness_of :number }
    end
  end
end
