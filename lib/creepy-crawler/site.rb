module Creepycrawler


  class Site 

    attr_reader :domain,:scheme,:url,:options,:crawl_queue, :page_crawl_count

    def initialize(url, options = {})
      response = open(url, :allow_redirections => :all)
      url_parsed = Addressable::URI.parse(response.base_uri)
      @domain = url_parsed.host
      @scheme = url_parsed.scheme
      @url = url_parsed.to_s
      @page_crawl_count = 0
      @options = options
      # add the initial url to our crawl queue
      @crawl_queue = [@url] 
      yield self if block_given?
    end
    
    def crawl
      loop do
        break if @crawl_queue.empty? or (!options[:max_page_crawl].nil? and @page_crawl_count >= options[:max_page_crawl])
        url = @crawl_queue.shift
        page = Page.new(url)
        # push each link onto our queue. todo: filter non-local and already visisted sites
        page.links.each do |link| 
          # we only want to crawl current domain, so only push local links
          crawl_queue.push(link) if local?(link)
        end
        @page_crawl_count += 1
      end

      return self
    end

    def local?(link)
      uri = Addressable::URI.parse(link)
      return true if uri.host == @domain
      return false
    end

    def add_page_to_graph(page)
      # if page doesnt exist, add it to neo4j
    end

    def create_relationship_in_graph(from, to)
      # create relationship between nodes
    end
  end
end
