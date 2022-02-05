require 'open-uri'
require 'json'

module RbtvSendeplanBot
  class PublishedVideos < Sendeplan
    def initialize startDay
      @startDay = startDay
      url = "https://api.rocketbeans.tv/v1/media/episode/preview/newest?limit=50"
      #url = "https://api.rocketbeans.tv/v1/media/episode/preview/newest?limit=50&offset=50"
      URI.open(url) {|request|
        @uploads = JSON.parse(request.read, symbolize_names: true)
      }
    end

    def uploads
      videos = @uploads[:data][:episodes].map {|episode|
        next if @startDay > Date.parse(episode[:distributionPublishingDate])
        next if episode[:showName].to_s.end_with? " streamt"

        episode[:episodeId] = episode[:id]
        format_entry(episode)
      }.flatten.uniq.compact

      videos.sort_by {|e| [e[:day], e[:type].to_s.bytes.first * -1, e[:starttime]] }
    end

  end
end
