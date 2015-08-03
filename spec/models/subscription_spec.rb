describe Subscription do
  describe 'relations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:board) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:date_to) }
    it do
      is_expected.to validate_numericality_of(:cost).
        is_greater_than_or_equal_to(0)
    end
  end
end
