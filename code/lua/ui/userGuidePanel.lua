--userGuidePanel.lua

--========================================================================
--新手引导界面

UserGuidePanel =
	{
		isUserGuide				= false;		--是否处于新手引导阶段
		hideGuideTalkEvent		= nil;			--隐藏talk时事件
		isArenaBegin            = false;
		isPropertyBegin         = false;
		isExpeditionBegin       = false;
		guideNum 				= 1000;
	};

--控件
local mainDesktop;
local userGuidePanel;
local guideShadePanel;
local newFeaturePanel;
local guideTalkPanel;
local newFeatureShade;

local isHeroLvUp;

local skipBtn;
local leftBrush;
local rightBrush;
local topBrush;
local bottomBrush;
local guideTipPanel;
local tipPanel;
local guideTipContent;
local guideArm;


local newFeatureBrush;
local shadeBrush;
local newFeatureTipPanel;
local newFeatureTipContent;
local labelGuideTalk;

--变量
local tipHeight = 0;
local tipWidth = 0;
local refreshTimer = 0;	
local targetPos;
local curPos;
local DelayTime = 1.7;
local HeartTime = 0.05;
local shadeCount = 0;
local curGuideIndex = 0;
local curGuideType = 1;

local showGuidShadeList = {};
local hidGuidShadeList = {};

local isequipGuide = true;


--初始化面板
function UserGuidePanel:InitPanel(desktop)
	--类变量初始化	
	self:SetInGuiding(false);

	--变量初始化
	tipHeight = 0;
	tipWidth = 0;
	refreshTimer = 0;	
	targetPos = nil;
	curPos = nil;
	DelayTime = 1.7;
	HeartTime = 0.05;
	shadeCount = 0;
	showGuidShadeList = {};
	hidGuidShadeList = {};
	

	--界面初始化
	mainDesktop = desktop;
	userGuidePanel = Panel(desktop:GetLogicChild('userGuidePanel'));
	userGuidePanel:IncRefCount();
	userGuidePanel.ZOrder = PanelZOrder.userGuide;
	
	guideShadePanel = Panel(userGuidePanel:GetLogicChild('guideShadePanel'));
	newFeaturePanel = Panel(userGuidePanel:GetLogicChild('newFeaturePanel'));
	newFeatureShade = Panel(userGuidePanel:GetLogicChild('newFeatureShade'));
	guideTalkPanel = Panel(userGuidePanel:GetLogicChild('guideTalkPanel'));
	skipBtn = userGuidePanel:GetLogicChild('skip');
	skipBtn:SubscribeScriptedEvent('Button::ClickEvent', 'UserGuidePanel:onSkip');
	
	labelGuideTalk = Label(guideTalkPanel:GetLogicChild('talkContent'));	
	
	leftBrush = BrushElement(guideShadePanel:GetLogicChild('left'));
	rightBrush = BrushElement(guideShadePanel:GetLogicChild('right'));
	topBrush = BrushElement(guideShadePanel:GetLogicChild('top'));
	bottomBrush = BrushElement(guideShadePanel:GetLogicChild('bottom'));
	guideTipPanel = Panel(guideShadePanel:GetLogicChild('guideTip'));
	guideArm = ArmatureUI(guideTipPanel:GetLogicChild('hand'));
	tipPanel = Panel(guideTipPanel:GetLogicChild('tipPanel'));
	guideTipContent = Label(tipPanel:GetLogicChild('tipContent'));	
		
	newFeatureBrush = BrushElement(newFeaturePanel:GetLogicChild('newFeature'));
	shadeBrush = BrushElement(newFeaturePanel:GetLogicChild('newFeatureShade'));
	newFeatureTipPanel = Panel(newFeaturePanel:GetLogicChild('newFeatureTip'));
	newFeatureTipContent = Label(newFeatureTipPanel:GetLogicChild('tipContent'));
	
	tipHeight = guideTipPanel.Height;
	tipWidth = guideTipPanel.Width;
	userGuidePanel.Visibility = Visibility.Hidden;
	newFeatureShade.Visibility = Visibility.Hidden;
	guideTalkPanel.Visibility = Visibility.Hidden;
	skipBtn.Visibility = Visibility.Hidden;
	isHeroLvUp = false;

	topDesktop:AddChild(userGuidePanel);
end

--销毁
function UserGuidePanel:Destroy()
	userGuidePanel:DecRefCount();
end

--显示说话提示
function UserGuidePanel:ShowGuideTalk( text )
	labelGuideTalk.Text = text;

	userGuidePanel.Visibility = Visibility.Visible;		
	newFeaturePanel.Visibility = Visibility.Hidden;
	guideShadePanel.Visibility = Visibility.Hidden;	
	guideTalkPanel.Visibility = Visibility.Visible;	
