  #Writer: writes the line from the state file:
  #And saves the critical date in werustate.txt.
  #For testing it can be called with a count in which case it will only read the prescribed number of entries.
  #
require 'state.rb' #needed to save the state
require 'nokogiri'
def display_lines( lines )
puts '['
lines.each do |line|
puts "[ #{line[0]} , #{line[1]}, #{line[2]} , #{line[3]} ], "
end
puts ']'
end


def write_schedule( lines ) 
  daynames = %w(Sun, Mon, Tue, Wed, Thu, Fri, Sat )
  @builder = Nokogiri::HTML::Builder.new { |doc|
    doc.html {
      doc.head {
      doc.title "WERU schedule" 
      doc.link(:rel =>"stylesheet",
               :type => "text/css", :href => "weru.css")
    }
    doc.body {
      doc.div.heading.thing! {
      doc.h1 "WERU Schedule"
    }
    doc.table {
      doc.tr { # top row, with days of week
      doc.td(:class => 'days') {
      doc.text 'Time'
      (0..6).each { |day|
        doc.text daynames[day]
      }
    }
    } #end of top row

    doc.tr { #write the row that is the body of the table
      #write first column with hours
      doc.td(:class=>'hours'){
      (0..23).each { |hour|
        doc.div.hours(:style=>'height: 60px;') {
          doc.text("Hr:" + hour.to_s) 
        }
      }
    } #finished with the hours column
    entry = 0
    (0..7).each { |day| 
      doc.td(:class => 'days') {
        puts "going into loop"
        loop do #we are going to loop until the day changes
        line =   lines[entry]
        break if line.nil?
        #p line
        name =   line[:name]
        height = line[:height]
        genre =  line[:genre]
        time =   line[:time]
        doc.div( :class => genre, :style => height){
           doc.text name
        }
        #go to next entry and see if we have switched times or finished
        entry += 1
        line = lines[entry]
        break if line.nil?
        time = line[:time]
        p line if time =~ /^12.*am/
        break if time =~ /^12.*am/
        end #finish the day..
      } #finish the td
    } #loop through the days     
    } #finish the big row containig it all
    }#finish the table
    } #finish the body
    } #finish the page
  } #finish the doc
    File.open("public/weru.html","w") do |file|
      file.write @builder.to_html
    end
  end #finished with procedure

def map_genres( genres )
  begin
    #read the file of show genres, and the genre category
    File.open("public/genremap.in", "r" ).readlines.each do |line|
      genre,category = line.split('=')
      genres[genre]=category
    end
  rescue
  end
  genres
end

def get_colormap()
  category_colors = Hash.new(:white)
  begin
    File.open("public/categorymap.in", "r").readlines.each do |line|
      category,color = line.split('=')
      category_colors[category] = color
    end
  rescue
  end
  category_colors
end

def write_css( genres, category_colors)
  File.open("public/weru.css", "w") do |file|
    file.write("body {background-color:lightgray}\n")
    file.write( "td {border: 1px solid darkgray}\n")
    genres.keys.each do |genre| 
      category = genres[genre]
      color = category_colors[category]
      file.write( ".#{genre} {background-color: #{color}}\n" ) 
    end
  end
end

  lines,genres = state_restore("werustate.yaml")
  #puts lines
  #puts genres
  write_schedule(lines)
  colormap = get_colormap()
  write_css(genres,colormap)

#vim tabstop=2:softtabstop=2:shiftwidth=2:expandtab
