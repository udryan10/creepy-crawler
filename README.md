creepy-crawler
==============

Webcrawler that takes a url as input and will output a sitemap using neo4j graph database - Nothing creepy about it.

[![Build Status](https://travis-ci.org/udryan10/creepy-crawler.svg?branch=master)](https://travis-ci.org/udryan10/creepy-crawler)


##Installation
####Clone
    git clone https://github.com/udryan10/creepy-crawler.git
####Install Required Gems
    bundle install
####Install graph database
    rake neo4j:install
####Start graph database
    rake neo4j:start

##Usage
####Require
    require './creepy-crawler'
####Start a crawl
    Creepycrawler.crawl("http://example.com")
####Limit number of pages to crawl
    Creepycrawler.crawl("http://example.com", :max_page_crawl => 500)
####Extract some (potentially) useful statistics
    crawler = Creepycrawler.crawl("http://example.com", :max_page_crawl => 500)
    # list of broken links
    puts crawler.broken_links
    # list of sites that were visited
    puts crawler.visited_queue
    # count of crawled pages
    puts crawler.page_crawl_count
####Options
    DEFAULT_OPTIONS = {
      # whether to print crawling information
      :verbose => true,
      # whether to obey robots.txt
      :obey_robots => true,
      # maximum number of pages to crawl, value of nil will attempt to crawl all pages
      :max_page_crawl => nil,
      # should pages be written to the database. Likely only used for testing, but may be used if you only wanted to get at the broken_links data
      :graph_to_neo4j => true
    }

####Example script located in examples/

##Output
creepy-crawler uses [neo4j](http://www.neo4j.org/) graph database to store and display the site map.

### Web interface
neo4j has a web interface for viewing and interacting with the graph data. When running on local host, visit: [http://localhost:7474/webadmin/](http://localhost:7474/webadmin/)

1. Click the Data Browser tab
2. Enter Query to search for nodes ex (will search all nodes):

    <code>
    START root=node(*) 
    RETURN root
    </code>
    
3. Click into a node
4. Click switch view mode to view a graphical map

neo4j also has a full-on [REST API](http://docs.neo4j.org/chunked/stable/rest-api.html) for programatic access to the data

###Example Output Map
![Output Map](https://raw.githubusercontent.com/udryan10/creepy-crawler/master/examples/output_map.png)
