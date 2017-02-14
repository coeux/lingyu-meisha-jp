--messageBox.lua
--================================================================
--新版对话框

MessageBoxType =
	{
		OkCancel	= 0;		--确定取消
		Ok 			= 1;		--确定O
	};

MessageContentType =
	{
		Text 		= 1;			--文本
		brush 		= 2;			--brushElement
	};

MessageBox =
	{
		dialogList 		= {};		--窗口队列
		id				= 0;		--窗口id

		defaultFont		= nil;		--默认字体
		defaultColor	= nil;		--默认颜色

		maxWidth		= nil;		--行最大宽度
		popNum			= 0;		--显示的窗口
	};

local messageBox;

--初始化
function MessageBox:InitPanel()
	messageBox = UIControl(uiSystem:FindControl('newMessageBox'));
	messageBox:IncRefCount();
	messageBox.Visibility = Visibility.Hidden;

	local rootPanel = messageBox:GetLogicChild('rootPanel');
	self.maxWidth = rootPanel.Width;
	self.defaultColor = QuadColor(Color(9, 47, 145, 255));
	self.defaultFont = uiSystem:FindFont('huakang_20_noborder');
	self.popNum = 0;
end

--销毁
function MessageBox:Destroy()
	messageBox:DecRefCount();
	messageBox = nil;
end

--分配窗口id
function MessageBox:allocID()
	self.id = self.id + 1;
	return self.id;
end

--显示对话框
--contents：1、类型为数组，插入文本{cType = MessageContentType.Text; text = 'LANG_messageBox_1'}
--插入文本时color和font不填时会使用默认值；插入刷子时，brush为BrushElement控件
--2、类型为字符串，直接填要显示的字符串
function MessageBox:ShowDialog( messageBoxType, contents, ... )
	StoryBoard:OnPopTopUI();

	if type(contents) == 'string' then
		local item = {cType = MessageContentType.Text; text = contents};
		contents = {};
		table.insert(contents, item);
	elseif type(contents) == 'table' then
		local newC = {};
		for _, v in ipairs(contents) do
			if type(v) == 'string' then
				local item = {cType = MessageContentType.Text; text = v};
				table.insert(newC, item);
			else
				table.insert(newC,v);
			end
		end
		contents = newC;
	end

	--分配ID
	local id = self:allocID();
	--创建并显示新MessageBox
	local newMessageBox = NewMessageBox.new(id, messageBoxType, contents);
	newMessageBox:SetCallBack(arg[1], arg[2]);
	local word_ok = LANG_MESSAGEBOX_OK;
	local word_cancel = LANG_MESSAGEBOX_CANCEL;
	local margin_ok = Rect(80, 145, 0, 0);
	local margin_cancel = Rect(0, 145, 80, 0);
	local margin_queding = Rect(0, 145, 0, 0);
	local size_ok = Size(110, 48);
	local size_cancel = Size(110, 48);
	local size_queding = Size(110, 48);
	if arg[3] then
		word_ok = tostring(arg[3]);
	end
	if arg[4] then
		word_cancel = tostring(arg[4]);
	end
	if arg[5] then
		margin_ok = arg[5];
	end
	if arg[6] then
		margin_cancel = arg[6];
	end
	if arg[7] then
		margin_queding = arg[7];
	end
	if arg[8] then
		size_ok = arg[8];
	end
	if arg[9] then
		size_cancel = arg[9];
	end
	if arg[10] then
		size_queding = arg[10];
	end

	newMessageBox:Show(word_ok, word_cancel, margin_ok, margin_cancel, margin_queding, size_ok, size_cancel, size_queding);

	self.dialogList[id] = newMessageBox;
	self.popNum = self.popNum + 1;
	return id;
end

--主动调用隐藏
function MessageBox:Hide( id )
	local newMessageBox = self.dialogList[id];
	if newMessageBox ~= nil then
		newMessageBox:Hide();
	end
end

