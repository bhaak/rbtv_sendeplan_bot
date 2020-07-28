require 'reddit_bot'

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

      if last_posting && today.cweek != Time.at(last_posting['created']).to_date.cweek
        # new week, create a new posting
        @bot.json :post, "/api/submit", {
          sr: @subreddit,
          kind: "self",
          title: title,
          text: @text.join("\n\n"),
        }
      else
        # update existing posting
        @bot.json :post, "/api/editusertext", {
          thing_id: @last_posting['name'],
          text: @text.join("\n\n"),
        }
      end
    end

    private

    def last_posting
      return @last_posting if @last_posting

      postings = @bot.json :get, "/user/#{@bot.name}/submitted"
      @last_posting = postings['data']['children'].find {|posting|
        posting['data']['subreddit_name_prefixed'] == @subreddit
      }
      @last_posting = @last_posting['data'].slice('created','id','name')
    end

  end
end
