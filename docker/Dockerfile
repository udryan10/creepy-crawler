FROM ubuntu:latest

MAINTAINER Ryan Grothouse <rgrothouse@gmail.com>

ENV DEBIAN_FRONTEND noninteractive
ENV NOKOGIRI_USE_SYSTEM_LIBRARIES 1

RUN apt-get -q update
RUN apt-get -y upgrade

# Nokogiri dependencies
RUN apt-get install -qy --force-yes git ruby ruby-dev build-essential
RUN apt-get install -qy libxslt1-dev libxml2-dev libssl-dev libyaml-dev
RUN apt-get install -qy --no-install-recommends openjdk-7-jdk openjdk-7-jre

# Neo4j dependencies
RUN apt-get install -qy curl lsof

RUN gem install bundler

RUN git clone https://github.com/udryan10/creepy-crawler /opt/creepy-crawler
WORKDIR /opt/creepy-crawler

RUN bundle install
RUN rake neo4j:install

ADD ./startup.sh /startup.sh
ADD ./neo4j-server.properties /opt/creepy-crawler/neo4j/conf/neo4j-server.properties
RUN chmod u+x /startup.sh

EXPOSE 7474

ENTRYPOINT ["/startup.sh"]