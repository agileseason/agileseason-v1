describe Activities::ArchiveActivity, type: :model do
  describe '#issue_number' do
    let(:activity) { build(:archive_activity, data: data) }
    subject { activity.issue_number }

    context :empty do
      let(:data) { nil }
      it { is_expected.to be_nil }
    end

    context :not_empty do
      let(:data) { { number: 1 } }
      it { is_expected.to eq 1 }
    end
  end
end
