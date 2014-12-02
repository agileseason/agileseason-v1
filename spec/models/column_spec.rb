require 'rails_helper'

RSpec.describe Column, type: :model do
  describe ".label_name" do
    let(:column) { build(:column, name: "backlog", order: 1) }
    subject { column.label_name }
    it { is_expected.to eq "[1] backlog" }
  end
end
