require 'spec_helper'

module Creepycrawler
  describe Creepycrawler do
    describe "#crawl" do
      it "should have a crawl convenience method to crawl the site and return a Site object" do
        result = Creepycrawler.crawl(RSPEC_URL,:graph_to_neo4j => false)
        result.should be_an_instance_of Site
      end 
      it "should have a crawl convenience method that accepts options to crawl the site and return a Site object" do
        result = Creepycrawler.crawl(RSPEC_URL, :verbose => false, :graph_to_neo4j => false)
        result.should be_an_instance_of Site
      end 
    end
  end
end