--按钮响应函数
--ok
function MessageBox:onOK( Arg )
	local arg = UIControlEventArgs(Arg);
	local newMessageBox = self.dialogList[arg.m_pControl.Tag];
	if newMessageBox == nil then
		--防止在对话框小时的过程中连续点击按钮崩溃
		return;
	end

	self.popNum = self.popNum - 1;

	local okDelegate = newMessageBox:GetOkCallBack();

	newMessageBox:Hide();
	
	if okDelegate ~= nil then
		okDelegate:Callback();
	end
end

--cancel
function MessageBox:onCancel( Arg )
	local arg = UIControlEventArgs(Arg);
	local newMessageBox = self.dialogList[arg.m_pControl.Tag];
	if newMessageBox == nil then
		--防止在对话框小时的过程中连续点击按钮崩溃
		return;
	end

	self.popNum = self.popNum - 1;

	local cancelDelegate = newMessageBox:GetCancelCallBack();
	
	newMessageBox:Hide();
	
	if cancelDelegate ~= nil then
		cancelDelegate:Callback();
	end
end

--确定
function MessageBox:onQueDing( Arg )
	local arg = UIControlEventArgs(Arg);
	local newMessageBox = self.dialogList[arg.m_pControl.Tag];
	if newMessageBox == nil then
		--防止在对话框小时的过程中连续点击按钮崩溃
		return;
	end
	
	self.popNum = self.popNum - 1;

	local quedingDelegate = newMessageBox:GetQuedingCallBack();

	newMessageBox:Hide();
	
	if quedingDelegate ~= nil then
		quedingDelegate:Callback();
	end
end

--设置ok按钮显示文字
function MessageBox:SetOkShowName( id, text )
	local okButton = self.dialogList[id]:GetMessageBox():GetLogicChild('ok');
	if (nil ~= okButton) then
		okButton.Text = text;
	end
end

--设置ok按钮是否可点击
function MessageBox:SetOkEnable(id, flag)
	local okButton = self.dialogList[id]:GetMessageBox():GetLogicChild('ok');
	if (nil ~= okButton) then
		okButton.Enable = flag;
	end
end

--设置cancel按钮显示文字
function MessageBox:SetCancelShowName( id, text )
	local cancelButton = self.dialogList[id]:GetMessageBox():GetLogicChild('cancel');
	if (nil ~= cancelButton) then
		cancelButton.Text = text;
	end
end

--设置确定按钮显示文字
function MessageBox:SetQuedingShowName( id, text )
	local quedingButton = self.dialogList[id]:GetMessageBox():GetLogicChild('queding');
	if (nil ~= quedingButton) then
		quedingButton.Text = text;
	end
end

--是否有对话框弹出
function MessageBox:isPopup( )	
	if 0 == self.popNum then
		return false;
	else		
		return true;
	end
end
--=============================================================================
NewMessageBox = class();

function NewMessageBox:constructor(id, messageBoxType, contents)
	self.m_id = id;
	self.m_type = messageBoxType;
	self.m_contents = contents;

	self.m_lastLine = nil;
	self.m_leftWidth = MessageBox.maxWidth;

	self.m_messageBox = messageBox:Clone();
	self.m_rootPanel = self.m_messageBox:GetLogicChild('rootPanel');
end

--显示
function NewMessageBox:Show(word_ok, word_cancel, margin_ok, margin_cancel, margin_queding, size_ok, size_cancel, size_queding)
	local btnOk = self.m_messageBox:GetLogicChild('ok');
	local btnCancel = self.m_messageBox:GetLogicChild('cancel');
	local btnQueding = self.m_messageBox:GetLogicChild('queding');
	btnOk.Text = word_ok;
	btnOk.Margin = margin_ok;
	btnOk.Size = size_ok
	btnQueding.Text = word_ok;
	btnQueding.Margin = margin_queding;
	btnQueding.Size = size_queding;
	btnCancel.Text = word_cancel;
	btnCancel.Margin = margin_cancel;
	btnCancel.Size = size_cancel;
	--解析显示内容
	self:ParaserContents(self.m_contents);

	--显示
	topDesktop:DoModal(self.m_messageBox);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(self.m_messageBox, StoryBoardType.ShowUI2);