end

--隐藏说话提示
function UserGuidePanel:HideGuideTalk()
	userGuidePanel.Visibility = Visibility.Hidden;		
	newFeaturePanel.Visibility = Visibility.Hidden;
	guideShadePanel.Visibility = Visibility.Hidden;	
	guideTalkPanel.Visibility = Visibility.Hidden;
	
	if self.hideGuideTalkEvent ~= nil then
		self.hideGuideTalkEvent:Callback();
		self.hideGuideTalkEvent = nil;
	end
end

--显示有遮罩的新手引导提示
function UserGuidePanel:ShowGuideShade(uiControl, effectType, tipPos, text, margin, opacity, time)
		if time == nil then
			time = 30;
		end
		shadeCount = shadeCount + 1;
		-- print('TTTTTTTTTTTTTTTTTTTTTTT:' .. shadeCount);
		
		local param = {};
		param.uiControl = uiControl;
		param.effectType = effectType;
		param.tipPos = tipPos;
		param.text = text;
		param.margin = margin;
		if opacity == nil then
			param.opacity = 0;
		else
			param.opacity = opacity;
		end
		table.insert(showGuidShadeList, param);
		
		self:ShowNewFeatureShade();
		AppendDelayTriggerEvent(function()
                   UserGuidePanel:showGuideShadeDelay()
                end, time);
		
--	end
end	

--延迟点注销事件，避免当前事件已经赋值，并被注销
function UserGuidePanel:showGuideShadeDelay()
	if #showGuidShadeList ~= 0 then
		local param = showGuidShadeList[1];
		self:ShadeVisiblity();
		self:ShowGuide(param.uiControl, param.effectType, param.tipPos, true, param.text, param.margin, param.opacity);
		param.uiControl:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'UserGuidePanel:Hide');
		table.remove(showGuidShadeList, 1);
	end
end


function UserGuidePanel:refreshUserGuideTask(tag)
	local allUserGuideApplyPanel = {                       --所有触发引导的Panel对应的Btn触发事件
	      TaskTipPanel:getUserGuideBtn(),
	      MenuPanel:getUserGuideBtn(),                  
          CardDetailPanel:getUserGuideBtn(),
          CardDetailPanel:getUserGuideRoleBtn(),
    };
	self:ShowGuideShade(allUserGuideApplyPanel[tag],GuideEffectType.hand, GuideTipPos.right, LANG_equipStrengthPanel_15);
end

