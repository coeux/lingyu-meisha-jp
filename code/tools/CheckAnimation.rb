#encoding = utf-8
require 'find'


baseBone = [
  'head',
  'body',
  'right_arm',
  'right_hand',
  'right_up_leg',
  'right_down_leg',
  'right_foot',
  'left_arm',
  'left_hand',
  'left_up_leg',
  'left_down_leg',
  'left_foot',
  'right_weapon',
  'left_weapon',
  'right_up_wing',
  'right_down_wing',
  'left_up_wing',
  'left_down_wing'
]


boneInfo = Hash.new
#收集所有用到的armature
Find.find '../resource/animation' do |filename|
  next unless filename.include? "skeleton.xml"


  boneInfo[filename] = Array.new;
  File.foreach filename do |line|
    begin
      bone = /<b name="([^"]*)"/.match line
      boneInfo[filename] << bone[1] if bone
    rescue
      #字符集错误，无需处理
    end
  end

end

puts "请选择想要查看的部位:(0为全部显示)"
baseBone.size.times.each do |index|
  puts "#{index+1}. #{baseBone[index]}"
end


choice = gets.chomp.to_i


checkItems = []
if choice == 0 
  checkItems = baseBone
else
  checkItems << baseBone[choice-1]
end

boneInfo.each do |k, v|
  checkItems.each do |item|
    if not v.include? item
      puts "#{item} 骨骼在 #{k}中没有发现"
    end
  end
end

