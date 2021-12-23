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

      url = "https://api.rocketbeans.tv/v1/schedule/publish?from=#{startDay.to_i}"
      URI.open(url) {|request|
        @uploads = JSON.parse(request.read, symbolize_names: true)
      }
    end

    def format_entry entry
      show_title = entry[:showTitle].to_s.strip
      title = entry[:title].to_s.strip
      title = title.gsub(/ -$/, "").to_s.strip
      sub_title = entry[:topic].to_s.strip

      title_parts = []
      title_parts << show_title if !title.start_with?(show_title)
      title_parts << title
      title_parts << sub_title if !title.include?(sub_title)

      display_title = title_parts.uniq.reject(&:empty?).take(2).join(" - ").gsub(/ +/, " ")

      time = entry[:timeStart] || entry[:uploadDate]
      start_time = Time.parse(time).localtime.strftime("%H:%M")
      publishing_date = Time.parse(entry[:publishingDate]).localtime.strftime("%Y-%m-%d %H:%M") if entry[:publishingDate]

      {
        # day starts at 06:00, show night time programmes on previous day
        day: (Time.parse(time).localtime - 6*60*60).to_date,
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

      (schedule + uploads).sort_by {|e| [e[:day], e[:type].to_s.bytes.first * -1, e[:starttime]] }
    end

  end
end