--触发自动任务提示
function UserGuidePanel:TriggerAutoTaskGuide()
	--新手引导提示
	if not self:GetInGuilding() and ActorManager.user_data.role.lvl.level < 10 then	
		skipBtn.Visibility = Visibility.Hidden;
		UserGuidePanel:ShowGuideShade(TaskTipPanel:getUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	end
end

--显示没遮罩的提示，主要是自动任务的提示
function UserGuidePanel:ShowGuideNoShade(uiControl, effectType, tipPos, text)
	userGuidePanel.Visibility = Visibility.Visible;	
	self:ShowGuide(uiControl, effectType, tipPos, false, text);
end	

--=============================================
--显示新手引导提示
--uiControl:遮罩的控件
--effectType:特效类型，包括手指，箭头和拖动
--tipPos:提示框相对位置
--isShade:是否显示遮罩
--text:提示框内容
--margin:特效向上相对控件的偏移率
--=============================================
function UserGuidePanel:ShowGuide(uiControl, effectType, tipPos, isShade, text, margin, opacity)
	UserGuidePanel:clickGuideBtn(uiControl)
	if self.guideNum/1000 < ActorManager.user_data.userguide.isnew then
		self.guideNum = ActorManager.user_data.userguide.isnew * 1000;
	else
		self.guideNum = self.guideNum + 1
	end

	self.guideNum = self.guideNum;

	local msg = {};
	msg.step = self.guideNum;
	Network:Send(NetworkCmdType.nt_quit_step, msg, true);


	if uiControl.Enable == false then
		UserGuidePanel:ReqWriteGuidence(curGuideIndex, curGuideType);
		hidGuidShadeList = {};
		shadeCount = 0;
		self:ShadeVisiblity();
		guideArm:Destroy();
		tipPanel.Visibility = Visibility.Hidden;
		return
	end
	guideShadePanel.Visibility = Visibility.Visible;
	newFeaturePanel.Visibility = Visibility.Hidden;	
	newFeatureShade.Visibility = Visibility.Hidden;	
	if nil ~= text then
		guideTipContent.Text = text;
	end
	--第一帧时强制布局下，可读正确坐标
	uiControl:ForceLayout();
	
	if isShade then
		leftBrush.Visibility = Visibility.Visible;
		rightBrush.Visibility = Visibility.Visible;
		topBrush.Visibility = Visibility.Visible;
		bottomBrush.Visibility = Visibility.Visible;
		
		if opacity == nil then
			opacity = 0;
		end
		
		leftBrush.Opacity = opacity;
		rightBrush.Opacity = opacity;
		topBrush.Opacity = opacity;
		bottomBrush.Opacity = opacity;
	else
		leftBrush.Visibility = Visibility.Hidden;
		rightBrush.Visibility = Visibility.Hidden;
		topBrush.Visibility = Visibility.Hidden;
		bottomBrush.Visibility = Visibility.Hidden;
		
		leftBrush.Opacity = 0;
		rightBrush.Opacity = 0;
		topBrush.Opacity = 0;
		bottomBrush.Opacity = 0;
	end
	
	local x = uiControl:GetAbsTranslate().x;
	local y = uiControl:GetAbsTranslate().y;
	local w = uiControl.Width;
	local h = uiControl.Height;	
	
	if UserGuidePanel:IsInGuidence(UserGuideIndex.upstar, 1) or  UserGuidePanel:IsInGuidence(UserGuideIndex.talent, 1) and CardListPanel:IsShow() then
		--x = x - 29;
		--y = y + 29;
	end
	if UserGuidePanel:IsInGuidence(UserGuideIndex.talent, 1) and XinghunPanel:IsShow() then
		--x = x + 66;
	end
	if UserGuidePanel:IsInGuidence(UserGuideIndex.talent, 1) and XinghunPanel:IsPopShow() then
		--y = y - 29;
	end
	
	topBrush.Height = y;
	topBrush.Width = mainDesktop.Width;
	bottomBrush.Height = mainDesktop.Height - y - h;
	bottomBrush.Width = mainDesktop.Width;
	bottomBrush:SetTranslateY(y + h);

	leftBrush.Width = x;
	leftBrush.Height = h;
	leftBrush:SetTranslateY(y);
	
	rightBrush.Width = mainDesktop.Width - x - w;
	rightBrush.Height = h;
	rightBrush:SetTranslateX(x + w);
	rightBrush:SetTranslateY(y);
	
	local path;
	local name;
	if GuideEffectType.arrow == effectType then
		name = 'zhiyin';
	elseif GuideEffectType.hand == effectType then		
		name = 'xinshoujiantou';
	elseif GuideEffectType.handMove == effectType then
		path = GlobalData.EffectPath .. 'tuozhuai_output/';
		--只出现一次，使用时加载，其他两个提前加载
		AvatarManager:LoadFile(path);
		name = 'tuozhuai';
	elseif GuideEffectType.handMove2 == effectType then
		path = GlobalData.EffectPath .. 'tuozhuai_output/';
		--只出现一次，使用时加载，其他两个提前加载
		AvatarManager:LoadFile(path);
		name = 'tuozhuai_2';
	end
	
	if GuideEffectType.arrow ~= effectType and GuideEffectType.hand ~= effectType then
		shadeCount = shadeCount - 1;
		print('Z: - ' .. shadeCount)
	end	

	if nil == margin then
		margin = 0;
	end
	if nil ~= guideArm then
		guideArm:Destroy();
	end
	guideArm:LoadArmature(name);
	guideArm:SetAnimation('play');
	
	guideTipPanel.Translate = Vector2(x, y);
	if GuideEffectType.arrow == effectType then
		guideArm.Translate = Vector2(-0.25 * tipWidth, h/3);
	elseif GuideEffectType.hand == effectType then
	--	guideArm.Translate = Vector2(w/2 + tipWidth*0.1, h + tipHeight*0.1 - h*margin);
		guideArm.Translate = Vector2(w/2, h/2);
	elseif GuideEffectType.handMove == effectType then
		guideArm.Translate = Vector2(w/2 - tipWidth*0.9, h - tipHeight*0.5);
	elseif GuideEffectType.handMove2 == effectType then
		guideArm.Translate = Vector2(w/2 - tipWidth*0.25, h - tipHeight*0.5);
	end
	
	tipPanel.Visibility = Visibility.Visible;	

	if GuideTipPos.no == tipPos then
		tipPanel.Visibility = Visibility.Hidden;
	elseif GuideTipPos.left == tipPos and GuideEffectType.arrow == effectType then
		tipPanel.Translate = Vector2(-1.30 * tipWidth, h/2 - tipHeight/2);
	elseif GuideTipPos.left == tipPos and GuideEffectType.hand == effectType then
		tipPanel.Translate = Vector2(w/2 - tipWidth, h - tipHeight*0.2);	
	elseif GuideTipPos.right == tipPos then
		tipPanel.Translate = Vector2(w/2 + 0.3 * tipWidth,  h - tipHeight*0.2);
	elseif GuideTipPos.bottom == tipPos then
		tipPanel.Translate = Vector2(w/2 - 0.40 * tipWidth, h + tipHeight*0.8);
	end
	TaskTipPanel:settasktiparm(false);
end

--隐藏自动任务提示
function UserGuidePanel:HideAutoTaskGuide()
	if nil ~= guideShadePanel then
		guideShadePanel.Visibility = Visibility.Hidden;
	end	
end

--新手引导触发下一步
function UserGuidePanel:clickGuideBtn(uiControl)
	if ActorManager.user_data.role.lvl.level <= 10 then
		local shadebtn = {topBrush,leftBrush,rightBrush,bottomBrush}
		self.m_pControl = uiControl
		local ui = uiControl:GetScriptedEventHandler('UIControl::MouseClickEvent');
		if ui == '' then
			ui = uiControl:GetScriptedEventHandler('Button::ClickEvent');
		end

		for _, btncontrol in pairs(shadebtn) do
			if ui ~= '' and ui then
				btncontrol.Tag = uiControl.Tag;
				btncontrol:RemoveAllEventHandler();
				btncontrol.TagExt = uiControl.TagExt;
				btncontrol:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'UserGuidePanel:HideGuide');
				btncontrol:SubscribeScriptedEvent('UIControl::MouseClickEvent', ui);
			else
				btncontrol:RemoveAllEventHandler();
			end
		end
	end
