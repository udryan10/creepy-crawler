require 'rubygems'
require 'bundler/setup'
require 'neography'
require 'nokogiri'
require 'open-uri'
require 'addressable/uri'
require 'open_uri_redirections'
require 'webrobots'

# dynamically require all creepy-crawler/*.rb
Dir[File.dirname(__FILE__) + '/creepy-crawler/*.rb'].each {|file| require file }

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
