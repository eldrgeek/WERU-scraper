#ReadSchedule reads a schedule from the WERU websits, parses it
#And saves the critical date in werustate.txt
#For testing it can be called with a count in which case it will only read the prescribed number of entries.
#
require 'rubygems'
require 'state.rb' #needed to save the state
require 'nokogiri'
require 'open-uri'

def read_schedule(count=9999)
  uri = "http://weru.org/schedule"

  doc = Nokogiri::HTML(open(URI.parse(uri)))
  
  puts doc.at_css("title").text
  #puts doc.css(".item")
  data = [] #Extracted data goes in data
  genres={} #hash of genres goes here
  n = 0     #count number of entires read
  doc.css("#station-sch a").each do |item|
	  #iterate through tags, found by SelectorGadget, and extract
    name = item.at_css('.station-sch-title').text
    time = item.at_css('.station-sch-time').text
    height = item[:style]
    link = item[:href]  #get link to the show and open its page
    doc = Nokogiri::HTML(open("http://weru.org/" + link))
    genre = doc.at_css(".odd").text.squeeze(" ").strip[10..-1].tr(" /'",'___')
    #genre string pulled from tag .odd, stripped and translated
    #to get rid of characters bad as css selectors 
    puts "#{name}:#{genre}"
    item = {:name => name, :time => time, :height => height, :link => link,
	    :genre => genre}
     data << item
    genres[genre]=1
    n = n + 1
    break if n > count 
  end
	#Write the genres...
  File.open("public/genres.out", "w") do |file|
		genres.keys.each { |genre|
			file.write("#{genre}=\n")
		}
	end
  $data = data #save in globals for IRB
  $genres = genres
  state_save("werustate.yaml", data, genres)
  [data,genres]
end
	puts "scheduling"
  read_schedule()
