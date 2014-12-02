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
      it { is_expected.to eq "\n<!---\n@agileseason:{:track_stats=>{:column=>1}}\n-->" }
    end
  end

  describe ".track" do
    let(:current) { Time.new(2014, 11, 19) }
    before { allow(Time).to receive(:current).and_return(current) }

    context :first_init do
      subject { TrackStats.track(column_id) }
      let(:column_id) { 21 }

      it { is_expected.to eq "\n<!---\n@agileseason:{:track_stats=>{:columns=>{#{column_id}=>{:in_at=>\"#{current}\", :out_at=>nil}}}}\n-->" }
    end

    context :second_column_track do
      let(:column_id_1) { 21 }
      let(:column_id_2) { 22 }
      let(:hash) { { track_stats: { columns: { column_id_1 => { in_at: (current - 1.minute).to_s, out_at: nil } } } } }
      subject { TrackStats.track(column_id_2, hash) }

      it { is_expected.to eq "\n<!---\n@agileseason:{:track_stats=>{:columns=>{#{column_id_1}=>{:in_at=>\"#{current - 1.minute}\", :out_at=>\"#{current}\"}, 22=>{:in_at=>\"#{current}\", :out_at=>nil}}}}\n-->" }
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

      it { is_expected.to eq "\n<!---\n@agileseason:{:track_stats=>{:columns=>{#{column_id_1}=>{:in_at=>\"#{current - 2.minute}\", :out_at=>\"#{current - 1.minute}\"}, #{column_id_2}=>{:in_at=>\"#{current - 1.minute}\", :out_at=>\"#{current}\"}, #{column_id_3}=>{:in_at=>\"#{current}\", :out_at=>nil}}}}\n-->" }
    end
  end
end
