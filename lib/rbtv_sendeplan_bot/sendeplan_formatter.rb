module RbtvSendeplanBot
  class SendeplanFormatter
    def initialize days:, reddit: false
      @days = days
      @sendeplan = RbtvSendeplanBot::Sendeplan.new(@days.min)

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
        titel = ""
        titel << @bold_begin
        titel << "Programm vom #{WOCHENTAG[day.wday]}, dem #{day.day}. #{MONAT[day.month]} #{day.year}"
        titel << @bold_end
        text << titel

        w.select {|e| e[:day] == day }.each {|e|
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

            programme << " (#{e[:duration]/60} Minuten)" if e[:duration]
            programme << " (ohne VOD)" if ohne_vod
            programme << @rerun_end if e[:type] == :rerun
            programme << @premiere_end if e[:type] == :premiere
            programme << @live_end if e[:type] == :live
            text << programme
          end
        }
        text << ""
      }
      update_notice = archival ? '' : "Dieses Posting wird täglich aktualisiert. "
      text << "#{update_notice}Der vollständige Sendeplan von RBTV ist unter https://rocketbeans.tv/sendeplan zu finden."
      text << "\nUnter https://redd.it/if366o wird eine Liste von gerade streamenden Bohnen bzw. VoDs ihrer letzten Livestream-Sessions gepflegt."
    end
  end
end
