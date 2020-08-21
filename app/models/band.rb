class Band < ApplicationRecord
    has_many :user_bands, dependent: :destroy
    has_many :users, through: :user_bands

    validates :name, presence: true, length: {maximum: 30}, uniqueness: true

    def attributes
        {
            'id' => nil,
            'name' => nil,
            'user_ids' => nil,
        }
    end
end
