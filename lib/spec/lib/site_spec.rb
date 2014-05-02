require 'spec_helper'

module Creepycrawler 
  describe Site do
    before :each do
      @site = Site.new(RSPEC_URL)
    end
  
    describe "#new" do
      it "should accept a url and return a site object" do
        expect(@site).to be_an_instance_of Creepycrawler::Site
      end 
    end

    describe "#local?" do
      it "should corectly recognize a url local" do
        expect(@site.local?("#{RSPEC_URL}/foo")).to be true
      end

      it "should correctly recognize a non-local url" do
        expect(@site.local?("http://non-local.com/")).to be false 
      end
    end
  end
end