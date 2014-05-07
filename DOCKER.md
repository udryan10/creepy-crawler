creepy-crawler - containerized
==============

I have containerized creepy-crawler using [Docker](http://docker.io) for testing, portability and because Docker is awesome


##Installation
####Clone
    git clone https://github.com/udryan10/creepy-crawler.git
####Build docker image
    cd docker/ && docker build -t "creepy-crawler:1.0" .
##Run
    # map neo4j's web interface port 7474 in the container to the host port 7474 for access
    docker run -i -p 7474:7474 creepy-crawler:1.0

##Output
creepy-crawler uses neo4j graph database to store and display the site map. When the crawl is complete, the docker container is set to loop indefinitley to provide access to the graph data. If we don't do this, the container will shut down and the data will not be able to be accessed.

### Web interface
View crawl data, stored in neo4j running inside of the container at: <code>http://\<docker_host\>:7474/webadmin</code>

Instructions on how to get to the graph data exist in the [README](https://github.com/udryan10/creepy-crawler#web-interface)

###boot2docker
If you are running docker on a mac using boot2docker, you will have to instruct virtual box to forward the correct port to the docker host:
    
    VBoxManage modifyvm "boot2docker-vm" --natpf1 "neo4j,tcp,,7474,,7474"

##Stopping
    docker stop <container id>

**Plans to add additional documentation for those less familiar with Docker
