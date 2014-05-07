#!/bin/sh 

MAX_PAGE_CRAWL=50
CRAWL_URL="http://www.yahoo.com"
echo "Crawler is set to crawl ${CRAWL_URL}"
echo "Crawler is set to crawl ${MAX_PAGE_CRAWL} pages"

cd /opt/creepy-crawler && rake neo4j:start
ruby /opt/creepy-crawler/lib/creepy-crawler.rb --site $CRAWL_URL --max-page-crawl $MAX_PAGE_CRAWL 
echo "==============================================="
echo "Crawl is complete!"
echo "To see graph data visit http://<docker_host>:7474/webadmin"
echo "Sleeping indefinitley to allow graph data to be viewed"
echo "To stop container execute: docker stop <container id>"
while true; do sleep 10000; done