# coding: utf-8
require 'csv'
require 'find'

tablesInfo = {}

preLoad = Hash.new

ROOT_DIR = "E:/NiceShot/niceshot-script/"

Types = ['number', 'array', 'array2', 'string']

#读取所有预加载资源
loaded = Array.new 
File.foreach '../lua/avatar/avatarLoadSkillEffect.lua' do |line|
  dirLine = /armatureManager:LoadFile\('(.*)'\);/.match line
  if dirLine then
    skeletonFile = "../#{dirLine[1]}skeleton.xml"
    #读取skeleton内容
    next unless File.exist? skeletonFile
    File.foreach skeletonFile do |line|
      begin
        armatureName = /<armature name="(.*)">/.match line
        if armatureName
          loaded << armatureName[1] 
        end
      rescue
      end
    end
  end
end

define_method :addSkillScript do |filename|
  begin
    File.foreach filename do |line|
      preLoadLine = /PreLoadAvatar\("(.*)"\)/.match line
      if preLoadLine then 
        avatarName = preLoadLine[1]
        preLoad[avatarName] ||= Array.new
        preLoad[avatarName] << filename
      end
    end
  rescue #include invalid charactors
    puts "文件中包含非法字符: #{filename}"
  end
end

class Object
  def is_number?
    self.to_f.to_s == self.to_s || self.to_i.to_s == self.to_s
  end

  def is_array?
    val = eval(self.to_s)
    return true if val.class == Array
    return false
  end
end

def readTable(tablesInfo, table_path)
  base_name = File.basename(table_path, ".txt")
  tablesInfo[base_name] = {}
  curTableInfo = tablesInfo[base_name]

  curTableInfo[:type] = []
  state_ok = true

  null_col_tables = {}

  #读取内容
  begin
    data = CSV.read(table_path, encoding: "UTF-8", col_sep: "\t")

    #表格结构分析
    data[0].each do |type|
      if Types.include?(type) then
        curTableInfo[:type] << type
      else
        state_ok = false
        #类型错误。如果是空格说明excel表中存在多余列，单独输出
        if type and type.length > 0 then
          puts "[type name error]   -> #{type} in #{base_name}, type name invalid"
        else
          null_col_tables[base_name] = true
        end
      end
    end

    null_col_tables.each do |name, value|
      puts "[null column exist]   -> table: 【#{name}】"
    end

    nul_row = false
    #空行判断
    data.each do |row|
      if row[0] == nil || row[0].length == 0 then
        nul_row = true
        break
      end
    end
    if nul_row then
      state_ok = false
      puts "[null row exist   ]   -> table: 【#{base_name}】"
    end
      

    #格式不正确的，则不进行下一步分析
    return if not state_ok 
    #表格内容分析
    curTableInfo[:data] = data
    data.map.with_index do |line, row|
      next if row <= 1 #跳过表头
      line.map.with_index do |item, col|
        item.strip! if item

        #array检查
        if curTableInfo[:type][col] == "array" and  not item.is_array? then
          puts "[array error      ]   -> table: 【#{base_name}】, pos:[#{ ('A'.ord + col).chr }:#{row+1}], data:#{item}"
        end

        #number检查
        if curTableInfo[:type][col] == "number" and item and not item.is_number? then
          puts "[number error     ]   -> table: 【#{base_name}】, pos:[#{ ('A'.ord + col).chr }:#{row+1}], data:#{item}"
        end
      end
    end
  rescue
    puts "[format error!!!! ]   -> table: 【#{base_name}】"
  end

end

Find.find(ROOT_DIR + "table") do |path|
  if File.file?(path)
    readTable(tablesInfo, path)
  end
end

#脚本是否存在
SCRIPT_DIR = ROOT_DIR + "skillScript/"
SCRIPT_CONFIG = {
  'skill' => ['effect'],
  'buff' => ['effect', 'effect_start', 'effect_end'],
  'role' => ['atk_script', 
             'skill_auto_script', 'skill_auto_script2', 'skill_auto_script3',
             'skill_script', 'next_skill', 'skill_script2', 'next_skill2', 
             'skill_script3', 'next_skill3'],
}
tablesInfo.each do |name, info|
  next unless info and info[:data]
  next unless SCRIPT_CONFIG.include? name

  script_cols = SCRIPT_CONFIG[name]
  data = info[:data]

  script_names = {}
  col_index = []
  script_cols.each do |col_name|
    index = data[1].index col_name
    col_index << index
  end

  data.map.with_index do |line, row|
    next if row <= 1 # 跳过表头
    values = line.values_at(*col_index)
    values.each do |value|
      script_names[value] = true if value and value.length > 0
    end
  end
  script_names.each do |k, v|
    filename = SCRIPT_DIR + k + ".lua"
    if not File.exist? filename then
      puts "[script not found ]   -> script: 【#{k}】"
    else
      addSkillScript(filename)
    end
  end
end


preLoad.each do |k, v|
  if not loaded.include? k
    puts "----------【#{k}】资源缺失----------"
    puts "error: #{k} 资源没有加载, 受此影响，以下脚本运行会发生崩溃:" 
    v.each do |line|
      puts "    #{line}"
    end
    puts "" 
  end
end
