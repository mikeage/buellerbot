require 'twitter_ebooks'

require 'dotenv'  
Dotenv.load(".env")


class MyBot < Ebooks::Bot
  attr_reader :last
  def configure
    self.consumer_key = ENV['EBOOKS_CONSUMER_KEY']
    self.consumer_secret = ENV['EBOOKS_CONSUMER_SECRET']

    @last = 0
    @shortsuffix = " // Bueller?"
    @suffix = " // Anyone? Bueller?"
    @tweeted = false
  end

  def check_anyone(tweet)
    text = tweet.text.gsub("\n", " ")
    if text =~ /anyone\? *$/im
      #print "#{tweet.user.screen_name}: #{tweet.text}\n"
      if text =~ /anyone\? *anyone\?$/im
        rt = "RT @" + tweet.user.screen_name + ": " + text + @shortsuffix
      else
        rt = "RT @" + tweet.user.screen_name + ": " + text + @suffix
      end
      if rt.length <= 140
        #print "RTing |#{rt}|\n"
        reply(tweet, rt)
        @tweeted = true
      else
        #print "Skipping |#{rt}| from #{tweet.text} because it's too long\n"
      end
    else
      #print "Skipping: #{tweet.text} because it's not a question\n"
    end
    #print "Last is #{@last}, id is #{tweet.id}\n"
    if tweet.id > @last
      @last = tweet.id
    end
  end

  def do_search
    #print "Searching...\n"
    self.twitter.search("anyone?", result_type: "recent", since_id: @last).take(100).each do |tweet|
      if @tweeted == false
        check_anyone(tweet)
      end
    end
  end

  def on_startup
    do_search()
    scheduler.every '1m' do
      @tweeted = false
      do_search()
    end
  end

  def on_message(dm)
    # Reply to a DM
    # reply(dm, "secret secrets")
  end

  def on_follow(user)
    # Follow a user back
    follow(user.screen_name)
  end

  def on_mention(tweet)
    # Reply to a mention
    #reply(tweet, meta(tweet).reply_prefix + "Sorry, I don't know how to talk.")
  end

  def on_timeline(tweet)
    # Reply to a tweet in the bot's timeline
    # reply(tweet, meta(tweet).reply_prefix + "nice tweet")
  end
end

# Make a MyBot and attach it to an account
MyBot.new("BuellerEconProf") do |bot|
  bot.access_token = ENV['EBOOKS_OAUTH_TOKEN']
  bot.access_token_secret = ENV['EBOOKS_OAUTH_TOKEN_SECRET']
end
