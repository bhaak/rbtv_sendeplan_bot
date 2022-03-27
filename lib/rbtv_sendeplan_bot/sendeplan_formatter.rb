module RbtvSendeplanBot
  class SendeplanFormatter
    def initialize days:, reddit: false
      @days = days
      @sendeplan = RbtvSendeplanBot::Sendeplan.new(@days.min)
      @published_videos = RbtvSendeplanBot::PublishedVideos.new(Date.today-7)

      @bold_begin = @bold_end = ""
      @live_begin = @live_end = ""
      @premiere_begin = @premiere_end = ""
      @reddit = reddit
      if reddit
        @rerun_begin = @rerun_end = ""
        @bold_begin = @bold_end = "**"
        @live_begin = @live_end = "*"
      elsif $stdout.tty?
        @bold_begin = "\033[1m"
        @rerun_begin = "\033[1;30m"
        @premiere_begin = "\033[1;34m"
        @live_begin = "\033[1;31m"
        @bold_end = @live_end = @premiere_end = @rerun_end = "\033[0m"
      end
    end

    def format(archival: false)
      w = @sendeplan.weekly_schedule
      text = []

      @days.each {|day|
        items = w.select {|e| e[:day] == day }
        next if items.empty?

        titel = ""
        titel << @bold_begin
        titel << "Programm vom #{WOCHENTAG[day.wday]}, dem #{day.day}. #{MONAT[day.month]} #{day.year}"
        titel << @bold_end
        text << titel

        items.each {|e|
          keine_wiederholung = [:live, :premiere, :upload].include?(e[:type])
          ohne_vod = e[:streamExclusive]
          verlinken = @reddit && e[:episodeId].to_i > 0 && Date.today > e[:day]

          if keine_wiederholung || ohne_vod
            programme = ""
            programme << "#{e[:starttime]} [#{e[:type].to_s[0].upcase}] "
            programme << @live_begin if e[:type] == :live
            programme << @premiere_begin if e[:type] == :premiere
            programme << @rerun_begin if e[:type] == :rerun

            programme << "[" if verlinken
            programme << e[:title]
            programme << "](https://rocketbeans.tv/mediathek/video/#{e[:episodeId]})" if verlinken

            if e[:openEnd]
              programme << " (Open End)"
            elsif e[:duration]
              programme << " (#{e[:duration]/60} Minuten)"
            end

            programme << " (ohne VOD)" if ohne_vod
            programme << @rerun_end if e[:type] == :rerun
            programme << @premiere_end if e[:type] == :premiere
            programme << @live_end if e[:type] == :live
            text << programme
          end
        }
        text << ""
      }

      # Uploads
      if @published_videos.uploads.size > 0
        text << "#{@bold_begin}VOD-Uploads der letzten 7 Tage#{@bold_end}"
        @published_videos.uploads.each { |upload|
          verlinken = @reddit && upload[:episodeId].to_i > 0
          programme = ""
          upload_time = upload[:day].strftime("%d.%m.%Y")
          programme << "#{upload_time} #{upload[:starttime]} "
          programme << "[" if verlinken
          programme << upload[:title]
          programme << "](https://rocketbeans.tv/mediathek/video/#{upload[:episodeId]})" if verlinken
          text << programme
        }
        text << ""
      end

      # additional information
      update_notice = archival ? '' : "Dieses Posting wird täglich aktualisiert. "
      text << "#{update_notice}Der vollständige Sendeplan von RBTV ist unter https://rocketbeans.tv/sendeplan zu finden."
      text << "\nDer Uploadplan mit allen Uploads dieser Woche ist hier https://rocketbeans.tv/mediathek/uploadplan."
      text << "\nKurzfristige YouTube-Upload-Änderungen werden im Forum in diesem Thread kommuniziert https://forum.rocketbeans.tv/t/rbtv-youtube-uploads-channel-managment-ticker/91004/9999."
      text << "\nUnter https://redd.it/if366o wird eine Liste von gerade streamenden Bohnen bzw. VoDs ihrer letzten Livestream-Sessions gepflegt."
    end
  end
end
