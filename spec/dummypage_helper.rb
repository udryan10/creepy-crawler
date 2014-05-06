module Creepycrawler
  class Dummypage
    attr_accessor :body
    
    def initialize(link_array) 
      @body = "<html><body>"
      link_array.each do |link|
        @body += "<a href = '#{link}'> here </a>"
      end
      @body += "</body></html>"
    end
  end
end