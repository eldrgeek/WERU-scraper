require 'rubygems'
require 'nokogiri'
require 'open-uri'

def state_save(lines, genres)
  file.open("savestate.yaml","w") do |file|
    file.write(YAML::dump([lines,genres]))
  end
end

def state_restore() 
	$/="\n\n"
	array = []
	File.open("savestate.yaml", "r") do |object|
		array << YAML::load(object)
	end
$/="\n"
	array
end

if !$lines
  url = URI.parse("http://weru.org/schedule");
  doc = Nokogiri::HTML(open(url))
  puts doc.at_css("title").text
  #puts doc.css(".item")
  lines = []
  genres={}
  n = 0
  doc.css("#station-sch a").each do |item|
    name = item.at_css('.station-sch-title').text
    time = item.at_css('.station-sch-time').text
    height = item[:style]
    link = item[:href] 
    n = n + 1
    #break if n == 3
    doc = Nokogiri::HTML(open("http://weru.org/" + link))
    genre = doc.at_css(".odd").text.squeeze(" ").strip[10..-1].tr(" /'",'___')
    puts "#{name}:#{genre}"
    lines << [name,genre,time, height]
    genres[genre]=1
  end
  $lines = lines
  $genres = genres
  state_save(lines, genres)
end

lines,genres = state_restore

#genres = $genres
#lines = $lines

#=begin
puts '['
  lines.each do |line|
  puts "[ #{line[0]} , #{line[1]}, #{line[2]} , #{line[3]} ], "
  end
  puts ']'
#=end
#Now output the lines array and turn into HTML
daynames = %w(Sun, Mon, Tue, Wed, Thu, Fri, Sat )

  @builder = Nokogiri::HTML::Builder.new do |doc|
  doc.html {
    doc.head {
      doc.title "WERU schedule" 
      doc.link(:rel =>"stylesheet", :type => "text/css", :href => "weru.css")
      
    }
    doc.body {
      doc.div.heading.thing! {
        doc.h1 "WERU Schedule"
      }
      doc.table {
        doc.tr { # top row, with days of week
        (0..6).each { |day|
        doc.td(:class => 'days') {
          doc.text daynames[day]
        }
      }
      }
      (0..23).each { |row|
        doc.tr {
          doc.td( :class => 'hours') {
          doc.text "Hr:" + row.to_s
        }
        (0..6).each { |col|
          entry = row * 7 + col
          pair = lines[entry]
          if !pair.nil?
            name =pair[0]
            # puts name
            doc.td(:class => pair[1].tr("'",'_')) {
              doc.text name + pair[2]
            }
          end
        }
        } #tr
      }#rows
      } #table	
      }
  }

end
#puts  @builder.to_html
#puts genres.keys.join("\n")

File.open("public/genres.out", "w") do |file|
  genres.keys.each { |genre|
    file.write("#{genre}=\n")
  }
end
neutral_color = 'white'
mapping = Hash.new(neutral_color)
begin
File.open("public/genres.in", "r" ).readlines.each do |line|
  genre,color = line.split('=')
  if mapping[genre] == neutral_color
    mapping[genre]=color
  end  
end
rescue
end
File.open("public/weru.html","w") do |file|
  file.write @builder.to_html
end
File.open("public/weru.css", "w") do |file|
 file.write("body {background-color:lightgray}\n")
 file.write( "td {border: 1px solid darkgray}\n")
 genres.keys.each do |genre| 
   color = mapping[mapping[genre]]
   file.write( ".#{genre.tr("'",'_')} {background-color: #{color}}\n" ) 
 end
end

