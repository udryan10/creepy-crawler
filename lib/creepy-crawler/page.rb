module Creepycrawler
  # Represents a webpage and the methods to extract the details we need for our crawler
  class Page

    # page url
    attr_accessor :url
    # page html
    attr_reader :body

    def initialize(url)
      @url = Addressable::URI.parse(url).normalize
      @robotstxt = WebRobots.new("CreepyCrawler")
    end

    def body=(body)
      # convert to Nokogiri object
      @body = Nokogiri::HTML(body)
    end

    # retrieve page
    def fetch
      @body = Nokogiri::HTML(open(@url, :allow_redirections => :all))
    end

    # return all links on page
    def links
      # if we haven't fetched the page, get it
      fetch if @body.nil?
      
      # using nokogiri, find all anchor elements
      hyperlinks = @body.css('a')
      
      # get array of links on page - remove any empty links or links that are invalid 
      @links = hyperlinks.map {|link| link.attribute('href').to_s}.uniq.sort.delete_if do |href| 
        
        # if href is empty, points to an anchor, mailto or ftp delete
        invalid = true if href.empty? or /^#/ =~ href or /^mailto:/ =~ href or /^ftp:/ =~ href or /^javascript:/ =~ href

        # if Addressable throws an exception, we have an invalid link - delete
        begin
          Addressable::URI.parse(href)
        rescue
          invalid = true
        end
        invalid
      end

      # map all links to absolute
      @links.map{|link| relative_to_absolute_link(link)}
    end

    def relative_to_absolute_link(link)
      uri = Addressable::URI.parse(link).normalize

      # this url was relative, prepend our known domain
      if uri.host.nil?
        # take page base site and add to relative link to get absolute
        uri.site = @url.site
        return uri.to_s
      else
        # the url was already absolute - leave as is
        return uri.to_s
      end
    end

    def robots_disallowed?
      return @robotstxt.disallowed?(@url)
    end
  end 
end