module Creepycrawler
  class Page
    attr_accessor :url,:body

    def initialize(url)
      @url = Addressable::URI.parse(url).normalize
      @robotstxt = WebRobots.new "CreepyCrawler"
    end

    # retrieve page
    def fetch
      @body = Nokogiri::HTML(open(@url, :allow_redirections => :all))
    end

    def links
      # if we haven't fetched the page, get it
      fetch if @body.nil?
      
      # using nokogiri, find all anchor elements
      hyperlinks = @body.css('a')
      
      # get array of links on page - remove any empty links and convert relative to absolute
      @links = hyperlinks.map {|link| link.attribute('href').to_s}.uniq.sort.delete_if{|href| href.empty? or href == "#"}.map{|link| relative_to_absolute_link(link)}
    end

    def relative_to_absolute_link(link)
      uri = Addressable::URI.parse(link).normalize
      # this url was relative, prepend our known domain
      if uri.host.nil? 
        # take base site and current link path to get absolute
        return "#{@url.site}#{uri.path}"
      else
        return link 
      end
    end

    def robots_disallowed?
      return @robotstxt.disallowed? @url 
    end

  end 
end