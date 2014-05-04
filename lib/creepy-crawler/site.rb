module Creepycrawler
  class Site 

    # the site domain
    attr_reader :domain
    # site scheme (http/https) 
    attr_reader :scheme
    # url the crawl began with
    attr_reader :url
    # hash of additional options to be passed in
    attr_reader :options
    # queue used to store discovered pages and crawl the site
    attr_reader :crawl_queue
    # number of pages crawled
    attr_reader :page_crawl_count
    # holds the neo4j url to the root node
    attr_reader :root_node
    # holds dead or broken links
    attr_reader :broken_links

    DEFAULT_OPTIONS = {
      # whether to print crawling information
      :verbose => true,
      # whether to obey robots.txt
      :obey_robots => true,
      # maximum number of pages to crawl, value of nil will attempt to crawl all pages
      :max_page_crawl => nil
      # should pages be written to database. Likely only used during testing 
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
      @scheme = url_parsed.scheme
      @url = url_parsed.to_s
      @page_crawl_count = 0
      @options = options
      # add the initial url to our crawl queue
      @crawl_queue = [@url] 
      @broken_links =[]
      @neo4j = Neography::Rest.new
      yield self if block_given?
    end
    
    def crawl
      # merge default and passed in options into one hash 
      @options = DEFAULT_OPTIONS.merge(@options)

      # begin crawl loop
      loop do
        # break if we have crawled all sites, or reached :max_page_crawl
        break if @crawl_queue.empty? or (!options[:max_page_crawl].nil? and @page_crawl_count >= @options[:max_page_crawl])
        
        # get next url from crawl queue
        url = @crawl_queue.shift
        
        # setup page object to get page information
        page = Page.new(url)
        
        # respect robots.txt
        if @options[:obey_robots] and page.robots_disallowed? 
          puts "Not crawling #{page.url} per Robots.txt request" if options[:verbose]
          next
        end

        puts "Crawling and indexing: #{page.url}" if @options[:verbose]
        
        begin
          # retrieve page
          page.fetch
        rescue OpenURI::HTTPError => e
          puts "Exception thrown: #{e.message} - Skipping Page" if @options[:verbose]
          @broken_links << page.url
          next
        end

        current_page_node = add_page_to_graph(page.url,true)
        @root_node = current_page_node[0] if @page_crawl_count == 0
        
        # push each link onto our queue.
        page.links.each do |link| 
          puts link
          # only push local links, links that do not yet exist in the queue and links that haven't been visted
          crawl_queue.push(link) if local?(link) and !crawl_queue.push.include?(link) and !page_already_visited?(link)

          current_link_node = add_page_to_graph(link,false)
          # create relationship from current
          create_relationship_in_graph(current_page_node,current_link_node)
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

    def page_already_visited?(page)
      begin
        node = @neo4j.get_node_index("page", "url", page)
      rescue Neography::NotFoundException => error 
        return false 
      end

      return false if node.nil?
      return node[0]['data']['visited']
    end

    def add_page_to_graph(page,visited)
      # if page doesnt exist, add it to neo4j
      begin
        node = @neo4j.get_node_index("page", "url", page)
      rescue Neography::NotFoundException => error 
        node = nil
      end
      # node doesnt exist, create it 
      if node.nil?
        node = @neo4j.create_node("url" => page, "visited" => visited)
        @neo4j.add_node_to_index("page", "url", page, node) unless node.nil?
      else # node already existed, update visited property
        # only want to flip nodes from not visted to visited. todo: find a better way to handle this 
        if node[0]['data']['visited'] == false and visited == true 
          @neo4j.set_node_properties(node, {"visited" => visited})
        end
      end

      return node
    end

    def create_relationship_in_graph(from, to)
      # create relationship between nodes
      @neo4j.create_relationship("links_to",from,to)
    end
  end
end
