require 'spec_helper'

module Creepycrawler 
  describe Site do
    before :each do
      @site = Site.new(RSPEC_URL)
    end
  
    describe "#new" do
      it "should accept a url and return a site object" do
        @site.should be_an_instance_of Site
      end 
    end

    describe "#local?" do

      it "should corectly recognize a url local" do
        @site.local?(RSPEC_URL).should be_true 
      end

      it "should correctly recognize a non-local url" do
        @site.local?("http://non-local.com/").should be_false 
      end
    end
  end
end