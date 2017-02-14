--systemPanel.lua

--========================================================================
--系统界面

SystemPanel =
	{
		soundFlag			= true;				--声音开关
		soundEffectFlag		= true;				--音效开关
		pisaPushAmFlag		= true;				--12点体力领取推送
		pisaPushPmFlag		= true;				--18点体力领取推送
		energyFullPushFlag	= true;				--体力恢复推送
		
		fileName			= 'config.dat';		--文件名
	};

--控件
local mainDesktop;
local systemPanel;
local checkboxSound;
local checkboxSoundEffect;
local checkboxPisaPushAm;
local checkboxPisaPushPm;
local checkboxEnergyFullPush;



--初始化面板
function SystemPanel:InitPanel( desktop )

	mainDesktop = desktop;
	systemPanel = Panel(desktop:GetLogicChild('systemPanel'));
	systemPanel:IncRefCount();
	
	systemPanel.Visibility = Visibility.Hidden;
	
	checkboxSound = systemPanel:GetLogicChild('sound');
	checkboxSound.Checked = true;
	checkboxSoundEffect = systemPanel:GetLogicChild('soundEffect');
	checkboxSoundEffect.Checked = true;
	checkboxPisaPushAm = systemPanel:GetLogicChild('pisaPushAm');
	checkboxPisaPushAm.Checked = true;
	checkboxPisaPushPm = systemPanel:GetLogicChild('pisaPushPm');
	checkboxPisaPushPm.Checked = true;
	checkboxEnergyFullPush = systemPanel:GetLogicChild('energyFullPush');
	checkboxEnergyFullPush.Checked = true;
	
	self:LoadFile();

end

--销毁
function SystemPanel:Destroy()
	systemPanel:DecRefCount();
	systemPanel = nil;
end

--显示
function SystemPanel:Show()
	--设置模式对话框
	mainDesktop:DoModal(systemPanel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(systemPanel, StoryBoardType.ShowUI1);
end

--隐藏
function SystemPanel:Hide()
	self:SaveFile();
	
	--重新注册推送
	--Push:RegisterPush();
	
	--取消模式对话框
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(systemPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--加载配置
function SystemPanel:LoadFile()
	
	local file = appFramework:GetDocumentPath() .. self.fileName;
	if not OperationSystem.IsPathExist(file) then
		--文件不存在
		return;
	end

	local xfile = xmlParseFile(file);
	if xfile == nil then
		return;
	end
	
	local rootNode = xfile[1];
	if rootNode == nil then
		return;
	end

	local attr = rootNode['attr'];
	if attr == nil then
		return;
	end

	local sound = attr['sound'];
	if sound == nil then
		return;
	end
	
	local soundEffect = attr['soundEffect'];
	if soundEffect == nil then
		return;
	end
	
	local pisaPushAm = attr['pisaPushAm'];
	if pisaPushAm == nil then
		return;
	end
	
	local pisaPushPm = attr['pisaPushPm'];
	if pisaPushPm == nil then
		return;
	end
	
	local energyFullPush = attr['energyFullPush'];
	if energyFullPush == nil then
		return;
	end
	
	if tonumber(sound) == 1 then
		self.soundFlag = true;
	else
		self.soundFlag = false;
	end
	
	if tonumber(soundEffect) == 1 then
		self.soundEffectFlag = true;
	else
		self.soundEffectFlag = false;
	end
	
	if tonumber(pisaPushAm) == 1 then
		self.pisaPushAmFlag = true;
	else
		self.pisaPushAmFlag = false;
	end
	
	if tonumber(pisaPushPm) == 1 then
		self.pisaPushPmFlag = true;
	else
		self.pisaPushPmFlag = false;
	end
	
	if tonumber(energyFullPush) == 1 then
		self.energyFullPushFlag = true;
	else
		self.energyFullPushFlag = false;
	end
	
	
	checkboxSound.Checked = self.soundFlag;
	checkboxSoundEffect.Checked = self.soundEffectFlag;
	checkboxPisaPushAm.Checked = self.pisaPushAmFlag;
	checkboxPisaPushPm.Checked = self.pisaPushPmFlag;
	checkboxEnergyFullPush.Checked = self.energyFullPushFlag;

end

--保存配置
function SystemPanel:SaveFile()
	local fileName = appFramework:GetDocumentPath() .. self.fileName;
	local sound, soundEffect,pisaPushAm,pisaPushPm,energyFullPush;
	if self.soundFlag then
		sound = 1;
	else
		sound = 0;
	end
	if self.soundEffectFlag then
		soundEffect = 1;
	else
		soundEffect = 0;
	end
	if self.pisaPushAmFlag then
		pisaPushAm = 1;
	else
		pisaPushAm = 0;
	end
	if self.pisaPushPmFlag then
		pisaPushPm = 1;
	else
		pisaPushPm = 0;
	end
	if self.energyFullPushFlag then
		energyFullPush = 1;
	else
		energyFullPush = 0;
	end
	
	local str = string.format('<Config sound="%d" soundEffect="%d"  pisaPushAm="%d" pisaPushPm="%d" energyFullPush="%d"/>', sound, soundEffect, pisaPushAm, pisaPushPm, energyFullPush);

	local file = io.open(fileName, 'w');
	if file == nil then
		return;
	end

	file:write(str);
	file:close();
end


--========================================================================
--点击事件

--背景音乐改变
function SystemPanel:onSoundChange( Args )
	self.soundFlag = checkboxSound.Checked;
	SoundManager:SetBackgroundSound(checkboxSound.Checked);
end

function SystemPanel:onSoundTextCick( Args )
	checkboxSound.Checked = not checkboxSound.Checked;
end

--音效改变
function SystemPanel:onSoundEffectChange( Args )
	self.soundEffectFlag = checkboxSoundEffect.Checked;
end

function SystemPanel:onSoundTextCick( Args )
	checkboxSoundEffect.Checked = not checkboxSoundEffect.Checked;
end

--12点领pisa设置
function SystemPanel:onPisaPushAmChange( Args )
	self.pisaPushAmFlag = checkboxPisaPushAm.Checked;
end

--18点领pisa设置
function SystemPanel:onPisaPushPmChange( Args )
	self.pisaPushPmFlag = checkboxPisaPushPm.Checked;
end

--体力满设置
function SystemPanel:onEnergyFullPushChange( Args )
	self.energyFullPushFlag = checkboxEnergyFullPush.Checked;
end

--关闭
function SystemPanel:onClose()
	MainUI:Pop();
end

--联系客服
function SystemPanel:onConnectCustom()
	MainUI:Pop();
	MainUI:Push(QuestPanel);
end
