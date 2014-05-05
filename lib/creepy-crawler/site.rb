module Creepycrawler
  # object to handle the discovery of our site through crawling
  class Site 

    # the site domain
    attr_reader :domain
    # url the crawl began with
    attr_reader :url
    # hash of additional options to be passed in
    attr_reader :options
    # queue used to store discovered pages and crawl the site
    attr_reader :crawl_queue
    # queue used to store visited pages 
    attr_reader :visited_queue
    # number of pages crawled
    attr_reader :page_crawl_count
    # holds the root node information 
    attr_reader :root_node
    # holds dead or broken links
    attr_reader :broken_links

    DEFAULT_OPTIONS = {
      # whether to print crawling information
      :verbose => true,
      # whether to obey robots.txt
      :obey_robots => true,
      # maximum number of pages to crawl, value of nil will attempt to crawl all pages
      :max_page_crawl => nil,
      # should pages be written to the database. Probably used for testing, but may be used if you only wanted to get at the broken_links data
      :graph_to_neo4j => true
    }

    # create setter methods for each default option
    DEFAULT_OPTIONS.keys.each do |option|
      define_method "#{option}=" do |value|
        @options[option.to_sym] = value
      end
    end

    def initialize(url, options = {})
      response = open(url, :allow_redirections => :all)
      url_parsed = Addressable::URI.parse(response.base_uri)
      @domain = url_parsed.host
      @url = url_parsed.to_s
      @page_crawl_count = 0
      @options = options
      # add the initial url to our crawl queue
      @crawl_queue = [@url] 
      @broken_links = [] 
      @visited_queue = []
      @graph = Creepycrawler::Graph.new
    end
    
    def crawl
      # merge default and passed in options into one hash 
      @options = DEFAULT_OPTIONS.merge(@options)

      # begin crawl loop
      loop do
        # break if we have crawled all sites, or reached :max_page_crawl
        break if @crawl_queue.empty? or (!options[:max_page_crawl].nil? and @page_crawl_count >= @options[:max_page_crawl])
        
        begin
          # pull next page from crawl_queue and setup page
          page = Page.new(@crawl_queue.shift)
          
          # add url to visited queue to keep track of where we have been
          @visited_queue.push(page.url.to_s)
          
          # respect robots.txt
          if @options[:obey_robots] and page.robots_disallowed? 
            puts "Not crawling #{page.url} per Robots.txt request" if options[:verbose]
            next
          end

          puts "Crawling and indexing: #{page.url}" if @options[:verbose]
          
          # retrieve page
          page.fetch
        rescue  => e
          puts "Exception thrown: #{e.message} - Skipping Page" if @options[:verbose]
          @broken_links.push(page.url)
          next
        end

        current_page_node = @graph.add_page(page.url) if @options[:graph_to_neo4j] 
        #todo: fix this. on first run current_page_node is a hash. subsequent is an array of hashes
        @root_node = current_page_node if @page_crawl_count == 0 and @options[:graph_to_neo4j]
        
        # Loop through all links on the current page
        page.links.each do |link|

          # add to crawl queue - only push local links, links that do not yet exist in the queue and links that haven't been visted
          @crawl_queue.push(link) if local? link and !@crawl_queue.include? link and !@visited_queue.include? link.to_s

          # add link page to graph
          current_link_node = @graph.add_page(link) if @options[:graph_to_neo4j]

          # create a links_to relationship from the current page node to link node
          @graph.create_relationship("links_to", current_page_node, current_link_node) if @options[:graph_to_neo4j]
        end
        @page_crawl_count += 1
      end # end of loop

      return self
    end

    # is link local to site?
    def local?(link)
      uri = Addressable::URI.parse(link)
      return true if uri.host == @domain
      return false
    end
  end
end
