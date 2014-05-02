module Creepycrawler
  class Page
    attr_accessor :url,:body

    def initialize(url)
      # todo: validate a url was passed in
      # fetch site and set url if successful. Handles redirects
      response = open(url, :allow_redirections => :all)
      @url = Addressable::URI.parse(response.base_uri)
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
      
      # get array of links on page - remove any empty links
      @links = hyperlinks.map {|link| link.attribute('href').to_s}.uniq.sort.delete_if{|href| href.empty? or href == "#"}.map{|link| relative_to_absolute_link(link)}
    end

    def relative_to_absolute_link(link)
      uri = Addressable::URI.parse(link).normalize
      # this url was relative, prepend our known domain
      if uri.host.nil? 
        return "#{@url}#{link.gsub(/^\//,'')}"
      else
        return link 
      end
    end

  end 
end