module Creepycrawler
  # Class that takes care of writing to our graph database (neo4j)
  class Graph 

    def initialize
      @neo4j = Neography::Rest.new
    end

    # add page to graph database
    def add_page(url)
      # if page doesnt exist, add it to neo4j
      begin
        node = @neo4j.get_node_index("page", "url", url)
      rescue Neography::NotFoundException => e
        node = nil
      end

      # node doesnt exist, create it
      if node.nil?
        node = @neo4j.create_node("url" => url)
        @neo4j.add_node_to_index("page", "url", url, node) unless node.nil?
      end

      return node
    end

    def create_relationship(type,from,to)
      @neo4j.create_relationship(type, from, to)
    end
  end 
end