require 'spec_helper'

module Creepycrawler 
  describe Page do
    before :each do
      @page = Page.new(RSPEC_URL)
    end
  
    describe "#new" do
      it "should accept a url and return a page object" do
        expect(@page).to be_an_instance_of Creepycrawler::Page
      end 

      it "should raise error on bad url" do
        expect { Page.new("http://?bad_uri") }.to raise_error
      end
    end

    describe "#fetch" do
      it "should return a nokogiri object" do
        expect(@page.fetch).to be_a(Nokogiri::HTML::Document)
      end
    end

    describe "#links" do
      it "should return an array" do
        dummy_page_link_array = [
          "/1",
          "/2",
          "http://remote.com/3"
        ]
        @page.body = Dummypage.new(dummy_page_link_array).body
        expect(@page.links).to be_an(Array)
      end

      it "should return three links" do
        dummy_page_link_array = [
          "/1",
          "/2",
          "http://remote.com/3"
        ]
        @page.body = Dummypage.new(dummy_page_link_array).body
        expect(@page.links.length).to equal(3)
      end

      it "should not return links to itself or empty links" do
        dummy_page_link_array = [
          "/1",
          "/2",
          "http://remote.com/3",
          "#",
          "" 
        ]
        @page.body = Dummypage.new(dummy_page_link_array).body
        expect(@page.links.length).to equal(3)
      end

      it "should convert relative to absolute links" do
        dummy_page_link_array = [
          "/1",
          "/2",
          "http://remote.com/3"
        ]
        @page.body = Dummypage.new(dummy_page_link_array).body
        expect(@page.links).to include("#{RSPEC_URL}1", "#{RSPEC_URL}2", "http://remote.com/3")
      end

      it "should not pickup mailto links" do
        dummy_page_link_array = [
          "mailto:foo@example.com"
        ]
        @page.body = Dummypage.new(dummy_page_link_array).body
        expect(@page.links).to be_empty
      end

      it "should not pickup ftp links" do
        dummy_page_link_array = [
          "ftp://example.com"
        ]
        @page.body = Dummypage.new(dummy_page_link_array).body
        expect(@page.links).to be_empty
      end

      it "should not pickup links that execute javascript" do
        dummy_page_link_array = [
          "javascript:void(0)"
        ]
        @page.body = Dummypage.new(dummy_page_link_array).body
        expect(@page.links).to be_empty
      end
    end
  end
end