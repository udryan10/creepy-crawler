require 'spec_helper'

module Creepycrawler 
  describe Graph do

    describe "#new" do

      it "should return a Graph object" do
        expect(Graph.new).to be_an_instance_of(Creepycrawler::Graph)
      end 
    end

    describe "#add_page" do

      it "should create a node if the node doesnt exist in the graph (returning nil)" do
        # mock out Neography::Rest object to allow us to return desired data
        neography = double(Neography::Rest, :get_node_index => nil, :create_node => [], :add_node_to_index => {})
        allow(Neography::Rest).to receive(:new) {neography}
        expect(neography).to receive(:get_node_index).with("page","url",RSPEC_URL)
        expect(neography).to receive(:create_node).with({"url" => RSPEC_URL})
        expect(neography).to receive(:add_node_to_index).with("page","url",RSPEC_URL,an_instance_of(Array))
        Graph.new.add_page RSPEC_URL
      end

      it "should create a node if it doesnt exist in the graph (raising exception Neography::NotFoundException)" do
        # mock out Neography::Rest object to allow us to return desired data
        neography = double(Neography::Rest, :create_node => [], :add_node_to_index => {})
        allow(Neography::Rest).to receive(:new) {neography}
        allow(neography).to receive(:get_node_index).and_raise(Neography::NotFoundException)
        expect(neography).to receive(:get_node_index).with("page","url",RSPEC_URL)
        expect(neography).to receive(:create_node).with({"url" => RSPEC_URL})
        expect(neography).to receive(:add_node_to_index).with("page","url",RSPEC_URL,an_instance_of(Array))
        Graph.new.add_page RSPEC_URL
      end

      it "should not create the node if the node exists" do
        # mock out Neography::Rest object to allow us to return desired data
        neography = double(Neography::Rest, :get_node_index => [], :create_node => [], :add_node_to_index => {})
        allow(Neography::Rest).to receive(:new) {neography}
        expect(neography).to receive(:get_node_index).with("page","url",RSPEC_URL)
        expect(neography).to receive(:create_node).never
        expect(neography).to receive(:add_node_to_index).never
        Graph.new.add_page RSPEC_URL
      end

      it "should return the node array when called" do
        # mock out Neography::Rest object to allow us to return desired data
        neography = double(Neography::Rest, :get_node_index => nil, :create_node => [], :add_node_to_index => {})
        allow(Neography::Rest).to receive(:new) {neography}
        expect(neography).to receive(:get_node_index).with("page","url",RSPEC_URL)
        expect(neography).to receive(:create_node).with({"url" => RSPEC_URL})
        expect(neography).to receive(:add_node_to_index).with("page","url",RSPEC_URL,an_instance_of(Array))
        expect(Graph.new.add_page RSPEC_URL).to be_an(Array)
      end
    end

    describe "#create_relationship" do
      it "should create relationship between nodes" do
        # mock out Neography::Rest object to allow us to return desired data
        neography = double(Neography::Rest, :create_relationship => {})
        allow(Neography::Rest).to receive(:new) {neography}
        expect(neography).to receive(:create_relationship).with("links_to","https://dummy.com",RSPEC_URL)
        Graph.new.create_relationship("links_to", "https://dummy.com", RSPEC_URL)
      end
    end
  end
end