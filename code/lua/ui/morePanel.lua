--morePanel.lua

--========================================================================
--更多界面

MorePanel =
	{
	};	

--控件
local mainDesktop;
local morePanel;
local personalCenter;
local emailEffect;
local emailBtn;
local emailCountLabel;

--===========================================================
--繁体版使用
local sharePanel;
local gplusBtn;
local gplayBtn;
local facebookBtn;
--===========================================================


--初始化面板
function MorePanel:InitPanel(desktop)

	mainDesktop = desktop;
	morePanel = Panel(desktop:GetLogicChild('morePanel'));
	morePanel:IncRefCount();
	morePanel.Visibility = Visibility.Hidden;
	
	personalCenter = morePanel:GetLogicChild('btnList'):GetLogicChild('personalCenter');

	--快用、pp显示个人中心
	if platformSDK.m_Platform == 'ky' or platformSDK.m_Platform == 'pp' or platformSDK.m_Platform == 'itools' then
		personalCenter.Visibility = Visibility.Visible;
	else
		personalCenter.Visibility = Visibility.Hidden;
	end
	
	emailBtn = desktop:GetLogicChild('activityPanel'):GetLogicChild('email');
	--emailEffect = ArmatureUI(emailBtn:GetLogicChild('effect'));
	--emailEffect:LoadArmature('daxinfeng');
	--emailEffect:SetAnimation('play');
	
	emailCountLabel = morePanel:GetLogicChild('iconList'):GetLogicChild('email'):GetLogicChild('leftCountLabel');
	
	--===========================================================
	--繁体版使用
	if VersionUpdate.curLanguage == LanguageType.tw then
		--繁体版
		
		local shareBtn = morePanel:GetLogicChild('iconList'):GetLogicChild('share');
		
		if platformSDK.m_System == 'Android' or platformSDK.m_System == 'Win32' then
			shareBtn.Visibility = Visibility.Visible;
		else
			shareBtn.Visibility = Visibility.Hidden;
		end
		
		sharePanel = desktop:GetLogicChild('sharePanel');
		sharePanel:IncRefCount();
		sharePanel.Visibility = Visibility.Hidden;
		
		local stackShareList = sharePanel:GetLogicChild('shareList');
		local gplusPanel = stackShareList:GetLogicChild('1');
		local gplayPanel = stackShareList:GetLogicChild('2');
		
		gplusBtn = gplusPanel:GetLogicChild('gplusBtn');
		gplayBtn = gplayPanel:GetLogicChild('gplayBtn');
		facebookBtn = stackShareList:GetLogicChild('3'):GetLogicChild('facebookBtn');

		if platformSDK.m_System == "Android" or platformSDK.m_System == 'Win32' then
			gplusPanel.Visibility = Visibility.Visible;
			gplayPanel.Visibility = Visibility.Visible;
			stackShareList.Height = 300;
			sharePanel.Height = 358;
		else
			gplusPanel.Visibility = Visibility.Hidden;
			gplayPanel.Visibility = Visibility.Hidden;
			stackShareList.Height = 96;
			sharePanel.Height = 158;			
		end
		
		if ActorManager.user_data.counts.n_twoprecord == nil then
			ActorManager.user_data.counts.n_twoprecord = 0;
		end
		
		if self:IsDone(ShareType.gplus) then
			gplusBtn.Text = LANG_morePanel_2;
		else
			gplusBtn.Text = LANG_morePanel_3;
		end

		if self:IsDone(ShareType.gplay) then
			gplayBtn.Text = LANG_morePanel_2;
		else
			gplayBtn.Text = LANG_morePanel_3;
		end
		
		if self:IsDone(ShareType.facebook) then
			facebookBtn.Text = LANG_morePanel_2;
		else
			facebookBtn.Text = LANG_morePanel_3;
		end
	end
	--===========================================================
	
end

--刷新邮箱特效
function MorePanel:RefreshEmailEffect()
	local num = ActorManager.user_data.counts.n_gmail_unopend;
	if num ~= nil and num > 0 then
		emailBtn.Visibility = Visibility.Visible;
		emailCountLabel.Text = tostring(num);
		emailCountLabel.Visibility = Visibility.Visible;
	else
		emailBtn.Visibility = Visibility.Hidden;
		emailCountLabel.Visibility = Visibility.Hidden;
	end
end

--销毁
function MorePanel:Destroy()
	morePanel:DecRefCount();
	morePanel = nil;
	
	--===========================================================
	--繁体版使用
	if VersionUpdate.curLanguage == LanguageType.tw then
		--繁体版
		sharePanel:DecRefCount();
		sharePanel = nil;
	end
	--===========================================================
end	

--显示
function MorePanel:Show()
	
	--设置模式对话框
	mainDesktop:DoModal(morePanel);	

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(morePanel, StoryBoardType.ShowUI1);
end

--隐藏
function MorePanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();
		
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(morePanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
end

--========================================================================
--点击事件

--显示好友添加界面
function MorePanel:onShowMore()
	MainUI:Push(self);
end

--关闭
function MorePanel:onClose()
	MainUI:Pop();
end

--切换角色（现在是重新登录游戏）
function MorePanel:onChangeRole()
	local okDelegate = Delegate.new(Network, Network.onNetError);
	MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_morePanel_1, okDelegate);
	
	--[[	local msg = {};
	Network:Send(NetworkCmdType.req_quit_game_t, msg);
	
	GodsSenki.resetFlag = true;--]]
end

--点击个人中心
function MorePanel:onPersonalCenter()
	platformSDK:onOpenPersonalCenter();
end


--========================================================================
--繁体版分享使用
SharePanel =
	{
	};
	
function SharePanel:Show()
	--设置模式对话框
	mainDesktop:DoModal(sharePanel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(sharePanel, StoryBoardType.ShowUI1);
end

--隐藏
function SharePanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();
		
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(sharePanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
end

function SharePanel:onClose( shareType )
	MainUI:Pop();
end

function MorePanel:onShare( shareType )
	MainUI:Push(SharePanel);
end

function MorePanel:IsDone( sharePos )
	local v = bit.lshift(1, sharePos);
	return bit.band(ActorManager.user_data.counts.n_twoprecord, v) == v;
end

function MorePanel:onGPlusClick()
	local msg = {};
	msg.op_done = ShareType.gplus;
	Network:Send(NetworkCmdType.nt_twoprecrod_t, msg, true);
	appFramework:OpenUrl('http://www.baidu.com');
	
	gplusBtn.Text = LANG_morePanel_2;
end

function MorePanel:onGPlayClick()
	local msg = {};
	msg.op_done = ShareType.gplay;
	
	Network:Send(NetworkCmdType.nt_twoprecrod_t, msg, true);
	appFramework:OpenUrl('http://www.baidu.com');
	
	gplayBtn.Text = LANG_morePanel_2;
end

function MorePanel:onFacebookClick()
	local msg = {};
	msg.op_done = ShareType.facebook;
	
	Network:Send(NetworkCmdType.nt_twoprecrod_t, msg, true);
	appFramework:OpenUrl('http://www.baidu.com');
	
	facebookBtn.Text = LANG_morePanel_2;
end

--繁体版分享结束
--========================================================================
