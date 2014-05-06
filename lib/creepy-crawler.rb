require 'rubygems'
require 'bundler/setup'
require 'neography'
require 'nokogiri'
require 'open-uri'
require 'addressable/uri'
require 'open_uri_redirections'
require 'webrobots'
require 'trollop'
require_relative 'creepy-crawler/site'
require_relative 'creepy-crawler/page'
require_relative 'creepy-crawler/graph'

module Creepycrawler
  # todo: on my local machine im hitting some openssl bug to where legitimate https sites are not validating the certificate.
  # For now, keeping this to override the verification but need to investigate further and remove this hack.
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
  # configure Neography - for now uses all defaults and expects neo4j to be running on localhost 
  Neography.configure do |config|
    config.protocol           = "http://"
    config.server             = "localhost"
    config.port               = 7474
    config.directory          = ""  # prefix this path with '/'
    config.cypher_path        = "/cypher"
    config.gremlin_path       = "/ext/GremlinPlugin/graphdb/execute_script"
    config.log_file           = "neography.log"
    config.log_enabled        = false
    config.slow_log_threshold = 0    # time in ms for query logging
    config.max_threads        = 20
    config.authentication     = nil  # 'basic' or 'digest'
    config.username           = nil
    config.password           = nil
    config.parser             = MultiJsonParser
  end
 
  # class method to start a crawl
  def Creepycrawler.crawl(url, options = {})
    return Site.new(url, options).crawl
  end
end


# allow the initiating of a crawl from command line 
if __FILE__==$0
  # setup options
  opts = Trollop::options do
    opt :site, "Url of site to crawl", :type => :string  # flag --site
    opt :obey_robots, "Obey robots.txt disallow list"    # string --name <s>, default nil
    opt :verbose, "Whether to print crawling information", :default => true
    opt :max_page_crawl, "Maximum number of pages to crawl. Defaults to unlimited", :default => 0 
    opt :graph_to_neo4j, "Whether pages should be written to graph database", :default => true
  end
  
  Trollop::die :site, "Must specify a site to crawl" unless opts[:site]
  opts[:max_page_crawl] = nil if opts[:max_page_crawl] == 0
  
  options_hash = {:obey_robots => opts[:obey_robots], :verbose => opts[:verbose], :max_page_crawl => opts[:max_page_crawl], :graph_to_neo4j => opts[:graph_to_neo4j]}
 
  # start crawl
  Creepycrawler.crawl(opts[:site], options_hash)
end
