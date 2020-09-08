class User < ApplicationRecord
    has_secure_password
    has_secure_token

    has_many :user_bands, dependent: :destroy
    has_many :bands, through: :user_bands

    validates :name, presence: true, length: {maximum: 15}, uniqueness: true
    validates :password, presence: true, confirmation: true, on: :create



    # def band_ids
    #     bands.map{|band| band.id}
    # end
end
