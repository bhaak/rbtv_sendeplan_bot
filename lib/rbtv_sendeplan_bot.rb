require "rbtv_sendeplan_bot/version"
require "rbtv_sendeplan_bot/sendeplan"
require "rbtv_sendeplan_bot/published_videos"
require "rbtv_sendeplan_bot/sendeplan_formatter"
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

if Date.today.sunday?
  days = [Date.today, Date.today+1]
else
  days = (0..6).map {|i| Date.today + i }
  days = days[0..days.find_index(&:sunday?)]
end
text = RbtvSendeplanBot::SendeplanFormatter.new(days: days, reddit: !!subreddit).format

if subreddit
  reddit = RbtvSendeplanBot::Reddit.new subreddit: subreddit, text: text
  reddit.post
else
  puts text
end
