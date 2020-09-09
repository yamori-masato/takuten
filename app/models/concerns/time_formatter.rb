module TimeFormatter

    def time_format_filter(*column_names)
        column_names.each do |column_name|
            define_method "#{column_name}_f" do
                self[column_name].strftime("%H:%M:%S")
            end
        end
    end
end
