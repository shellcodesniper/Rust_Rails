class Messagelog < ApplicationRecord
  belongs_to :player
  belongs_to :server
end
