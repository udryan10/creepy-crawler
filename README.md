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
####Limit number of pages in crawl
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
