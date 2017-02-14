--limitedWord.lua

--========================================================================
--屏蔽字类

LimitedWord =
	{
		words = {};	      			--屏蔽字库
	};

--是否屏蔽字
function LimitedWord:isLimited(userword)
	if userword == nil or '' == userword then
		return false;
	end
	local isLimit, word = self:isLimitedWithWord(userword);	
	return isLimit;
end

--替换屏蔽字为*
function LimitedWord:replaceLimited(userword)
	if userword == nil or '' == userword then
		return userword;
	end
	while true do	
		local isLimit, word = self:isLimitedWithWord(userword);	
		if isLimit then
			local exchText = ''
			for i = 1, utf8.len(word) do
				exchText = exchText .. '*';
			end
			userword = string.gsub(userword, word, exchText);
		else
			break;
		end
	end
	return userword;
end

--是否屏蔽字
function LimitedWord:isLimitedWithWord(userword)
	local len = self:length(userword);
	
	--屏蔽单引号、双引号、百分号
	if string.find(userword, "'") then
		return true, "'";
	end
	if string.find(userword, '"') then
		return true, '"';
	end
	if string.find(userword, '%%') then
		return true, '%%';
	end
	
	local uchars = {};
	for uchar in string.gfind(userword, "([%z\1-\127\194-\244][\128-\191]*)") do
		table.insert(uchars, uchar);
	end

	for i = 0, len-1 do
		for j = 1, len-i do
			local uchar = self:substring(uchars, j, j + i);
			if self.words[uchar] ~= nil then
				return true, uchar;
			end
		end
	end
	return false, nil;
end

--UTF-8长度
function LimitedWord:length(word)
	local _, len = string.gsub(word, "[^\128-\193]", "");
	return len;
end

--显示时，一个中文转成两个英文
function LimitedWord:enLength(str)
  local _,n=str:gsub('[\128-\255]','');
  return #str-n/3;
 end

--子字符串
function LimitedWord:substring(uchars, first, last)
	local word = '';
	for j = first, last do
		word = word .. uchars[j];
	end
	return word;
end
