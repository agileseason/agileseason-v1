describe Activity do
  describe 'validations' do
    subject { Activity.new }

    it { is_expected.to validate_presence_of(:user) }
  end
end
