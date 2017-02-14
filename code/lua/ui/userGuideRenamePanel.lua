--userGuideRenamePanel.lua

--========================================================================
--新手引导重命名界面

UserGuideRenamePanel =
	{
	};

--变量
local resid;			        --伙伴resid
local heroName;                --主角名字
local defaultName;				--默认名字（不能在InitPanel里面初始化，但会setDefaultName设置默认值）

--控件
local mainDesktop;
local userGuideRenamePanel;
local textCreateName;
local btnCreate;
local btnRandom;
local changeNameFlag;				--是否使用改名卡改名字

--初始化面板
function UserGuideRenamePanel:InitPanel(desktop)
	--变量初始化
	resid = nil;			        --伙伴resid
	heroName = '';                	--主角名字
	changeNameFlag = false;

	--界面初始化
	mainDesktop = desktop;
	userGuideRenamePanel = Panel(desktop:GetLogicChild('userGuideRename'));
	userGuideRenamePanel:IncRefCount();
	
	userGuideRenamePanel.Visibility = Visibility.Hidden;

	local panel = userGuideRenamePanel:GetLogicChild(0);
	textCreateName = TextBox(panel:GetLogicChild('createName'));
	textCreateName:SubscribeScriptedEvent('Label::TextChangedEvent', 'UserGuideRenamePanel:onTextChange');
	btnCreate = Button( panel:GetLogicChild('create') );
	btnRandom = Button( panel:GetLogicChild('random') );	
	
end	

--销毁
function UserGuideRenamePanel:Destroy()
	userGuideRenamePanel:DecRefCount();
	userGuideRenamePanel = nil;
end

--显示
function UserGuideRenamePanel:Show()
	--设置模式对话框
	StoryBoard:DetectSameStoryBoardList();
	
	mainDesktop:DoModal(userGuideRenamePanel);
	textCreateName.Text = defaultName;

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(userGuideRenamePanel, StoryBoardType.ShowUI1);
end

--隐藏
function UserGuideRenamePanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();	

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(userGuideRenamePanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--========================================================================
--点击事件

--点击创建角色按钮
function UserGuideRenamePanel:onRenameClick()
	local msg = {};
	if textCreateName.Text == '' then	
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_userGuideRenamePanel_1);
	elseif LimitedWord:isLimited(textCreateName.Text) then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_userGuideRenamePanel_2);
	else
		if changeNameFlag then
			--使用改名卡改名字			
			msg.resid = Configuration.ChangeNameCardID;
			msg.num = 1;
			msg.param = heroName;
			Network:Send(NetworkCmdType.req_use_item_t, msg);
		else			
			msg.name = heroName;
			Network:Send(NetworkCmdType.req_guidence_rename, msg);
		end	
	end	
end

--更新角色名
function UserGuideRenamePanel:AfterRename()
	--更新主界面角色名
	ActorManager:ChangeHeroName(heroName);
	uiSystem:UpdateDataBind();
	
	--新手引导起名字结束
	if not changeNameFlag then
		UserGuidePanel:SetInGuiding(false);
	end
	
	self:onClose();
end

--点击随机图标
function UserGuideRenamePanel:onRandomNameClick()
	Network:Send(NetworkCmdType.req_random_name, {});
end

--随机生成一个名字
function UserGuideRenamePanel:onRandomName(name)
	textCreateName.Text = name;
end

--显示重命名界面
function UserGuideRenamePanel:onShow(isChangeName)
	if isChangeName == nil then
		changeNameFlag = false;
	else
		changeNameFlag = isChangeName;
	end
	
	MainUI:Push(self);
end

--关闭
function UserGuideRenamePanel:onClose()
	MainUI:Pop();
end

--设置默认名字
function UserGuideRenamePanel:setDefaultName(name)
	defaultName = name;
end

--字符内容改变事件
function UserGuideRenamePanel:onTextChange(Args)
	local args = UIControlEventArgs(Args);
	if utf8.len(args.m_pControl.Text) > Configuration.HeroNameStrCount then
		--超过最大字符限制
		args.m_pControl.Text = heroName;
	else
		--没有超过最大字符限制
		heroName = args.m_pControl.Text;
	end
end