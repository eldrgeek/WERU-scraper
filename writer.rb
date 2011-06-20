  #nWriter: writes the line from the state file:
  #And saves the critical date in werustate.txt.
  #For testing it can be called with a count in which case it will only read the prescribed number of entries.
  #
require 'state.rb' #needed to save the state
require 'nokogiri'
def hourname(hour)
  return "12am" if hour == 0
  return "#{hour}am" if hour < 11
  return "12pm" if hour == 11
  return "#{hour-11}pm"
end
def display_lines( lines )
puts '['
lines.each do |line|
puts "[ #{line[0]} , #{line[1]}, #{line[2]} , #{line[3]} ], "
end
puts ']'
end

def display_show(doc, lines, entry )

  line =   lines[entry]
  return if line.nil?
  name =   line[:name]
  height = line[:height]
  genre =  line[:genre]
  time =   line[:time]
  #remove one pixel for the border
  pixelheight = Integer(height.match(/(\d*)px/)[1]) - 1

  doc.div( :class => "#{genre} show" , 
          :style => "height: #{pixelheight}"){
    doc.text name
  }

end
def write_schedule( lines ) 
  daynames = %w(Sun Mon Tue Wed Thu Fri Sat )
  @builder = Nokogiri::HTML::Builder.new { |doc|
    doc.html {
      doc.head {
      doc.title.titleclass "WERU schedule" 
      doc.link(:rel =>"stylesheet",
               :type => "text/css", :href => "weru.css")
      doc.link(:rel =>"stylesheet",
               :type => "text/css", :href => "base.css")
      }
      doc.body {
        doc.div.heading.thing! {
        doc.h1 "WERU Schedule"
      }
      doc.table {
        doc.tr { # top row, with days of week
          doc.td(:class => 'day-heading') {
            doc.text 'Time'
          }
          (0..6).each { |day|
            doc.td.dayheading {
              doc.text daynames[day]
            }
          }
        } #end of top row

        doc.tr { #write the row that is the body of the table
          #write first column with hours
          doc.td(:class=>'hours'){
          #cycle through the hours from 5AM and then to midhnight
          ( (5..22).each.collect + [0, 1, 2]).each { |hour|
            doc.div.hoursdiv {
              doc.text(hourname(hour)) 
              }
            }
          } #finished with the hours column
          entry = 0
          (0..7).each { |day| 
            doc.td(:class => 'days') {
              #puts "going into loop"
              first_in_loop = entry; #this is the midnight show
              loop do #skip until the 5AM show
                line =   lines[entry]
                break if line.nil?
                #p line
                time =   line[:time]
                break if time =~ /^5.*am/
                entry += 1
              end
              loop do
                display_show(doc, lines, entry)
                #go to next entry and see if we have switched times or finished
                entry += 1
                line = lines[entry]
                break if line.nil?
                time = line[:time]
                #p line if time =~ /^12.*am/
                break if time =~ /^12.*am/
              end #finish the day..
              display_show(doc, lines, first_in_loop)
            } #finish the td
          } #loop through the days     
        } #finish the big row containig it all
        }#finish the table
        } #finish the body
      } #finish the HTML
    } #finish the doc
    File.open("public/weru.html","w") do |file|
      file.write @builder.to_html
    end
  end #finished with procedure

def map_genres( genres )
  begin
    #read the file of show genres, and the genre category
    File.open("public/genremap.in", "r" ).readlines.each do |line|
      line.chomp!
      genre,category = line.split('=')
      genres[genre]=category
    end
  rescue
  end
  genres.keys.each do |genre|
    #puts" #{genre} :  #{genres[genre]}\n"
    if genres[genre] == 1
      puts "Genre not mapped #{genre}\n"
      genres[genre]=genre 
    end
  end
  genres
end

def get_colormap()
  category_colors = Hash.new(:undefined)
  begin
    File.open("public/categorymap.in", "r").readlines.each do |line|
      line.chomp!
      #p line
      category,color = line.split('=')
      category_colors[category] = color
    end
  rescue
  end
  category_colors
end

def write_css( genres, category_colors)
  File.open("public/weru.css", "w") do |file|
    genres.keys.each do |genre| 
      category = genres[genre]
      color = category_colors[category]
      if color == :undefined
        color = "white"
        puts "no color for category #{category}"
      end
      file.write( ".#{genre} {background-color: #{color}}\n" ) 
    end
  end
end

  lines,genres = state_restore("werustate.yaml")
  #puts lines
  #puts genres
  write_schedule(lines); p "scheduled"
  colormap = get_colormap(); p "colors";# p colormap
  genres = map_genres(genres); p "genres";# p genres
  write_css(genres,colormap); p "css"

 #vim tabstop=2:softtabstop=2:shiftwidth=2:expandtab
