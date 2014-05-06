require 'spec_helper'

module Creepycrawler 
  describe Site do
    before :each do
      @site = Site.new(RSPEC_URL, :verbose => false, :graph_to_neo4j => false)
    end

    it "should accept options" do
      @site = Site.new(RSPEC_URL, :foo => true)
      expect(@site.options[:foo]).to be true
    end

    it "should allow the changing of default options" do
      @site = Site.new(RSPEC_URL, :verbose => false)
      expect(@site.options[:verbose]).to be false
    end
  
    describe "#new" do

      it "should accept a url and return a site object" do
        expect(@site).to be_an_instance_of Creepycrawler::Site
      end 
    end

    describe "#local?" do

      it "should corectly recognize a local url" do
        expect(@site.local?("#{RSPEC_URL}/foo")).to be true
      end

      it "should correctly recognize a non-local url" do
        expect(@site.local?("http://non-local.com/")).to be false 
      end
    end

    describe "#crawl" do

      it "should increment page_crawl_count with every indexed page" do
        page = double(Creepycrawler::Page, :url => RSPEC_URL, :robots_disallowed? => false, :fetch => "", :links => [])
        allow(Creepycrawler::Page).to receive(:new) {page}
        expect(@site.crawl.page_crawl_count).to eq(1)

      end

      it "should obey robots.txt when not explicity ignored" do
        page = double(Creepycrawler::Page, :url => RSPEC_URL, :robots_disallowed? => true, :fetch => "", :links => [])
        allow(Creepycrawler::Page).to receive(:new) {page}
        expect(@site.crawl.page_crawl_count).to eq(0)
      end

      it "should add each visited site to visited_queue" do
        page = double(Creepycrawler::Page, :url => RSPEC_URL, :robots_disallowed? => true, :fetch => "", :links => [])
        allow(Creepycrawler::Page).to receive(:new) {page}
        expect(@site.crawl.visited_queue).to match_array([RSPEC_URL])
      end

      it "should terminate when max_page_crawl is reached" do
        dummy_page_link_array = [
          "/1",
          "/2",
          "/3",
        ]
        dummy_page = Page.new(RSPEC_URL)
        dummy_page.body = Dummypage.new(dummy_page_link_array).body
        @site = Site.new(RSPEC_URL, :verbose => false, :max_page_crawl => 2, :graph_to_neo4j => false)
        page = double(Creepycrawler::Page, :url => RSPEC_URL, :robots_disallowed? => false, :fetch => "", :links => dummy_page.links)
        allow(Creepycrawler::Page).to receive(:new) {page}
        expect(@site.crawl.page_crawl_count).to eq(2)
      end

      it "should not visit the same page twice" do
        dummy_page_link_array = [
          "/1",
          "/2",
          "/2",
        ]
        dummy_page = Page.new(RSPEC_URL)
        dummy_page.body = Dummypage.new(dummy_page_link_array).body

        page = double(Creepycrawler::Page, :robots_disallowed? => false, :fetch => "", :links => dummy_page.links)
        #allow(Creepycrawler::Page).to receive(:links) {["foo", "baz"]}
        allow(Creepycrawler::Page).to receive(:new) do |arg|
          # dynamically stub url to return url passed in initialization
          allow(page).to receive(:url) {arg}
          # return mock
          page
        end
        expect(@site.crawl.page_crawl_count).to eq(3)
        expect(@site.crawl.visited_queue).to match_array([RSPEC_URL, "#{RSPEC_URL}1", "#{RSPEC_URL}2"])
      end

      it "should not visit remote sites" do
        dummy_page_link_array = [
          "/1",
          "http://remote.com/"
        ]
        dummy_page = Page.new(RSPEC_URL)
        dummy_page.body = Dummypage.new(dummy_page_link_array).body
        page = double(Creepycrawler::Page, :robots_disallowed? => false, :fetch => "", :links => dummy_page.links)
        allow(Creepycrawler::Page).to receive(:new) do |arg|
          # dynamically stub url to return url passed in initialization
          allow(page).to receive(:url) {arg}
          # return mock
          page
        end
        expect(@site.crawl.page_crawl_count).to eq(2)
        expect(@site.crawl.visited_queue).to match_array([RSPEC_URL, "#{RSPEC_URL}1"])
      end

      it "should add url to broken_links when exception is thrown" do
        page = double(Creepycrawler::Page, :url => RSPEC_URL, :robots_disallowed? => false, :fetch => "")
        allow(Creepycrawler::Page).to receive(:new) {page}
        allow(page).to receive(:fetch).and_raise('404 site not found')
        expect(@site.crawl.broken_links).to match_array([RSPEC_URL])
      end
    end
  end
end