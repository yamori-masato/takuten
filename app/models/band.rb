class Band < ApplicationRecord
    has_many :user_bands, dependent: :destroy
    has_many :users, through: :user_bands

    has_many :nonregulars, -> { where(type: "Activity::Nonregular") }, class_name: "Activity::Nonregular", dependent: :destroy
    has_many :regulars, -> { where(type: "Activity::Regular") }, class_name: "Activity::Regular", dependent: :destroy
    
    validates :name, presence: true, length: {maximum: 30}, uniqueness: true

 
end
