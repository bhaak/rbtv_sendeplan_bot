require "rbtv_sendeplan_bot/version"
require "rbtv_sendeplan_bot/sendeplan"

WOCHENTAG = [:Sonntag, :Montag, :Dienstag, :Mittwoch, :Donnerstag, :Freitag, :Samstag, :Sonntag]
MONAT = [nil,
         :Januar, :Februar, :März, :April, :Mai, :Juni,
         :Juli, :August, :September, :Oktober, :November, :Dezember]

sendeplan = RbtvSendeplanBot::Sendeplan.new
w = sendeplan.weekly_schedule

text = ""

[Date.today, Date.today+1].each {|day|
  text << "Programm vom #{WOCHENTAG[day.wday]}, dem #{day.day}. #{MONAT[day.month]} #{day.year}\n\n"

  w.select {|e| e[:day] == day }.each {|e|
    if [:live, :premiere].include? e[:type]
      text << "#{e[:starttime]} [#{e[:type].to_s[0].upcase}] #{e[:title]} (#{e[:duration]/60} Minuten)\n"
    end
  }
  text << "\n"
}
text << "Der vollständige Sendeplan von RBTV ist unter https://rocketbeans.tv/sendeplan zu finden.\n"
puts text
