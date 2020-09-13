module ActivityMixin
    extend ActiveSupport::Concern

    included do
        belongs_to :band
        scope :band, -> (id){ where(band_id: id) }
    end



end