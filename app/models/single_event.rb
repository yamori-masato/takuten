class SingleEvent < Single
    validates :title, presence: true, length: {maximum: 30}
end
