require 'factory_bot'
include FactoryBot::Syntax::Methods

range = 1..14
num = range.size




#User
range.each do |n|
    FactoryBot.create(:user)
end


#Band
range.each do |n|
    if n==1
        FactoryBot.create(:band, user_ids: [num, 1, 2])
    elsif n==num
        FactoryBot.create(:band, user_ids: [num-1, num, 1])
    else
        FactoryBot.create(:band, user_ids: [n-1, n, n+1])
    end
end





ms = Date.parse("2000/01/01")
section = [
    ["09:00:00", "11:00:00"],
    ["11:00:00", "13:00:00"],
    ["13:00:00", "15:00:00"],
    ["15:00:00", "17:00:00"],
    ["17:00:00", "18:30:00"],
    ["18:30:00", "20:00:00"],
].map{|s| s.map{|t| Time.parse(t)}}

#Timetable -------------------------------------------------1件以上必ず必要
Timetable.create(
    date_start: Date.parse("1000/01/01"),
    sections: section,
)



#Nonregular
# 毎日9:00~11:00をbandでローテーションして予約
31.times do |n|
    Activity::Nonregular.create(
        date: ms + n.days,
        time_start: section[0][0],
        time_end: section[0][1],
        band_id: (n % 7) + 1
                )
end


#Regular
7.times do |n|
    Activity::Regular.create(
        date_start: ms + n.days,
        time_start: section[0][0],
        time_end: section[0][1],
        band_id: (n % 7) + 1 + 7
                )
end

