module RbtvSendeplanBot
  class SendeplanFormatter
    def initialize days:, sendeplan:, tty: false, reddit: false
      @days = days
      @tty = tty
      @reddit = reddit
      @sendeplan = sendeplan
    end

    def format
      subreddit = @reddit
      w = @sendeplan.weekly_schedule

      text = []

      @days.each {|day|
        titel = ""
        titel << "**" if subreddit
        titel << "Programm vom #{WOCHENTAG[day.wday]}, dem #{day.day}. #{MONAT[day.month]} #{day.year}"
        titel << "**" if subreddit
        text << titel

        w.select {|e| e[:day] == day }.each {|e|
          if [:live, :premiere].include? e[:type] || e[:streamExclusive]
            programme = ""
            programme << "#{e[:starttime]} [#{e[:type].to_s[0].upcase}] "
            programme << "*" if subreddit && e[:type] == :live
            programme << "#{e[:title]} (#{e[:duration]/60} Minuten)"
            programme << "*" if subreddit && e[:type] == :live
            text << programme
          end
        }
        text << ""
      }
      text << "Dieses Posting wird täglich aktualisiert. Der vollständige Sendeplan von RBTV ist unter https://rocketbeans.tv/sendeplan zu finden."
    end
  end
end
