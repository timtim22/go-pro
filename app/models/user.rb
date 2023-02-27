class User < ApplicationRecord
  require 'securerandom'
  has_many :videos

  has_secure_password

  validates :email, presence: true
  validates :email, uniqueness: true, on: :create
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP } 
  validates :password, presence: true
end
