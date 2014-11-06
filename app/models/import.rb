class Import < ActiveRecord::Base
  has_many :fan_duel_players
  has_many :overunders
end
