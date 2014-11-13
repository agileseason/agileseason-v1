class User < ActiveRecord::Base
  has_many :boards
end
