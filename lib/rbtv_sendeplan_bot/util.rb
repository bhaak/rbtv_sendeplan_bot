module RbtvSendeplanBot
  module Util
    def self.display_title entry
      show_title = entry[:showTitle].to_s.strip
      title = entry[:title].to_s.strip
      title = title.gsub(/ -$/, "").to_s.strip
      sub_title = entry[:topic].to_s.strip

      title_parts = []
      title_parts << show_title if !title.start_with?(show_title)
      title_parts << title
      title_parts << sub_title if !title.include?(sub_title)

      title_parts.uniq.reject(&:empty?).take(2).join(" - ").gsub(/ +/, " ")
    end
  end
end
