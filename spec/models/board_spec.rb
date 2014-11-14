require 'rails_helper'

RSpec.describe Board, :type => :model do
  describe :validates do
    subject { Board.new }
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :type }
  end
end
