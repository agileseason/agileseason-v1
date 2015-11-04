describe RoadmapIssue do
  describe '#call' do
    subject do
      RoadmapIssue.call(
        issue_stat: issue_stat,
        free_time_at: free_time_at,
        cycle_time_days: cycle_time_days,
        column_ids: column_ids
      )
    end
    let(:issue) { BoardIssue.new(github_issue, issue_stat) }
    let(:free_time_at) { Time.zone.parse('2015-10-01') }
    let(:cycle_time_days) { 2 }
    let(:created_at) { free_time_at - 1.day }

    context 'without specific columns' do
      let(:column_ids) { [] }
      let(:issue_stat) do
        create(:issue_stat, created_at: created_at, closed_at: closed_at)
      end

      context 'closed' do
        let(:closed_at) { free_time_at + 1.days }

        its(:from) { is_expected.to eq created_at }
        its(:to) { is_expected.to eq closed_at }
        its(:free_time_at) { is_expected.to eq free_time_at }
        its(:cycletime) { is_expected.to eq closed_at - created_at }
      end

      context 'open' do
        let(:closed_at) { nil }

        its(:from) { is_expected.to eq created_at }
        its(:to) { is_expected.to eq free_time_at + cycle_time_days.days }
        its(:free_time_at) do
          is_expected.to eq free_time_at + cycle_time_days.days
        end
        its(:cycletime) do
          is_expected.to eq free_time_at + cycle_time_days.days - created_at
        end
      end
    end

    context 'with specific columns' do
      let(:column_ids) { [column.id] }
      let(:board) { build(:board, :with_columns) }
      let(:column) { board.columns.last }
      let(:issue_stat) do
        create(
          :issue_stat,
          board: board,
          column: column,
          created_at: created_at,
          closed_at: closed_at
        )
      end
      let(:closed_at) { nil }

      context 'no lifetimes' do
        it { is_expected.to be_nil }
      end

      context 'with other lifetimes' do
        let!(:lifetime) do
          create(:lifetime, issue_stat: issue_stat, column: other_column)
        end
        let(:other_column) { board.columns.first }

        it { is_expected.to be_nil }
      end

      context 'with lifetime' do
        let!(:lifetime) do
          create(
            :lifetime,
            issue_stat: issue_stat,
            column: column,
            in_at: in_at,
            out_at: out_at
          )
        end

        context 'in and out' do
          let(:in_at) { Time.zone.parse('2015-10-01') }
          let(:out_at) { in_at + 1.day }

          it { is_expected.not_to be_nil }
          its(:free_time_at) { is_expected.to eq free_time_at }
          its(:cycletime) { is_expected.to eq out_at - in_at }
        end

        context 'in but not out' do
          let(:in_at) { created_at + 1.day }
          let(:out_at) { nil }

          context 'open' do
            let(:closed_at) { nil }

            it { is_expected.not_to be_nil }
            its(:free_time_at) do
              is_expected.to eq free_time_at + cycle_time_days.days
            end
            its(:cycletime) do
              is_expected.to eq free_time_at + cycle_time_days.days - in_at
            end
          end

          context 'closed' do
            let(:closed_at) { created_at + 3.days }

            it { is_expected.not_to be_nil }
            its(:free_time_at) { is_expected.to eq free_time_at }
            its(:cycletime) { is_expected.to eq in_at - in_at } # max in_at
          end
        end
      end

      context 'with lifetimes' do
        let(:in_at_1) { Time.zone.parse('2015-10-01') }

        context 'in but not out - last column' do
          let!(:lifetime_1) do
            create(
              :lifetime,
              issue_stat: issue_stat,
              column: column,
              in_at: in_at_1,
              out_at: out_at_1
            )
          end
          let!(:lifetime_2) do
            create(
              :lifetime,
              issue_stat: issue_stat,
              column: column,
              in_at: out_at_1,
              out_at: nil
            )
          end
          let(:out_at_1) { in_at_1 + 1.day }

          it { is_expected.not_to be_nil }
          its(:free_time_at) do
            is_expected.to eq free_time_at + cycle_time_days.days
          end
          its(:cycletime) do
            is_expected.to eq free_time_at + cycle_time_days.days - in_at_1
          end
        end

        context 'in but not out - not last column' do
          let!(:lifetime_1) do
            create(
              :lifetime,
              issue_stat: issue_stat,
              column: column_1,
              in_at: in_at_1,
              out_at: out_at_1
            )
          end
          let!(:lifetime_2) do
            create(
              :lifetime,
              issue_stat: issue_stat,
              column: column_2,
              in_at: out_at_1,
              out_at: nil
            )
          end
          let(:column_1) { board.columns.first }
          let(:column_2) { board.columns.last }
          let(:out_at_1) { in_at_1 + 1.day }
          let(:column_ids) { [column_1] }

          it { is_expected.not_to be_nil }
          its(:free_time_at) { is_expected.to eq free_time_at }
          its(:cycletime) { is_expected.to eq out_at_1 - in_at_1 }
        end
      end
    end
  end
end
