class RegularSerializer < ActiveModel::Serializer
  attributes :id, :date_start, :time_start, :time_end, :band_id

  attribute :time_start do
    object.time_start_f
  end

  attribute :time_end do
    object.time_end_f
  end

  attribute :exception_times do
    object.exception_times.map{|et| et.date}
  end

end