end

--触发下一步隐藏新手引导
function UserGuidePanel:HideGuide()
	table.insert(hidGuidShadeList, self.m_pControl);
	timerManager:CreateTimer(0, 'UserGuidePanel:removeEvent', 0, true);		--设置定时器进行事件删除
	shadeCount = shadeCount - 1;
	self:ShadeVisiblity();
	if shadeCount <= 0 then
		guideArm:Destroy();
		tipPanel.Visibility = Visibility.Hidden;
		shadeCount = 0;
	end
end


--新功能开启显示
function UserGuidePanel:ShowNewFeature( brush, prompt, size )
	self:SetInGuiding(true);	
	userGuidePanel.Visibility = Visibility.Visible;		
	newFeaturePanel.Visibility = Visibility.Visible;
	guideShadePanel.Visibility = Visibility.Hidden;	
	newFeatureShade.Visibility = Visibility.Visible;

	newFeatureBrush.Scale = Vector2(1, 1);
	newFeatureBrush.Translate = Vector2(0, 0);
	newFeatureBrush.Background = brush;
	newFeatureTipContent.Text = prompt;
	newFeatureBrush.Size = size;

	--弹出所有对话框，防止新手开启时菜单不能点击
	MainUI:PopAll();
	
	timerManager:CreateTimer(DelayTime, 'UserGuidePanel:showButton', 0, true);
	totalTime = 0;	
	curPos = Vector2(0, 0);
end

--隐藏新手引导
function UserGuidePanel:Hide( Args )
	local args = UIControlEventArgs(Args);
	table.insert(hidGuidShadeList, args.m_pControl);
	--print(args.m_pControl.Name)
	timerManager:CreateTimer(0, 'UserGuidePanel:removeEvent', 0, true);		--设置定时器进行事件删除

	shadeCount = shadeCount - 1;
	
	self:ShadeVisiblity();
	
	if shadeCount <= 0 then
		guideArm:Destroy();
		tipPanel.Visibility = Visibility.Hidden;
		
		shadeCount = 0;
	end
end

--移除事件
function UserGuidePanel:removeEvent()
	if #hidGuidShadeList ~= 0 then
		local uiControl = hidGuidShadeList[1];
		uiControl:UnSubscribeScriptedEvent('UIControl::MouseClickEvent', 'UserGuidePanel:Hide');
		table.remove(hidGuidShadeList, 1);
	end
end

function UserGuidePanel:ShadeVisiblity()
	if shadeCount > 0 then
		userGuidePanel.Visibility = Visibility.Visible;
	else
		userGuidePanel.Visibility = Visibility.Hidden;
	end
end

function UserGuidePanel:showButton()
	targetPos = MenuPanel:getNewMenuPos();
	refreshTimer = timerManager:CreateTimer(HeartTime, 'UserGuidePanel:moveButton', 0);	
end

function UserGuidePanel:hideNewFeature()
	newFeaturePanel.Visibility = Visibility.Hidden;	
end

--新开启图标移动效果
function UserGuidePanel:moveButton()
	newFeatureTipPanel.Visibility = Visibility.Hidden;
	local dir = targetPos - curPos;
	local length = dir:Normalise();
	local dis = 30;
	if dis >= length then
		newFeatureBrush.Translate = targetPos;
		newFeatureShade.Visibility = Visibility.Hidden;	
		--到达目标
		if 0 ~= refreshTimer then
			timerManager:DestroyTimer(refreshTimer);
			refreshTimer = 0;
			MenuPanel:openNewMenuShade();
		end
	else
		--没有到达，就移动
		dis = dir * dis;
		curPos = curPos + dis;
		newFeatureBrush.Translate = curPos;
	end
