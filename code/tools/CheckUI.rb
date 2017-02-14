require "rexml/document"  
include REXML  

puts "-- BEGIN --"  

image_map = {}
brush_map = {}

doc = Document.new(File.open("../resource/ui/godsSenki.res"))  

images_node = doc.elements['Resource/Images']
images_node.elements.each("Image"){  |elem|  
  file = elem.attributes['File']
  name = elem.attributes['Name']
  group = elem.attributes['Group']

  if File.exist? "../resource/ui/" + file
    image_map[name] = { :file => file, :name => name, :group => group }
  else
    images_node.delete_element elem
  end
}  

doc.elements['Resource'].elements.each('Group') do |group|
  group_name = group.attributes['Name']

  #storyboard乱入。。
  next if group_name == 'storyboard'
  brush_map[group_name] ||= {}

  group.elements.each do |brush|

    name = brush.attributes['Name']
    image = brush.attributes['Image']

    if not image_map.include? image then
      #引用了不存在的图片
      group.delete_element brush
      puts brush.to_s
    else
      brush_map[group_name][name] = { :name => name, :image => image }
    end
  end
end

=begin
layer_files = ['fight', 'godsSenki', 'loading', 'login']

layer_files.each do |layer|
  layer_name = layer + ".lay"
=end


formatter = REXML::Formatters::Pretty.new(4)
formatter.compact = true # This is the magic line that does what you need!
formatter.write(doc, File.open("som.xml", "w"))

