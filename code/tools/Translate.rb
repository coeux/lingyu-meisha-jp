#encoding: utf-8
require 'fileutils'
require 'find'
require 'digest/md5' 


CHINESE_REGEXP_UI = /Text="([^"]*[\u{4e00}-\u{9fff}]+[^"]*)"/
CHINESE_FORMAT_UI = "Text=\"%s\""
CHINESE_REGEXP_LANG = /["']([^"']*[\u{4e00}-\u{9fff}]+[^"']*)["']/
CHINESE_FORMAT_LANG = "'%s'"

LANG_FILE_PATH = "../language/language_cn.lua"

TRANSDB_PATH = "./transdb"

def generate_simplechinese_db
  words = {}

  define_method :extract_from_line do |line, regexp|
    ret = line.force_encoding('utf-8').match regexp
    if ret
      word = ret[1] 
      md5 = Digest::MD5.hexdigest word
      words[md5] = word
      puts "OK#{word}"
    end
  end

  Find.find '../resource/ui/' do |path|
    next unless path.include? ".lay"

    File.foreach path do |line|
      extract_from_line(line, CHINESE_REGEXP_UI)
    end
  end

  #增加对language.lua的处理
  File.foreach LANG_FILE_PATH do |line|
    extract_from_line(line, CHINESE_REGEXP_LANG)
  end

  File.open "#{TRANSDB_PATH}/simple_chinese.db", "w" do |f|
    words.each do |k, v|
      f.puts "#{k}\t\"#{v}\""
    end
  end
end

def translate_to lang
  #读取目标词典
  db_to = {}
  File.foreach "#{TRANSDB_PATH}/#{lang}.db" do |line|
    key = line[0..31]
    value = line[34..-3]
    db_to[key] = value
  end

  # ui
  Find.find '../resource/ui/' do |path|
    next unless path.include? ".lay"

    lines = []
    File.foreach path do |line|
      ret = line.force_encoding('utf-8').match CHINESE_REGEXP_UI
      if ret then
        word = ret[1] 
        md5 = Digest::MD5.hexdigest word
        if db_to.has_key? md5 then
          line = line.force_encoding('utf-8').gsub(CHINESE_REGEXP_UI, CHINESE_FORMAT_UI % db_to[md5])
        end
      end
      lines << line
    end

    File.open path,"w" do |f|
      lines.each do |line|
        f.write(line)
      end
    end
  end

  # lang
  lines = []
  File.foreach LANG_FILE_PATH do |line|
    ret = line.force_encoding('utf-8').match CHINESE_REGEXP_LANG
    if ret
      word = ret[1]
      md5 = Digest::MD5.hexdigest word
      if db_to.has_key? md5
        puts CHINESE_FORMAT_LANG % db_to[md5]
        line = line.force_encoding('utf-8').gsub(CHINESE_REGEXP_LANG,
                                                 (CHINESE_FORMAT_LANG % db_to[md5]).force_encoding('utf-8'))
      end
    end
    lines << line
  end

  File.open LANG_FILE_PATH, "w" do |f|
    lines.each do |line|
      f.write(line)
    end
  end
end

def print_info
  puts "选择操作："
  puts "1. 重新生成中文字典(慎重!!)"
  puts "2. 翻译成其他语言"
  puts "3. 退出"
end

def get_option
  while true do

    print_info
    option = gets.chomp

    if option == "1" or option == "2" or option == "3" then
      return option
    end
  end
end

FileUtils.mkdir_p(TRANSDB_PATH) if not Dir.exist?(TRANSDB_PATH)

option = get_option
case option
when "1"
  puts "确定要覆盖原始字典么?(y/n)"
  sure = gets.chomp
  exit if sure != "y"
  generate_simplechinese_db
  puts "中文版本字典已经重新生成，请发送simple_chinese.db文件给翻译人员"
when "2"
  puts "请选择要翻译的目标:"
  target = []
  Find.find TRANSDB_PATH do |path|
    next unless path.include? ".db"
    filename = path.match(/([^\/\\]*)\.db/)[1]
    target << filename
  end
  target.each_with_index do |lang, index|
    puts "#{index+1}. #{lang}"
  end
  opt = gets.chomp
  target_lang = target[opt.to_i - 1]
  puts "你选择的语言是#{target_lang}, 翻译之后只能通过版本库还原，确定么(y/n)"
  sure = gets.chomp
  exit if sure != "y"
  translate_to target_lang
  puts "翻译已经完成，请打开游戏确认"
when "3"
  exit
end




