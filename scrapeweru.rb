require 'rubygems'
require 'nokogiri'
require 'open-uri'

url = URI.parse("http://www.walmart.com/search/search-ng.do?search_query=Lost+third+season&ic=48_0&Find=Find&search_constraint=0");
doc = Nokogiri::HTML(open(url))
puts doc.at_css("title").text
#puts doc.css(".item")
doc.css(".item").each do |item|
  title = item.at_css(".ListItemLink").text
  price = item.at_css(".bigPriceText2").text +  item.at_css(".smallPriceText2")
  puts "#{title} - #{price}"
  puts item.at_css(".ListItemLink")[:href]
end