end

-- 用于外部控制状态的接口
function UserGuidePanel:InitButton(bmpName)
	newFeatureBrush.Scale = Vector2(1, 1);
	newFeatureBrush.Translate = Vector2(0, 0);	
	userGuidePanel.Visibility = Visibility.Visible;		
	newFeaturePanel.Visibility = Visibility.Visible;
	guideShadePanel.Visibility = Visibility.Hidden;	
	newFeatureShade.Visibility = Visibility.Hidden;	
	newFeatureTipPanel.Visibility = Visibility.Hidden;
	newFeatureBrush.Background = Converter.String2Brush(bmpName);
end

function UserGuidePanel:HidePanel()
	userGuidePanel.Visibility = Visibility.Hidden;
end

function UserGuidePanel:setBGDButtonPos(pos)
	newFeatureBrush.Translate = pos;
end

--添加新功能开启遮罩，防止被点击
function UserGuidePanel:ShowNewFeatureShade()
	userGuidePanel.Visibility = Visibility.Visible;
	newFeatureShade.Visibility = Visibility.Visible;		
end

--隐藏新功能开启遮罩
function UserGuidePanel:HideNewFeatureShade()
	newFeatureShade.Visibility = Visibility.Hidden;	
end

--设置引导状态
function UserGuidePanel:SetInGuiding( val )
	self.isUserGuide = val;
end

--获得新手引导状态
function UserGuidePanel:GetInGuilding()
	return self.isUserGuide;
end

--显示新功能开启界面
function UserGuidePanel:GetNewSystem(index)
	if index == UserGuideIndex.arenaTask or index == UserGuideIndex.propertyTask or index == UserGuideIndex.task10 then
		local openSystemPanel = mainDesktop:GetLogicChild('OpenNewSystemPanel');
		openSystemPanel.Visibility = Visibility.Visible;
		openSystemPanel:GetLogicChild('Panel'):GetLogicChild('text').Text = LANG_OpenSystemPanel_text[index];
		openSystemPanel:GetLogicChild('Panel'):GetLogicChild('title').Text = LANG_OpenSystemPanel_title[index];
		openSystemPanel:GetLogicChild('Panel'):GetLogicChild(5).Image = GetPicture('userGuide/userguide_img' .. index .. '.ccz');
		openSystemPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'UserGuidePanel:startuseGuide');
		openSystemPanel.Tag = index;
	else
		UserGuidePanel:enterUserGuide(index);
	end
