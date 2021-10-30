require 'reddit_bot'
require 'htmlentities'

module RbtvSendeplanBot
  class Reddit

    def initialize subreddit:, text:
      @subreddit = subreddit
      @text = text
      @bot = RedditBot::Bot.new YAML.load(File.read "secrets.yaml")
    end

    def post
      today = Date.today
      title = "Sendeplan-Thread der Kalenderwoche #{today.strftime('%-V')} des Jahres #{today.year}"

      obsolete_posting = last_posting && today.cweek != Time.at(last_posting['created']).to_date.cweek
      if !last_posting || obsolete_posting
        if last_posting
          # new week, update old posting with complete week data
          last_monday = Time.at(last_posting['created']).to_date.yield_self {|date| date - date.cwday + 1 }
          days = (0..6).map {|i| last_monday + i }
          last_week = RbtvSendeplanBot::SendeplanFormatter.new(days: days, reddit: true).format(archival: true)
          puts "Update posting from last week #{last_posting['id']}"
          update_posting name: last_posting['name'], text: last_week.join("\n\n")

          # unsticky old posting
          @bot.json :post, "/api/set_subreddit_sticky", { id: last_posting['name'], state: false }
        end

        # new week, create a new posting
        puts "New posting for week #{today.cweek}"
        data = @bot.json :post, "/api/submit", {
          sr: @subreddit,
          kind: "self",
          title: title,
          text: @text.join("\n\n"),
        }
        name = data.dig('json', 'data', 'name')
        set_sticky name: name if name
      else
        htmlentities = HTMLEntities.new
        # update existing posting
        if @text != htmlentities.decode(last_posting['selftext']).split("\n\n")
          puts "Update existing posting #{last_posting['id']}"
          update_posting name: last_posting['name'], text: @text.join("\n\n")
        else
          puts "Text hasn't changed for posting #{last_posting['id']}"
        end
      end
    end

    private

    def update_posting(name:, text:)
      @bot.json :post, "/api/editusertext", {
        thing_id: name,
        text: text
      }
    end

    def set_sticky(name:)
      @bot.json :post, "/api/set_subreddit_sticky", {
        id: name,
        num: 4,
        state: true,
      }
    end

    def last_posting
      return @last_posting if @last_posting

      postings = @bot.json :get, "/user/#{@bot.name}/submitted"
      @last_posting = postings['data']['children'].find {|posting|
        posting['data']['subreddit_name_prefixed'] == @subreddit &&
          posting['data']['title'].include?('Sendeplan-Thread')
      }
      return nil if !@last_posting
      @last_posting = @last_posting['data'].slice('created','id','name','selftext')
    end

  end
end
