require "rbtv_sendeplan_bot/version"
require "rbtv_sendeplan_bot/sendeplan"
require "rbtv_sendeplan_bot/reddit"

require 'optparse'

WOCHENTAG = [:Sonntag, :Montag, :Dienstag, :Mittwoch, :Donnerstag, :Freitag, :Samstag, :Sonntag]
MONAT = [nil,
         :Januar, :Februar, :März, :April, :Mai, :Juni,
         :Juli, :August, :September, :Oktober, :November, :Dezember]

subreddit = nil

OptionParser.new do |parser|
  parser.separator "Show the RBTV programme schedule"
  parser.separator ""
  parser.separator "Options:"
  parser.on('-r', '--subreddit=SUBREDDIT', 'Comma separated list of subreddits') {|r| subreddit = "r/#{r}" }
end.parse!

sendeplan = RbtvSendeplanBot::Sendeplan.new
w = sendeplan.weekly_schedule

text = []

[Date.today, Date.today+1].each {|day|
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

if subreddit
  reddit = RbtvSendeplanBot::Reddit.new subreddit: subreddit, text: text
  reddit.post
else
  puts text
end
