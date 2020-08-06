require 'open-uri'
require 'json'

module RbtvSendeplanBot
  class Sendeplan
    def initialize weekday=Date.today
      # ensure it's a Monday
      weekday = weekday - weekday.cwday + 1

      startDay = weekday.to_time + 10*60*60
      endDay   = startDay + 8*86400 - 1
      url = "https://api.rocketbeans.tv/v1/schedule/normalized?startDay=#{startDay.to_i}&endDay=#{endDay.to_i}"
      URI.open(url) {|request|
        @schedule = JSON.parse(request.read, symbolize_names: true)
      }
    end

    def weekly_schedule weekday=Date.today
      @schedule[:data].map {|day|
        #puts Time.parse(day[:date]).localtime.to_date
        day[:elements].map {|entry|
          sub_title = entry[:topic].to_s.strip
          title = entry[:title].to_s.strip
          title = sub_title.empty? ? title : "#{title} - #{sub_title}"
          start_time = Time.parse(entry[:timeStart]).localtime.strftime("%H:%M")

          {
            day: Time.parse(day[:date]).localtime.to_date,
            starttime: start_time,
            title: title,
            duration: entry[:duration],
            type: entry[:type].to_sym,
            streamExclusive: entry[:streamExclusive],
          }
        }
      }.flatten
    end

  end
end
