require 'find'

Find.find '../lua' do |path|
  next unless path.include? ".lua"

  filename = path.match(/([^\/\\]*\.lua)/)[1]
  content = []
  File.foreach path do |line|
    content << line
  end

  content.insert(0, "--#{filename}\n")

  File.open(path,"w") do |l|
    content.each do |line|
       l.write(line)    
    end
  end   
end

