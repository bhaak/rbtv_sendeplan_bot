require 'open-uri'
require 'json'

require 'rbtv_sendeplan_bot/util'

module RbtvSendeplanBot
  class Sendeplan
    def initialize weekday=Date.today
      startDay = weekday.to_time + 10*60*60
      endDay   = startDay + 8*86400 - 1
      url = "https://api.rocketbeans.tv/v1/schedule/normalized?startDay=#{startDay.to_i}&endDay=#{endDay.to_i}"
      URI.open(url) {|request|
        @schedule = JSON.parse(request.read, symbolize_names: true)
      }

      url = "https://api.rocketbeans.tv/v1/schedule/publish?from=#{startDay.to_i}"
      URI.open(url) {|request|
        @uploads = JSON.parse(request.read, symbolize_names: true)
      }
    end

    def format_entry entry
      display_title = Util.display_title entry

      time = entry[:timeStart] || entry[:uploadDate] || entry[:distributionPublishingDate]
      start_time = Time.parse(time).localtime.strftime("%H:%M")
      publishing_date = Time.parse(entry[:publishingDate]).localtime.strftime("%Y-%m-%d %H:%M") if entry[:publishingDate]

      {
        # day starts at 06:00, show night time programmes on previous day
        day: (Time.parse(time).localtime - 6*60*60).to_date,
        sorting_time: time,
        starttime: start_time,
        publishingDate: publishing_date,
        title: display_title,
        duration: entry[:duration],
        type: (entry[:type] || "upload").to_sym,
        streamExclusive: entry[:streamExclusive],
        episodeId: entry[:episodeId],
        openEnd: entry[:openEnd],
        bohnen: entry[:bohnen] ? entry[:bohnen].map {|b| b[:name] }.sort.join(', ') : []
      }
    end

    def weekly_schedule weekday=Date.today
      schedule = @schedule[:data].map {|day|
        #puts Time.parse(day[:date]).localtime.to_date
        day[:elements].map {|entry|
          format_entry(entry)
        }
      }.flatten.uniq
      uploads = @uploads[:data].map {|day|
        next if day[:elements].nil?
        day[:elements].map {|entry|
          format_entry(entry)
        }
      }.flatten.uniq

      (schedule + uploads).sort_by {|e| [e[:day], e[:type].to_s.bytes.first * -1, e[:sorting_time]] }
    end

  end
end
