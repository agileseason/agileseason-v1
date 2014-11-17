class Column < ActiveRecord::Base
  belongs_to :board

  def label_name
    "[#{order}] #{name}"
  end
end
