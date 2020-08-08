module RbtvSendeplanBot
  class SendeplanFormatter
    def initialize days:, sendeplan:, reddit: false
      @days = days
      @sendeplan = sendeplan

      @bold_begin = @bold_end = ""
      @live_begin = @live_end = ""
      @premiere_begin = @premiere_end = ""
      if reddit
        @bold_begin = @bold_end= "**"
        @live_begin = @live_end = "*"
      elsif $stdout.tty?
        @bold_begin = "\033[1m"
        @rerun_begin = "\033[1;30m"
        @premiere_begin = "\033[1;34m"
        @live_begin = "\033[1;31m"
        @bold_end = @live_end = @premiere_end = @rerun_end = "\033[0m"
      end
    end

    def format
      w = @sendeplan.weekly_schedule

      text = []

      @days.each {|day|
        titel = ""
        titel << @bold_begin
        titel << "Programm vom #{WOCHENTAG[day.wday]}, dem #{day.day}. #{MONAT[day.month]} #{day.year}"
        titel << @bold_end
        text << titel

        w.select {|e| e[:day] == day }.each {|e|
          if [:live, :premiere].include?(e[:type]) || e[:streamExclusive]
            programme = ""
            programme << "#{e[:starttime]} [#{e[:type].to_s[0].upcase}] "
            programme << @live_begin if e[:type] == :live
            programme << @premiere_begin if e[:type] == :premiere
            programme << @rerun_begin if e[:type] == :rerun
            programme << "#{e[:title]} (#{e[:duration]/60} Minuten)"
            programme << @rerun_end if e[:type] == :rerun
            programme << @premiere_end if e[:type] == :premiere
            programme << @live_end if e[:type] == :live
            text << programme
          end
        }
        text << ""
      }
      text << "Dieses Posting wird täglich aktualisiert. Der vollständige Sendeplan von RBTV ist unter https://rocketbeans.tv/sendeplan zu finden."
    end
  end
end
