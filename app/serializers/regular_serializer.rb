class RegularSerializer < ActiveModel::Serializer
  attributes :id, :date_start, :time_start_f, :time_end_f, :band_id

  attribute :exception_times do
    object.exception_times.map{|et| et.date}
  end

end
