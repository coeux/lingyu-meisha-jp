#encoding = utf-8
require 'find'


actions = [
  'idle',
  'run',
  'f_idle',
  'f_run',
  'attack',
  'skill',
  'hit',
  'death',
  'win',
  'await',
  'auto1',
  'skill2',
  'chant',
  'repel',
  'down'
]


actionInfo = Hash.new
#收集所有用到的armature
Find.find '../resource/animation' do |filename|
  next unless filename.include? "skeleton.xml"


  actionInfo[filename] = Array.new;
  File.foreach filename do |line|
    begin
      action = /<mov name="([^"]*)"/.match line
      actionInfo[filename] << action[1] if action
    rescue
      #字符集错误，无需处理
    end
  end

end

puts "请选择想要查看的部位:(0为全部显示)"
actions.size.times.each do |index|
  puts "#{index+1}. #{actions[index]}"
end


choice = gets.chomp.to_i


checkItems = []
if choice == 0 
  checkItems = actions
else
  checkItems << actions[choice-1]
end

actionInfo.each do |k, v|
  checkItems.each do |item|
    if not v.include? item
      puts "#{item} 动画在 #{k}中没有发现"
    end
  end
end

