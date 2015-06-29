RSpec.describe BoardHistory, type: :model do
  describe 'validations' do
    subject { BoardHistory.new }
    it { is_expected.to validate_presence_of(:collected_on) }
    it { is_expected.to validate_presence_of(:data) }
    it { is_expected.to validate_uniqueness_of(:collected_on) }
  end
end
