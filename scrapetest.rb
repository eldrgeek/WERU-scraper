require 'rubygems'
require 'scrapi'

scraper = Scraper.define do
  array :items
  process "tr.odd", :items => Scraper.define {
    process "td", :title => :text, :link => "@href"
    process "div.priceAvail>div>div.PriceCompare>div.BodyS", :price => :text
    result :price, :title, :link
  }
  result :items
end
html>body>div>div:nth-of-type(2)>div>div>div:nth-of-type(4)>div>table:nth-of-type(2) tr>td:nth-of-type(2)>div>a>span:nth-of-type(2)

tr.odd
:nth-of-type(1)
td:nth-of-type(2)
td.station-sch-now-day
td.station-sch-now-day+td

div>a:nth-of-type(1)
div>a>span:nth-of-type(2)

td:nth-of-type(3)
uri = URI.parse("http://www.walmart.com/search/search-ng.do?search_query=Lost+third+season&ic=48_0&Find=Find&search_constraint=0");
scraper.scrape(uri).each do |product|
  puts product.title
  puts product.price
  puts product.link
  puts
end

Lost: The Complete Third Season (Unexplored Experience) (Widescreen)
nil
/ip/5978156

Lost: The Complete Third Season - The Unexplored Experience (Blu-ray) (Widescree
n)
nil
/ip/6537172

Lost: The Complete Third Season - The Unexplored Experience (Spanish Language Pa
ckaging) (Widescreen)
nil
/ip/6537182

Lost In Space: Season 3, Vol. 1 (Full Frame, Widescreen)
nil
/ip/3551329

Lost World: Season 3, The (Full Frame)
nil
/ip/10750968

Lost In Space: Season 3, Vol. 2
nil
/ip/3873349

Land of the Lost: Season 1 [3 Discs] (Full Frame)
nil
/ip/12187922

Land Of The Lost: Season 3 (Full Frame)
nil
/ip/12187920

scraper >











