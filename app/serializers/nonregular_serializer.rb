class NonregularSerializer < ActiveModel::Serializer
    attributes :id, :date, :time_start, :time_end, :band_id
    

    attribute :time_start do
      object.time_start_f
    end

    attribute :time_end do
      object.time_end_f
    end

  end
  