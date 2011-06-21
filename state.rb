require 'yaml'
def state_save(file, *state)
	#usage: state_save (var.....)
	#saves the state in the given file
  File.open(file, "w") do |file|
    file.write(YAML::dump(state))
  end
end

def state_restore(file) 
	#usage: a,... = state_restore(file)
	#restore the variables from the file
  $/="\n\n"
  array = []
  File.open(file, "r") do |object|
    array =  YAML::load(object)
  end
  $/="\n"
  array
end

