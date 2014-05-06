require_relative '../lib/creepy-crawler'

crawler = Creepycrawler.crawl("http://yahoo.com", :max_page_crawl => 100)
puts "=" * 40
puts "broken link list:"
puts crawler.broken_links
puts "=" * 40
puts "number of visited pages:"
puts crawler.page_crawl_count
puts "=" * 40
