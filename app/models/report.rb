class Report < ApplicationRecord
  belongs_to :server
  belongs_to :player
  belongs_to :user
end
