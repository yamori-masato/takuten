class User < ApplicationRecord
    before_create -> { self.nickname ||= self.name }


    has_secure_password
    has_secure_token

    has_many :user_bands, dependent: :destroy
    has_many :bands, through: :user_bands

    validates :name, presence: true, length: {maximum: 15}, uniqueness: true
    validates :nickname, length: {maximum: 15}
    validates :password, presence: true, confirmation: true, on: :create

end
