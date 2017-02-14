require 'find'

#列举lay文件中的事件绑定
filename = "../resource/ui/godsSenki.lay"
subscribers = Hash.new

#<Event Name="Button::ClickEvent" Subscriber="GemSelectPanel
File.foreach filename do |line|
  begin
    subscriber = /Subscriber="([^"]*)"/.match line
    if subscriber then
      str = subscriber[1].gsub(":", ".");
	  subscribers[str] = true      
    end
  rescue
    #字符集错误，无需处理
  end
end


#列举lua代码中的事件绑定
Find.find '../lua' do |filename|
  next unless filename.include? "\.lua"
  File.foreach filename do |line|
    begin
      subscriber = /SubscribeScriptedEvent\('.*'.*['"](.*)['"]\)/.match line
      if subscriber then
	str = subscriber[1].gsub(":", ".");
	subscribers[str] = true      
      end
    rescue
      #字符集错误，无需处理
    end
  end
end


subscribers.each do |k, v|
	puts "  #{k} = Debug.hook(#{k}); print('#{k} hooked')" 
end
