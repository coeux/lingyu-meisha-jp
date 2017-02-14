--innerTestPackPanel.lua

--========================================================================
--内测礼包面板

InnerTestPackPanel =
	{
		url	= '';
	};

local mainDesktop;
local panel;
local shuijing;
local vipLevel;
local gotButton;
local innerTestPackBtn;					--内测礼包按钮

--初始化面板
function InnerTestPackPanel:InitPanel( desktop )
	--界面初始化
	mainDesktop = desktop;
	panel = Panel( desktop:GetLogicChild('innerTestPackPanel') );
	panel:IncRefCount();
	panel.Visibility = Visibility.Hidden;
	
	shuijing = panel:GetLogicChild('shuijing');
	vipLevel = panel:GetLogicChild('vipLevel');
	gotButton = panel:GetLogicChild('gotButton');
	
	local iconId = resTableManager:GetValue(ResTable.item, tostring(10003), 'icon');	--水晶
	shuijing.Image = GetIcon(iconId);
	
	--内测礼包按钮（主界面）
	innerTestPackBtn = desktop:GetLogicChild('activityPanel'):GetLogicChild('thirdBtnList'):GetLogicChild('innerTestPack');
	innerTestPackBtn.Visibility = Visibility.Hidden;
	
	--测试是否有内测补偿
	local msg = {};
	msg.cmd = 'enable_buchang';
	msg.domain = platformSDK.m_Platform;
	msg.system = platformSDK.m_System;
	msg.name = platformSDK.m_UserName;
	msg.uid = Login.uid;
	msg.serid = Login:getServer(Login.hostnum).serid;

	msg = cjson.encode(msg);
	self.url = VersionUpdate.serverUrl .. '/buchang.php';
	curlManager:SendHttpScriptRequest(self.url, '', 'InnerTestPackPanel:onHaveTestPack', 3, msg, '', 0);
	
end

--销毁
function InnerTestPackPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function InnerTestPackPanel:Show()
	--显示属性界面
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);	
end

--隐藏
function InnerTestPackPanel:Hide()
	
	--隐藏属性界面
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
end

--测试是否可以领补偿回调
function InnerTestPackPanel:onHaveTestPack( request )
	if request.m_Data ~= nil then
		local data = cjson.decode(request.m_Data);
		if data.code == 0 then
			--显示主界面内测补偿按钮
			innerTestPackBtn.Visibility = Visibility.Visible;
			shuijing.ItemNum = data.yb;		--水晶
			
			if VersionUpdate.curLanguage == LanguageType.cn then
				vipLevel.Text = LANG_innerTestPackPanel_1 .. data.vip .. LANG_innerTestPackPanel_2;		--vip等级
			else
				vipLevel.Visibility = Visibility.Hidden;		--vip等级隐藏
			end
		end
	end
end

--领取补偿回调
function InnerTestPackPanel:onGotTestPack( request )
	if request.m_Data ~= nil then
		innerTestPackBtn.Visibility = Visibility.Hidden;
		MainUI:Pop();
		
		local data = cjson.decode(request.m_Data);
		if data.code == 0 then
			ToastMove:CreateToast( LANG_innerTestPackPanel_3 .. data.yb .. LANG_innerTestPackPanel_4 );
			ToastMove:CreateToast( LANG_innerTestPackPanel_5 .. data.vip .. LANG_innerTestPackPanel_6 );
		else
			ToastMove:CreateToast( LANG_innerTestPackPanel_7 );
		end
	end
end

--========================================================================
--界面响应
--========================================================================

--显示
function InnerTestPackPanel:onShow()
	MainUI:Push(self);
end

--返回
function InnerTestPackPanel:onClose()
	--领取内测补偿
	local msg = {};
	msg.cmd = 'given_buchang';
	msg.domain = platformSDK.m_Platform;
	msg.system = platformSDK.m_System;
	msg.name = platformSDK.m_UserName;
	msg.uid = Login.uid;
	msg.serid = Login:getServer(Login.hostnum).serid;

	msg = cjson.encode(msg);
	curlManager:SendHttpScriptRequest(self.url, '', 'InnerTestPackPanel:onGotTestPack', 3, msg, '', 0);
	
	gotButton.Enable = false;
end
