require "rails_helper"

describe TrackStats do
  describe ".hidden_content" do
    subject { TrackStats.hidden_content(hash) }
    context :empty do
      let(:hash) { {} }
      it { is_expected.to eq "\n<!---\n@agileseason:{}\n-->" }
    end

    context :not_empty do
      let(:hash) { { track_stats: { column: 1 } } }
      it { is_expected.to eq "\n<!---\n@agileseason:{\"track_stats\":{\"column\":1}}\n-->" }
    end
  end

  describe ".track" do
    let(:current) { Time.new(2014, 11, 19) }
    before { allow(Time).to receive(:current).and_return(current) }

    context :first_init do
      subject { TrackStats.track(column_id) }
      let(:column_id) { 21 }

      it { is_expected.to eq "\n<!---\n@agileseason:{\"track_stats\":{\"columns\":{\"#{column_id}\":{\"in_at\":\"#{current}\",\"out_at\":null}}}}\n-->" }
    end

    context :fix_wrong_hidden_content do
      subject { TrackStats.track(1, hash) }
      let(:column_id) { 1 }

      context :nil do
        let(:hash) { nil }
        it { is_expected.to eq "\n<!---\n@agileseason:{\"track_stats\":{\"columns\":{\"#{column_id}\":{\"in_at\":\"#{current}\",\"out_at\":null}}}}\n-->" }
      end

      context :empty do
        let(:hash) { {} }
        it { is_expected.to eq "\n<!---\n@agileseason:{\"track_stats\":{\"columns\":{\"#{column_id}\":{\"in_at\":\"#{current}\",\"out_at\":null}}}}\n-->" }
      end
    end

    context :second_column_track do
      let(:column_id_1) { 21 }
      let(:column_id_2) { 22 }
      let(:hash) { { track_stats: { columns: { column_id_1 => { in_at: (current - 1.minute).to_s, out_at: nil } } } } }
      subject { TrackStats.track(column_id_2, hash) }

      it { is_expected.to eq "\n<!---\n@agileseason:{\"track_stats\":{\"columns\":{\"#{column_id_1}\":{\"in_at\":\"#{current - 1.minute}\",\"out_at\":\"#{current}\"},\"22\":{\"in_at\":\"#{current}\",\"out_at\":null}}}}\n-->" }
    end

    context :thrid_column_track do
      let(:column_id_1) { 21 }
      let(:column_id_2) { 22 }
      let(:column_id_3) { 23 }
      let(:hash) do
        {
          track_stats: {
            columns: {
              column_id_1 => { in_at: (current - 2.minute).to_s, out_at: (current - 1.minute).to_s },
              column_id_2 => { in_at: (current - 1.minute).to_s, out_at: nil }
            }
          }
        }
      end
      subject { TrackStats.track(column_id_3, hash) }

      it { is_expected.to eq "\n<!---\n@agileseason:{\"track_stats\":{\"columns\":{\"21\":{\"in_at\":\"#{current - 2.minute}\",\"out_at\":\"#{current - 1.minute}\"},\"22\":{\"in_at\":\"#{current - 1.minute}\",\"out_at\":\"#{current}\"},\"23\":{\"in_at\":\"#{current}\",\"out_at\":null}}}}\n-->" }
    end

    context :not_rewrite_in_at do
      subject { TrackStats.track(column_id, hash) }
      let(:column_id) { 22 }
      let(:time_s) { (Time.current - 10.minutes).to_s }
      let(:hash) { { track_stats: { columns: { column_id.to_s => { in_at: time_s, out_at: time_s } } } } }

      it { is_expected.to eq "\n<!---\n@agileseason:{\"track_stats\":{\"columns\":{\"#{column_id}\":{\"in_at\":\"#{time_s}\",\"out_at\":null}}}}\n-->" }
    end
  end

  describe '.extract' do
    subject { TrackStats.extract(body) }

    context :empty do
      let(:body) { "\n<!---\n@agileseason:{}\n-->" }
      let(:hash) { {} }
      it { expect(subject[:comment]).to be_empty }
      it { expect(subject[:hash]).to eq hash }
      it { expect(subject[:tail]).to be_empty }
    end

    context :by_symbol do
      let(:body) { "\n<!---\n@agileseason:{\"x\":\"1\"}\n-->" }
      it { expect(subject[:hash][:x]).to eq "1" }
    end
  end

  describe '.current_column' do
    subject { TrackStats.current_column(hash) }
    let(:time_1) { Time.current }

    context :has_one_column do
      let(:hash) { { track_stats: { columns: { "21" => { in_at: time_1.to_s, out_at: nil } } } } }
      it { is_expected.to eq "21" }
    end

    context :has_two_column do
      let(:hash) { { track_stats: { columns: { "21" => { in_at: time_1.to_s, out_at: time_1.to_s }, "22" => { in_at: time_1.to_s, out_at: nil } } } } }
      it { is_expected.to eq "22" }
    end
  end

  describe '.remove_columns' do
    subject { TrackStats.remove_columns(hash, columns_ids) }
    let(:time_s) { Time.current.to_s }
    let(:columns_ids) { [22, 23] }

    context :nothing_to_remove do
      let(:hash) { { track_stats: { columns: { "21" => {} } } } }
      it { is_expected.to eq hash }
    end

    context :has_to_remove do
      let(:hash) { { track_stats: { columns: { "21" => {}, "22" => {}, "23" => {} } } } }
      let(:expected_hash) { { track_stats: { columns: { "21" => {} } } } }
      it { is_expected.to eq expected_hash }
    end

    context :empty do
      let(:hash) { {} }
      it { is_expected.to be_empty }
    end
  end
end
