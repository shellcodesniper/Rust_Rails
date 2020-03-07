class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

#   attr_accessor :username, :realname, :steamid
#   validates :username, presence: true
#   validates :realname, presence: true
#   validates :steamid, presence: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