end
function UserGuidePanel:enterUserGuide(index)
	if UserGuidePanel:IsInGuidence(UserGuideIndex.card, 1) then
		MenuPanel:getGuideCardPanel().Visibility = Visibility.Visible;
		self:ShowGuideShade( MenuPanel:getGuideCardBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.equipadv, 1) then
		self:ShowGuideShade( MenuPanel:getUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif index == UserGuideIndex.npcshop then
		LimitTaskPanel:GetNewNews(LimitNews.npcshop);
	elseif index == UserGuideIndex.upstar then
		self:ShowGuideShade( MenuPanel:getUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right,'');
	elseif index == UserGuideIndex.talent then
		self:ShowGuideShade( MenuPanel:getUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right,'');
	elseif index == UserGuideIndex.skillup then
		self:ShowGuideShade( MenuPanel:getUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right,'');
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.dailytask, 1) then
		MenuPanel:getGuideTaskBtn().Visibility = Visibility.Visible;
		self:ShowGuideShade( MenuPanel:getGuideTaskBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif index == UserGuideIndex.worldBossTask then
		if self:IsInGuidence(UserGuideIndex.worldBossTask, 2) then
			self:ReqWriteGuidence(UserGuideIndex.worldBossTask,2)
		end
		-- self:ShowGuideShade( MenuPanel:getUserGuideTaskBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3)     --  世界boss
	elseif index == UserGuideIndex.expeditonTask then
		self:ShowGuideShade( MenuPanel:getUserGuideTaskBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3)     --  远征
	--elseif index == UserGuideIndex.task11 then
	--	self:ShowGuideShade(MenuPanel:getUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right,'');
	elseif index == UserGuideIndex.task16 then
		self:ShowGuideShade(MenuPanel:getBtnDungeons(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif index == UserGuideIndex.task17 then
		-- self:ReqWriteGuidence(UserGuideIndex.task17);
		--进入副本界面
		--paweiug
		--self:ShowGuideShade(MenuPanel:getUserGuideTaskBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif index == UserGuideIndex.task18 then
		if TreasurePanel:checkUserGuideTask18() then
			self:ShowGuideShade(MenuPanel:getBtnDungeons(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
		else
			self:ReqWriteGuidence(UserGuideIndex.task18);
		end
	elseif index == UserGuideIndex.cardEvent then
		self:ShowGuideShade( MenuPanel:getEventPanel(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif index == UserGuideIndex.union then
		self:ReqWriteGuidence(UserGuideIndex.union,2)
		return;
	elseif index == UserGuideIndex.soulAndCrystalsoul then
		--soulug
		--UserGuidePanel:onOpenSoul();
	elseif index == 100 then
		--soulug
		--self:ReqWriteGuidence(UserGuideIndex.soulAndCrystalsoul, 2);
	end
end
---[[
function UserGuidePanel:startuseGuide(Args)
	local args = UIControlEventArgs(Args);
	local index = args.m_pControl.Tag;
	mainDesktop:GetLogicChild('OpenNewSystemPanel').Visibility = Visibility.Hidden;
	if index == UserGuideIndex.arenaTask then
		self:ShowGuideShade( MenuPanel:getUserGuideTaskBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3)     --  竞技场
	elseif index == UserGuideIndex.propertyTask then
		self:ShowGuideShade( MenuPanel:getUserGuideTaskBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3)     --  属性试炼
	elseif index == UserGuideIndex.task10 then																	 --  探宝
		if TreasurePanel:checkUserGuideTask10() then
			self:ShowGuideShade(MenuPanel:getBtnDungeons(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
		else
			self:ReqWriteGuidence(UserGuideIndex.task10);
		end
	end
end
--]]
--[[
function UserGuidePanel:startuseGuide(Args)
	local args = UIControlEventArgs(Args);
	local index = args.m_pControl.Tag;
	mainDesktop:GetLogicChild('OpenNewSystemPanel').Visibility = Visibility.Hidden;
	if UserGuidePanel:IsInGuidence(UserGuideIndex.card, 1) then
		MenuPanel:getGuideCardPanel().Visibility = Visibility.Visible;
		self:ShowGuideShade( MenuPanel:getGuideCardBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.equipadv, 1) then
		self:ShowGuideShade( MenuPanel:getUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif index == UserGuideIndex.npcshop then
		LimitTaskPanel:GetNewNews(LimitNews.npcshop);
	elseif index == UserGuideIndex.upstar then
		self:ShowGuideShade( MenuPanel:getUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right,'');
	elseif index == UserGuideIndex.talent then
		self:ShowGuideShade( MenuPanel:getUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right,'');
	elseif index == UserGuideIndex.skillup then
		self:ShowGuideShade( MenuPanel:getUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right,'');
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.dailytask, 1) then
		MenuPanel:getGuideTaskBtn().Visibility = Visibility.Visible;
		self:ShowGuideShade( MenuPanel:getGuideTaskBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif index == UserGuideIndex.arenaTask then
		self:ShowGuideShade( MenuPanel:getUserGuideTaskBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3)     --  竞技场
	elseif index == UserGuideIndex.worldBossTask then
		if self:IsInGuidence(UserGuideIndex.worldBossTask, 2) then
			self:ReqWriteGuidence(UserGuideIndex.worldBossTask,2)
		end
		-- self:ShowGuideShade( MenuPanel:getUserGuideTaskBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3)     --  世界boss
	elseif index == UserGuideIndex.propertyTask then
		self:ShowGuideShade( MenuPanel:getUserGuideTaskBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3)     --  属性试炼
	elseif index == UserGuideIndex.expeditonTask then
		self:ShowGuideShade( MenuPanel:getUserGuideTaskBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3)     --  远征
	elseif index == UserGuideIndex.task10 then
		if TreasurePanel:checkUserGuideTask10() then
			self:ShowGuideShade(MenuPanel:getBtnDungeons(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
		else
			self:ReqWriteGuidence(UserGuideIndex.task10);
		end
	elseif index == UserGuideIndex.task11 then
		self:ShowGuideShade(MenuPanel:getUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right,'');
	elseif index == UserGuideIndex.task16 then
		self:ShowGuideShade(MenuPanel:getBtnDungeons(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif index == UserGuideIndex.task17 then
		-- self:ReqWriteGuidence(UserGuideIndex.task17);
		--进入副本界面
		--paweiug
		--self:ShowGuideShade(MenuPanel:getUserGuideTaskBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif index == UserGuideIndex.task18 then
		if TreasurePanel:checkUserGuideTask18() then
			self:ShowGuideShade(MenuPanel:getBtnDungeons(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
		else
			self:ReqWriteGuidence(UserGuideIndex.task18);
		end
	elseif index == UserGuideIndex.cardEvent then
		self:ShowGuideShade( MenuPanel:getEventPanel(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif index == UserGuideIndex.union then
		self:ReqWriteGuidence(UserGuideIndex.union,2)
		return;
	elseif index == UserGuideIndex.soulAndCrystalsoul then
		--soulug
		--UserGuidePanel:onOpenSoul();
	elseif index == 100 then
		--soulug
		--self:ReqWriteGuidence(UserGuideIndex.soulAndCrystalsoul, 2);
	end
end
--]]
function UserGuidePanel:onOpenSoul()
	local openSystemPanel = mainDesktop:GetLogicChild('OpenNewSystemPanel');
	openSystemPanel.Visibility = Visibility.Visible;
	openSystemPanel:GetLogicChild('Panel'):GetLogicChild('text').Text = LANG_OpenSystemPanel_text[100];
	openSystemPanel:GetLogicChild('Panel'):GetLogicChild('title').Text = LANG_OpenSystemPanel_title[100];
	openSystemPanel:GetLogicChild('Panel'):GetLogicChild(5).Image = GetPicture('userGuide/userguide_img' .. 100 .. '.ccz');
	openSystemPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'UserGuidePanel:startuseGuide');
	openSystemPanel.Tag = 100;
end

--请求记录新手引导任务
function UserGuidePanel:ReqWriteGuidence(index, guideindex)
	local msg = {};
	msg.index = index;
	msg.guideindex = guideindex or 1;
	Network:Send(NetworkCmdType.req_write_guidence, msg);
	--记录新手引导流失点
	NetworkMsg_GodsSenki:SendStatisticsData(index, 8);
	UserGuidePanel:SetIsLvUp(false)
end

--新手引导任务记录返回
function UserGuidePanel:retWriteGuidence(msg)
	TaskTipPanel:settasktiparm(true);
	if msg.index == 0 then
		return
		--错误的索引
	elseif msg.guideindex == 1 then
		ActorManager.user_data.userguide.isnew = msg.index;
	elseif msg.guideindex == 2 then
		ActorManager.user_data.userguide.isnewlv = msg.index;
	end
	MenuPanel:InitMenu()
	if msg.index ~= UserGuideIndex.fight1 then
		UserGuidePanel:SelectAndEnterGuidence();
	end
	if not self:GetInGuilding() and MainUI:GetSceneType() ~= SceneType.MainCity then	
		UserGuidePanel:ShowGuideShade(TaskTipPanel:getUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	end
end


--判断并进入新手引导
function UserGuidePanel:SelectAndEnterGuidence()
	UserGuidePanel:SetInGuiding(true);
	if UserGuidePanel:IsInGuidence(UserGuideIndex.hire, 1) then
		if not ActorManager:GetRoleFromResid(GuidePartner.hire) then		
			UserGuidePanel:ShowGuideShade(LimitTaskPanel:getUserGuidePartnerGoBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
		else
			self:ShowGuideShade( MenuPanel:getUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
		end
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.hire1, 2) then
		UserGuidePanel:ShowGuideShade(LimitTaskPanel:getUserGuidePartnerGoBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.card, 1) then
		UserGuidePanel:GetNewSystem(UserGuideIndex.card);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.love2, 1) and LoveMaxPanel:GetLoveGuide() and LovePanel:IsRoleCanAttack(ActorManager:GetRoleFromResid(GuidePartner.love)) then
		UserGuidePanel:ShowGuideShade(MenuPanel:getUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.love, 2) and LoveMaxPanel:GetLoveGuide() and LovePanel:IsRoleCanAttack(ActorManager:GetRoleFromResid(GuidePartner.love)) then
		self:ShowGuideShade( MenuPanel:getUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	--elseif UserGuidePanel:IsInGuidence(UserGuideIndex.cardrolelvup, 1) then
		--UserGuidePanel:ShowGuideShade(MenuPanel:getUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.equip, 1) and not EquipStrengthPanel:IsEquipHaveUpLevel() and isequipGuide then
		UserGuidePanel:ShowGuideShade(MenuPanel:getUserGuideBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.equipadv, 1) and not EquipStrengthPanel:IsEquipHaveAdv() and isequipGuide then
		UserGuidePanel:GetNewSystem(UserGuideIndex.equipadv);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.npcshop, 1) then
		UserGuidePanel:GetNewSystem(UserGuideIndex.npcshop);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.upstar, 1) then
		UserGuidePanel:GetNewSystem(UserGuideIndex.upstar);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.talent, 1) then
		UserGuidePanel:GetNewSystem(UserGuideIndex.talent);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.skillup, 2) then
		UserGuidePanel:GetNewSystem(UserGuideIndex.skillup);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.dailytask, 1) then
		self:ShowGuideShade( MenuPanel:getGuideTaskBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	elseif self:IsInGuidence(UserGuideIndex.arenaTask, 1) then         --  任务编号27     竞技场
		self.isArenaBegin = true
		UserGuidePanel:GetNewSystem(UserGuideIndex.arenaTask)
	elseif self:IsInGuidence(UserGuideIndex.worldBossTask, 2) then         --  任务编号30     世界boss
		UserGuidePanel:GetNewSystem(UserGuideIndex.worldBossTask)
	elseif self:IsInGuidence(UserGuideIndex.propertyTask, 2) then         --  任务编号33     属性副本
		self.isPropertyBegin = true
		UserGuidePanel:GetNewSystem(UserGuideIndex.propertyTask)
	elseif self:IsInGuidence(UserGuideIndex.expeditonTask, 2) then         --  任务编号38     远征
		self.isExpeditionBegin = true
		UserGuidePanel:GetNewSystem(UserGuideIndex.expeditonTask)
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.task10, 1)then 
		UserGuidePanel:GetNewSystem(UserGuideIndex.task10);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.task16, 1) then
		UserGuidePanel:GetNewSystem(UserGuideIndex.task16);
	--elseif UserGuidePanel:IsInGuidence(UserGuideIndex.task17, 2) then
		--paiweiug
		--UserGuidePanel:GetNewSystem(UserGuideIndex.task17);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.task18, 1) then
		UserGuidePanel:GetNewSystem(UserGuideIndex.task18);
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.union, 2) then
		UserGuidePanel:GetNewSystem(UserGuideIndex.union);
	--elseif UserGuidePanel:IsInGuidence(UserGuideIndex.cardEvent, 1) then
		--UserGuidePanel:GetNewSystem(UserGuideIndex.cardEvent);
	--elseif UserGuidePanel:IsInGuidence(UserGuideIndex.soulAndCrystalsoul, 2) then
		--soulug
		--UserGuidePanel:GetNewSystem(UserGuideIndex.soulAndCrystalsoul);
	else
		UserGuidePanel:SetInGuiding(false);
	end
end

--判断是否处于某个新手引导状态中, typeNum == 1代表有任务Id判断,2代表由等级判断
function UserGuidePanel:IsInGuidence(guideindex, typeNum)
	--由任务Id判断新手引导
	if typeNum == 1 then
		if Task:getMainTaskId() == SystemTaskId[guideindex] and guideindex > ActorManager.user_data.userguide.isnew then
			if guideindex == UserGuideIndex.upstar then
				return false;
			end
			for index = 0, #SystemTaskId do
				if Task:getMainTaskId() == SystemTaskId[guideindex + index] then
					curGuideIndex = guideindex + index;
					curGuideType = 1;
				else
					break;
				end
			end
			--记录新手引导流失点
			NetworkMsg_GodsSenki:SendStatisticsData(guideindex, 1);
			return true;
		else
			return false;
		end
	--由等级判断新手引导
	elseif typeNum == 2 then
		if guideindex > ActorManager.user_data.userguide.isnewlv and ActorManager.user_data.role.lvl.level == SystemTaskId[guideindex] then   --- guideindex > ActorManager.user_data.isnew and 
			curGuideIndex = guideindex;
			curGuideType = 2;
			--记录新手引导流失点
			NetworkMsg_GodsSenki:SendStatisticsData(guideindex, 1);
			return true
		else
			return false
		end
	--由前置新手引导判断
	elseif typeNum == 3 then
		if guideindex == ActorManager.user_data.userguide.isnew + 1 then
			curGuideIndex = guideindex;
			curGuideType = 1;
			--记录新手引导流失点
			NetworkMsg_GodsSenki:SendStatisticsData(guideindex, 1);
			return true;
		end
		return false;
	end
end

--获取新手引导时是否处于角色升级状态
function UserGuidePanel:GetIsLvUp()
	return isHeroLvUp;
end

--获取新手引导时是否处于角色升级状态
function UserGuidePanel:SetIsLvUp(flag)
	isHeroLvUp = flag;
end

--是否通过主界面进入装备引导
function UserGuidePanel:SetIsequipguide(flag)
	isequipGuide = flag;
end

--是否通过主界面进入装备引导状态
function UserGuidePanel:GetIsequipguide()
	return isequipGuide;
end

--跳过新手引导
function UserGuidePanel:onSkip()
	if ActorManager.user_data.role.lvl.level <= 10 then
		--不允许skip
	else
		UserGuidePanel:ReqWriteGuidence(curGuideIndex, curGuideType)
		hidGuidShadeList = {};
		shadeCount = 0;
		self:ShadeVisiblity();
		guideArm:Destroy();
		tipPanel.Visibility = Visibility.Hidden;
		UserGuidePanel:SetIsLvUp(false)
	end
end
