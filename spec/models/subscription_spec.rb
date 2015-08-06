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

  describe 'default order' do
    subject { Subscription.all }
    let(:user) { create(:user) }
    let(:board) { create(:board, :with_columns, user: user) }
    let!(:subscription_new) { create(:subscription, user: user, board: board, date_to: Time.current) }
    let!(:subscription_old) { create(:subscription, user: user, board: board, date_to: Time.current - 1.month) }

    it { is_expected.to have(2).items }
    its(:first) { is_expected.to eq subscription_old }
    its(:last) { is_expected.to eq subscription_new }
  end
end