end

--关闭
function NewMessageBox:Hide()
	StoryBoard:HideTopUIStoryBoard(self.m_messageBox, StoryBoardType.HideUI2, 'StoryBoard::OnPopTopUI');
	
	MessageBox.dialogList[self.m_id] = nil;
end

--解析显示内容
function NewMessageBox:ParaserContents(contents)
	local count = 0;
	for _, content in ipairs(contents) do
		count = count + 1;
		local isNewLine = false;
		if content.cType == MessageContentType.Text then
			--文本
			--将字符串转化成宽字符串
			local text = Converter.String2WString(content.text .. ' ', 65001);

			--获取字符串显示颜色
			local color = content.color;
			if (color == nil) then
				color = MessageBox.defaultColor;
			end

			--获取显示字体
			local font = content.font;
			if (font == nil) then
				font = MessageBox.defaultFont;
			end

			--追加字体
			if count > 1 then
				isNewLine = true;
			end
			self:appendText(text, color, font, isNewLine);
		elseif content.cType == MessageContentType.brush then
			--追加画刷
			self:appendBrush(content.brush);
		end
	end
end

--追加文字内容
function NewMessageBox:appendText(wsText, color, font, isNewLine)
	if (self.m_lastLine == nil) then
		self:createNewLine();
	end
	if (isNewLine) then
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

--追加图片
function NewMessageBox:appendBrush(brushElement)
	if (self.m_lastLine == nil) then
		self:createNewLine();
	end

	--获取当前刷子的宽度
	local brushWidth = brushElement.Width;

	if (brushWidth > self.m_leftWidth) then
		--当前刷子宽度大于剩余宽度，则另起一行
		self:createNewLine();
	end

	self.m_lastLine:AddUIControl(brushElement);
	self.m_leftWidth = self.m_leftWidth - brushWidth;
end

--创建新行
function NewMessageBox:createNewLine()
	self.m_lastLine = uiSystem:CreateControl('CombinedElement');
	self.m_lastLine.Alignment = Alignment.Center;
	self.m_rootPanel:AddChild(self.m_lastLine);
	self.m_leftWidth = MessageBox.maxWidth;
end

--设置按钮回调
function NewMessageBox:SetCallBack( ... )
	local btnOk = self.m_messageBox:GetLogicChild('ok');
	local btnCancel = self.m_messageBox:GetLogicChild('cancel');
	local btnQueding = self.m_messageBox:GetLogicChild('queding');

	btnOk.Tag = self.m_id;
	btnCancel.Tag = self.m_id;
	btnQueding.Tag = self.m_id;

	--设置回调
	btnOk:SubscribeScriptedEvent('Button::ClickEvent', 'MessageBox:onOK');
	btnCancel:SubscribeScriptedEvent('Button::ClickEvent', 'MessageBox:onCancel');
	btnQueding:SubscribeScriptedEvent('Button::ClickEvent', 'MessageBox:onQueDing');

	--设置显示
	if (self.m_type == MessageBoxType.OkCancel) then
		btnOk.Visibility = Visibility.Visible;
		btnCancel.Visibility = Visibility.Visible;
		btnQueding.Visibility = Visibility.Hidden;

		self.m_okCallBack = arg[1];
		self.m_cancelCallBack = arg[2];
	else
		btnOk.Visibility = Visibility.Hidden;
		btnCancel.Visibility = Visibility.Hidden;
		btnQueding.Visibility = Visibility.Visible;

		self.m_quedingCallBack = arg[1];
	end
end

--获取messageBox
function NewMessageBox:GetMessageBox()
	return self.m_messageBox;
end

--获取Ok按钮回调
function NewMessageBox:GetOkCallBack()
	return self.m_okCallBack;
end

--获取取消按钮回调
function NewMessageBox:GetCancelCallBack()
	return self.m_cancelCallBack;
end

--获取确定按钮回调
function NewMessageBox:GetQuedingCallBack()
	return self.m_quedingCallBack;
end
