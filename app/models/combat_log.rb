class CombatLog < ApplicationRecord
  belongs_to :player, class_name: "Player"
  belongs_to :attacker, class_name: "Player"
  belongs_to :server
end
