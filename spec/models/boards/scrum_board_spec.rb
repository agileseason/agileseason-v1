describe Boards::ScrumBoard, type: :model do
  let(:board) { build(:scrum_board) }

  describe '#days_per_iteration' do
    subject { board.days_per_iteration }

    context 'default' do
      it { is_expected.to eq 14 }
    end

    context 'sepecific' do
      before { board.days_per_iteration = 42 }
      it { is_expected.to eq 42 }
    end
  end

  describe '#start_iteration' do
    subject { board.start_iteration }

    context 'default' do
      it { is_expected.to eq :monday }
    end

    context 'sepecific' do
      before { board.start_iteration = :friday }
      it { is_expected.to eq :friday }
    end
  end

  describe '#scrum_settings' do
    subject { board.scrum_settings }
    it { is_expected.to_not be_nil }
    it { expect(subject.days_per_iteration).to eq 14 }
    it { expect(subject.start_iteration).to eq 'monday' }
  end
end
