--settingPanel.lua
--=============================================================================================

SettingPanel =
{
	isSoundON = true;
};

--初始化
function SettingPanel:InitPanel(desktop)
	self.isSoundON = true;	
	--控件初始化
	self.mainDesktop = desktop;
	self.panel = Panel(desktop:GetLogicChild('settingPanel'));
	self.panel.Visibility = Visibility.Hidden;
	self.panel:IncRefCount();

	self.soundPanel = self.panel:GetLogicChild('soundPanel');
	self.soundON = self.panel:GetLogicChild('soundPanel'):GetLogicChild('soundON');
	self.soundON:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'SettingPanel:onSoundON');
	self.soundOFF = self.panel:GetLogicChild('soundPanel'):GetLogicChild('soundOFF');
	self.soundOFF:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'SettingPanel:onSoundOFF');
	self.switchAccountBtn = self.panel:GetLogicChild('switchAccountBtn');
	self.switchAccountBtn:SubscribeScriptedEvent('Button::ClickEvent', 'SettingPanel:onSwitchAccount');
	self.closeBtn = self.panel:GetLogicChild('closeBtn');
	self.closeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'SettingPanel:onClose');

	self.soundON.GroupID = RadionButtonGroup.settingPanelSound;
	self.soundOFF.GroupID = RadionButtonGroup.settingPanelSound;

	self.inBtn = self.panel:GetLogicChild('inBtn');
	self.inBtn:SubscribeScriptedEvent('Button::ClickEvent', 'SettingPanel:genInCode');
	self.goToBtn = self.panel:GetLogicChild('goToBtn');
	self.goToBtn:SubscribeScriptedEvent('Button::ClickEvent','SettingPanel:goToClick');
	
	self.panel.Visibility = Visibility.Hidden;
end

function SettingPanel:goToClick()
	local okDelegate = Delegate.new(SettingPanel, SettingPanel.goTo, 0);
	local contents = {};
	table.insert(contents,{cType = MessageContentType.Text; text = LANG_settingPanel_1});
	table.insert(contents,{cType = MessageContentType.Text; text = LANG_settingPanel_2});
	table.insert(contents,{cType = MessageContentType.Text; text = LANG_settingPanel_3});
	MessageBox:ShowDialog(MessageBoxType.OkCancel, contents, okDelegate);
end
function SettingPanel:goTo()
	if platformSDK.m_System == "iOS" then
		appFramework:OpenUrl('http://www.qmax.co.jp/busouhyakki/support/');
	elseif platformSDK.m_System == "Android" then
		platformSDK:GetExtraInfo("url", "http://www.qmax.co.jp/busouhyakki/support/");
	end
end
--销毁
function SettingPanel:Destroy()
	self.panel:DecRefCount();
	self.panel = nil;
end

function SettingPanel:onSwitchAccount()
	appFramework:Reset();
end

function SettingPanel:onSoundON()
	self.soundPanel.Background = Converter.String2Brush(FightConfigBrush.On);
	SystemPanel.soundFlag = true;
	SystemPanel.soundEffectFlag = true;
	--写入到本地配置表中
	SystemPanel:SaveFile();
	SoundManager:SetBackgroundSound(true);   --设置背景乐的声音大小
	SoundManager:PlayBackgroundSound();
end

function SettingPanel:onSoundOFF()
	self.soundPanel.Background = Converter.String2Brush(FightConfigBrush.Off);
	SoundManager:PauseBackgroundSound();
	SystemPanel.soundFlag = false;
	SystemPanel.soundEffectFlag = false
	SystemPanel:SaveFile();
end

function SettingPanel:genInCode()
	local msg = {};
    Network:Send(NetworkCmdType.req_gen_in_code_t, msg);	
end

--显示
function SettingPanel:Show()

	if SystemPanel.soundFlag and SystemPanel.soundEffectFlag then
		self.soundPanel.Background = Converter.String2Brush(FightConfigBrush.On);
		self.soundON.Selected = true;
		self.soundOFF.Selected = false;
	else
		self.soundPanel.Background = Converter.String2Brush(FightConfigBrush.Off);
		self.soundON.Selected = false;
		self.soundOFF.Selected = true;
	end

	mainDesktop:DoModal(self.panel);
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(self.panel, StoryBoardType.ShowUI1);
	GodsSenki:LeaveMainScene()
end

--隐藏
function SettingPanel:Hide()
	--mainDesktop:UndoModal();
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(self.panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
	GodsSenki:BackToMainScene(SceneType.HomeUI)
end

function SettingPanel:onClose()
	MainUI:Pop();
end
