--multiTextControl.lua
--================================================================
--多行文本控件
MultiTextControl =
	{
		m_combinedElementList = {};
		m_width = 0;
	};

MultiTextControlType =
	{
		Text 	= 1;			--文本
		Control = 2;			--控件
	};

--获取combinedElement
function MultiTextControl:GetCombinedList(contents, width)
	self.m_width = width;
	self.m_leftWidth = 0;
	self.m_lastLine = nil;
	self.m_combinedElementList = {};

	self:ParaserContents(contents);

	return self.m_combinedElementList;
end

--解析显示内容
function MultiTextControl:ParaserContents(contents)
	for _, content in ipairs(contents) do
		if content.mType == MultiTextControlType.Text then
			--文本
			--将字符串转化成宽字符串
			local text = Converter.String2WString(content.text, 65001);

			--获取字符串显示颜色
			local color = content.color;
			if (color == nil) then
				color = Configuration.WhiteColor;
			end

			--获取显示字体
			local font = content.font;
			if (font == nil) then
				font = uiSystem:FindFont('huakang_20');
			end

			--追加字体
			self:AppendText(text, color, font);
		elseif content.mType == MultiTextControlType.Control then
			--追加画刷
			self:AppendControl(content.brush);
		end
	end
end

--创建新行
function MultiTextControl:createNewLine()
	self.m_lastLine = uiSystem:CreateControl('CombinedElement');
	self.m_lastLine.Alignment = Alignment.Center;
	self.m_leftWidth = self.m_width;

	table.insert(self.m_combinedElementList, self.m_lastLine);
end

--追加文本
function MultiTextControl:AppendText(wsText, color, font)
	if (self.m_lastLine == nil) then
		self:createNewLine();
	end

	--获取当前字符串的宽度
	local textLength = font:GetTextExtent(wsText, 1.0);

	--如果当前字符串的宽度大于最后一行的宽度
	while (textLength > self.m_leftWidth) do
		--添加行尾字符串
		local preText = font:GetTextFromLength(wsText, self.m_leftWidth, 1.0);
		self.m_lastLine:AddText(Converter.WString2String(preText, 65001), color, font);

		--保留剩余字符串
		wsText = font:GetTextOutOfLength(wsText, self.m_leftWidth, 1.0);

		--创建新行
		self:createNewLine();

		--重新计算剩余字符串长度
		textLength = font:GetTextExtent(wsText, 1.0);
	end

	--添加剩余字符串
	self.m_lastLine:AddText(Converter.WString2String(wsText, 65001), color, font);
	self.m_leftWidth = self.m_leftWidth - textLength;
end

--追加控件
function MultiTextControl:AppendControl(control)
	if (self.m_lastLine == nil) then
		self:createNewLine();
	end

	local controlWidth = control.Width;
	if (controlWidth > self.m_leftWidth) then
		self:createNewLine();
	end

	self.m_lastLine:AddUIControl(control);
	self.m_leftWidth = self.m_leftWidth - controlWidth;
end
