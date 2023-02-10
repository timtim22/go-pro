class User < ApplicationRecord
  require 'securerandom'
  has_many :videos

  has_secure_password

  validates :email, presence: true
  validates :email, uniqueness: true
  validates :password, presence: true
end
