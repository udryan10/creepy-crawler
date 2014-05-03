module Creepycrawler
  class Site 

    # the site domain
    attr_reader :domain
    # site scheme (http/https) 
    attr_reader:scheme
    # url the crawl began with
    attr_reader :url
    # hash of additional options to be passed in
    attr_reader :options
    # queue used to store discovered pages and crawl the site
    attr_reader :crawl_queue
    # number of pages crawled
    attr_reader :page_crawl_count

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
      @neo4j = Neography::Rest.new
      yield self if block_given?
    end
    
    def crawl
      loop do
        break if @crawl_queue.empty? or (!options[:max_page_crawl].nil? and @page_crawl_count >= options[:max_page_crawl])
        url = @crawl_queue.shift
        page = Page.new(url)
        current_page_node = add_page_to_graph(page.url,true)
        # push each link onto our queue. todo: filter already visisted sites
        page.links.each do |link| 
          # only push local links and links that do not already exist in the queue
          crawl_queue.push(link) if local?(link) and !crawl_queue.push.include?(link)

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

    def page_already_visisted?

    end

    def add_page_to_graph(page,visited)
      # if page doesnt exist, add it to neo4j
      # if it exists and visited is false and passed in variable is true, update visited
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
