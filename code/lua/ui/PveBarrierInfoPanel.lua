--PveBarrierInfoPanel.lua

--========================================================================
--进入pve信息关卡

PveBarrierInfoPanel =
	{
		curBarrierId	= 0;						--选择进入的关卡id
		friendList		= {};						--助战好友列表
	};

--变量
local isZodia;
local needPower;
local selectIndex = 0;						--选择的助战好友下标
local isHangUp 	= true;						--是否挂机，或清除挂机CD
local cdTimer = 0;							--挂机cd计时器

--控件
local mainDesktop;
local mainPanel;
local panel;
local btnClose;
local btnHangUp;
local btnHangUpElem;
local btnChallenge;
local labelTitle;
local labelPower;
local labelExp;
local labelCoin;
local labelLevel;
local labelOpenLevel;
local labelZhuzhanhaoyou;
local icGoodList = {};
local labelFightCapacity;
local labelIcon;
local labelAchievementList = {};
--local labelGoodNameList = {};
local assistFrientCheckBoxList = {};

local pveGuardsPanel;
local bossName;
local bossNoName;
local monsterNameList = {};

local timeLeftTip;
local timeLeft;

local textCharpterInfo;

--初始化
function PveBarrierInfoPanel:InitPanel(desktop)
	--变量初始化
	self.curBarrierId	= 0;						--选择进入的关卡id
	self.friendList		= {};						--助战好友列表
	isZodia = false;
	needPower = 5;
	selectIndex = 0;								--选择的助战好友下标
	icGoodList = {};
	--labelGoodNameList = {};
	assistFrientCheckBoxList = {};
	monsterNameList = {};
	isHangUp = true;

	--控件初始化
	--[[
	mainDesktop 	= desktop;
	panel 			= Panel(desktop:GetLogicChild('pveGuanQiaEnterPanel'));
	panel:IncRefCount();
	btnClose		= Button(panel:GetLogicChild('close'));
	btnHangUp		= Button(panel:GetLogicChild('btnList'):GetLogicChild('guaiji'));
	btnHangUpElem	= btnHangUp:GetLogicChild('btnText');
	timeLeftTip		= panel:GetLogicChild('leftTimeTip')
	timeLeft		= timeLeftTip:GetLogicChild('time');
	btnChallenge	= Button(panel:GetLogicChild('btnList'):GetLogicChild('tiaozhan'));
	labelTitle		= Label(panel:GetLogicChild('title'));
	labelPower		= Label(panel:GetLogicChild('tili'));
	labelExp		= Label(panel:GetLogicChild('exp'));
	labelCoin		= Label(panel:GetLogicChild('jinbi'));
	labelLevel		= Label(panel:GetLogicChild('level'));
	labelOpenLevel		= Label(panel:GetLogicChild('openlevel'));
	labelZhuzhanhaoyou = panel:GetLogicChild('zhuzhanhaoyou');
	
	pveGuardsPanel	= panel:GetLogicChild('pveGuardsPanel');
	pveGuardsPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'PveBarrierInfoPanel:onCloseGuardsPanel');
	bossName		= pveGuardsPanel:GetLogicChild('bossName');
	bossNoName		= pveGuardsPanel:GetLogicChild('bossNoName');
	for index = 1, 5 do
		local monsterName = pveGuardsPanel:GetLogicChild('monster' .. index);
		table.insert(monsterNameList, monsterName);
	end
	
	for index = 1, 3 do
		local cb = panel:GetLogicChild(tostring(index));
		cb.Tag = index;
		cb:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PveBarrierInfoPanel:onFriendClick');
		table.insert(assistFrientCheckBoxList, cb);
	end
	
	for index = 1, 3 do
		local icGood = ItemCell(panel:GetLogicChild('dropItemList'):GetLogicChild('item' .. index));
		local labelGoodName = icGood:GetLogicChild(0);		
		table.insert(icGoodList, icGood);
		table.insert(labelGoodNameList, labelGoodName);
	end	
--]]

	--控件初始化
	mainDesktop 	= desktop;
	mainPanel 		= desktop:GetLogicChild('pveInfoPanel');
	panel 			= desktop:GetLogicChild('pveInfoPanel'):GetLogicChild('center');
	
	mainPanel:IncRefCount();
	btnClose		= Button(panel:GetLogicChild('btnClose'));
	btnHangUp		= Button(panel:GetLogicChild('btnSweep'));
	--btnHangUpElem	= btnHangUp:GetLogicChild('btnText');
	timeLeftTip		= panel:GetLogicChild('sweepTime')
	--timeLeft		= timeLeftTip:GetLogicChild('time');
	btnChallenge	= Button(panel:GetLogicChild('btnChallenge'));
	labelTitle		= Label(panel:GetLogicChild('smallChapterName'));
	labelChapter  = Label(panel:GetLogicChild('chapterName'))
	labelPower		= Label(panel:GetLogicChild('apLabel'));
	labelExp		= Label(panel:GetLogicChild('expLabel'));
	labelCoin		= Label(panel:GetLogicChild('goldLabel'));
	local fightPanel = Panel(panel:GetLogicChild('fightPanel'));
	labelFightCapacity = Label(fightPanel:GetLogicChild('fightNum'));
	labelIcon		= Label(panel:GetLogicChild('chapterIconLabel'));
	textCharpterInfo = TextElement(panel:GetLogicChild('chapterInfo'));
	local taskPanel1 = panel:GetLogicChild('task1');
	labelAchievementList.task = 
	{
		finish = taskPanel1:GetLogicChild('finish');
		normal = taskPanel1:GetLogicChild('normal');
		label  = taskPanel1:GetLogicChild('taskLabel');
	}
	labelAchievementList.task.finish.Visibility = Visibility.Hidden;
	labelAchievementList.task.normal.Visibility = Visibility.Visible;
	labelAchievementList.task.label.Visibility = Visibility.Visible;
	for i=1, 3 do
		local taskPanel = panel:GetLogicChild('task' .. i+1);
		labelAchievementList[i] = 
		{
			finish = taskPanel:GetLogicChild('finish');
			normal = taskPanel:GetLogicChild('normal');
			star   = taskPanel:GetLogicChild('finishstar');
			starbg = taskPanel:GetLogicChild('normalstar');	
			label  = taskPanel:GetLogicChild('taskLabel');		
		}
		labelAchievementList[i].finish.Visibility = Visibility.Hidden;
		labelAchievementList[i].normal.Visibility = Visibility.Visible;
		labelAchievementList[i].star.Visibility = Visibility.Hidden;
		labelAchievementList[i].starbg.Visibility = Visibility.Visible;
		labelAchievementList[i].label.Visibility = Visibility.Visible;
		
	end
	--labelLevel		= Label(panel:GetLogicChild('level'));
	--labelOpenLevel		= Label(panel:GetLogicChild('openlevel'));
	--labelZhuzhanhaoyou = panel:GetLogicChild('zhuzhanhaoyou');
	
--[[	
	pveGuardsPanel	= panel:GetLogicChild('pveGuardsPanel');
	pveGuardsPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'PveBarrierInfoPanel:onCloseGuardsPanel');
	bossName		= pveGuardsPanel:GetLogicChild('bossName');
	bossNoName		= pveGuardsPanel:GetLogicChild('bossNoName');
	for index = 1, 5 do
		local monsterName = pveGuardsPanel:GetLogicChild('monster' .. index);
		table.insert(monsterNameList, monsterName);
	end
	
	for index = 1, 3 do
		local cb = panel:GetLogicChild(tostring(index));
		cb.Tag = index;
		cb:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'PveBarrierInfoPanel:onFriendClick');
		table.insert(assistFrientCheckBoxList, cb);
	end
	--]]
	for index = 1, 5 do
		
		local icGood = customUserControl.new(panel:GetLogicChild('dropPanel'), 'rewardTemplate');-- UserControl(panel:GetLogicChild('dropPanel'):GetLogicChild('drop' .. index)):GetLogicChild(0);
		--local labelGoodImg = icGood:GetLogicChild('rewardImage');
		--local labelGoodNum = icGood:GetLogicChild('rewardNum');
		table.insert(icGoodList, icGood);
		--table.insert(labelGoodNameList, {img = labelGoodImg, num = labelGoodNum});
		
		--local icGood = ItemCell(panel:GetLogicChild('dropItemList'):GetLogicChild('item' .. index));
		--local labelGoodName = icGood:GetLogicChild(0);		
		--table.insert(icGoodList, icGood);
		--table.insert(labelGoodNameList, labelGoodName);
	end	
	
	--初始化时隐藏panel
	mainPanel.Visibility = Visibility.Hidden;
	--pveGuardsPanel.Visibility = Visibility.Hidden;
	timeLeftTip.Visibility = Visibility.Hidden;
end

--销毁
function PveBarrierInfoPanel:Destroy()
	mainPanel:DecRefCount();
	mainPanel = nil;
end	

--显示
function PveBarrierInfoPanel:Show()
	--向服务器发送统计数据
	print('1111111111111111');
	local taskID = Task:getMainTaskId();
	if (Task.mainTask ~= nil) and (taskID <= MenuOpenLevel.statistics) then
		local taskItem = resTableManager:GetValue(ResTable.task, tostring(taskID), {'type','value'});
		if (1 == taskItem['type']) and (self.curBarrierId == taskItem['value'][1]) then
			NetworkMsg_GodsSenki:SendStatisticsData(taskID, 4);
		end	
	end	
	
	labelExp.Text 	= '+' .. resTableManager:GetValue(ResTable.barriers, tostring(self.curBarrierId), 'exp');
	labelCoin.Text 	= '+' .. resTableManager:GetValue(ResTable.barriers, tostring(self.curBarrierId), 'coin');
	labelTitle.Text = resTableManager:GetValue(ResTable.barriers, tostring(self.curBarrierId), 'name');
	local chapterid = resTableManager:GetValue(ResTable.barriers, tostring(self.curBarrierId), 'city_id');
	labelChapter.Text = resTableManager:GetValue(ResTable.chapter ,tostring(chapterid), 'name')
	labelFightCapacity.Text = tostring(resTableManager:GetValue(ResTable.barriers, tostring(self.curBarrierId), 'fighting_capacity'));
	textCharpterInfo.Text = tostring(resTableManager:GetValue(ResTable.barriers, tostring(self.curBarrierId), 'description'));

	--[[
	if isZodia then										--显示关卡名
		labelLevel.Text = 'Lv' .. resTableManager:GetValue(ResTable.zodiac_level, tostring(ActorManager.hero:GetLevel()), 'lv' .. math.mod(self.curBarrierId, 100));
	else
		labelLevel.Text = 'Lv' .. resTableManager:GetValue(ResTable.barriers, tostring(self.curBarrierId), 'monster_level');
	end	
	--]]
	
	if isZodia and (math.mod(self.curBarrierId, 10) == 0) then
		needPower = Configuration.ZodiaBossNeedPower;
		labelPower.Text = '-' .. Configuration.ZodiaBossNeedPower;				--显示体力
	else
		needPower = Configuration.NormalRequestPower;
		labelPower.Text = '-' .. Configuration.NormalRequestPower;				--显示体力
	end
	
	--刷新挂机显示
	self:RefreshHangUp();
	
	--显示掉落物品
	---[[
	local drop_items = {};
	if isZodia then
		drop_items = resTableManager:GetValue(ResTable.zodiac_drop, tostring(ActorManager.hero:GetLevel()), 'drop' .. math.mod(self.curBarrierId, 100));
	else
		drop_items = resTableManager:GetValue(ResTable.barriers, tostring(self.curBarrierId), 'item_drop');
	end	

	for index = 1, 5 do
		if (drop_items ~= nil) and (nil ~= drop_items[index]) then
			print(drop_items[index][1])
			local item = resTableManager:GetValue(ResTable.item, tostring(drop_items[index][1]), {'name', 'icon', 'quality'});
			--icGoodList[index].Tag = drop_items[index][1];
			if item then
			icGoodList[index].Visibility = Visibility.Visible;
			--icGoodList[index].Background = Converter.String2Brush( QualityType[item['quality']]);
			--icGoodList[index].Image = GetPicture('icon/' .. item['icon'] .. '.ccz');
			--labelGoodNameList[index].Text = item['name'];
			icGoodList[index].setItemImage(item['icon']);
			icGoodList[index].setImageSize(62, 65)
			icGoodList[index]:Show();
			end
			--labelGoodNameList[index].img.Image = GetPicture('icon/' .. item['icon'] .. '.ccz');
			--print(item['icon'])
			--labelGoodNameList[index].img.Visibility = Visibility.Visible;
			--labelGoodNameList[index].num.Visibility = Visibility.Hidden;
		else
			icGoodList[index]:Hide();
		end
	end
	--]]
	
	--显示成就和评级
	print(333)
	self:setAchievement();
	print(222)

	--设置模式对话框 
	mainDesktop:DoModal(mainPanel);	

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1, nil, 'PveBarrierInfoPanel:onUserGuid');
end

--打开时的新手引导
function PveBarrierInfoPanel:onUserGuid()
	local taskID = Task:getMainTaskId();

	if taskID <= SystemTaskId.enterFight then
		UserGuidePanel:SetInGuiding(true);
		UserGuidePanel:ShowGuideShade(btnChallenge, GuideEffectType.hand, GuideTipPos.bottom, LANG_pveBarrierInfoPanel_2);
		UserGuidePanel:SetInGuiding(false);
	-- 在新手引导的中间状态
	elseif UserGuidePanel:GetInGuilding() then	
		UserGuidePanel:ShowGuideShade(btnChallenge, GuideEffectType.hand, GuideTipPos.bottom, LANG_pveBarrierInfoPanel_3, nil, 0.5);	
		UserGuidePanel:SetInGuiding(false);
	end
end

function PveBarrierInfoPanel:refreshHangUpBtn()
	if LuaTimerManager.leftHangUpSeconds > 0 then
		--btnHangUp.Text = LANG_pveBarrierInfoPanel_4 .. Time2MinSecStr( LuaTimerManager.leftHangUpSeconds );
		--btnHangUp.Font = uiSystem:FindFont('huakang_20');	
		timeLeft.Text = Time2MinSecStr( LuaTimerManager.leftHangUpSeconds );
		timeLeft.Font = uiSystem:FindFont('huakang_20');
		--timeLeftTip.Visibility = Visibility.Visible;
		--btnHangUpElem.Visibility = Visibility.Visible;
		btnHangUp.Text = '';
		isHangUp = false;
	else
		--btnHangUp.Text = LANG_pveBarrierInfoPanel_5;
		--btnHangUp.Font = uiSystem:FindFont('huakang_20');	
		isHangUp = true;
		--timeLeftTip.Visibility = Visibility.Hidden;
		--btnHangUpElem.Visibility = Visibility.Hidden;
	end
end


--隐藏
function PveBarrierInfoPanel:Hide()
	selectIndex = 0;
	self.friendList = {};
	for _,item in ipairs(assistFrientCheckBoxList) do
		item.Visibility = Visibility.Hidden;					--隐藏助战好友选项
	end
	
	Friend.isHelpApply = false;									--代表是战斗时候拉好友助战时申请好友列表信息

	--隐藏进入战斗的新手引导
	local taskID = Task:getMainTaskId();
	if taskID <= SystemTaskId.enterFight then
		UserGuidePanel:SetInGuiding(false);
		UserGuidePanel:HideAutoTaskGuide();
	end
	
	if 0 ~= cdTimer then
		timerManager:DestroyTimer(cdTimer);
		cdTimer = 0;
	end

	--取消模式对话框
	mainDesktop:UndoModal();

	--增加UI消失时的效果
	--StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--刷新挂机按钮显示
function PveBarrierInfoPanel:RefreshHangUp()
	--挂机按钮是否显示以及是否可用
	if isZodia then
		btnHangUp.Visibility = Visibility.Hidden;
		timeLeftTip.Visibility = Visibility.Hidden;
	else
		if Hero:GetLevel() < FunctionOpenLevel.HangUpOpenLevel then
			btnHangUp.Visibility = Visibility.Hidden;
		else
			btnHangUp.Visibility = Visibility.Visible;
			local stars = PveBarrierPanel:getBarriderStars(self.curBarrierId);
			if (nil ~= stars) and (stars >= 3) then
				btnHangUp.Enable = true;					--不可点击
				self:refreshHangUpBtn();
				if cdTimer == 0 then
					cdTimer = timerManager:CreateTimer(1, 'PveBarrierInfoPanel:refreshHangUpBtn', 0);
				end
			else
				btnHangUp.Enable = false;					--可点击
				--btnHangUp.Text = LANG_pveBarrierInfoPanel_1;
				--btnHangUp.Font = uiSystem:FindFont('huakang_20');	
				isHangUp = false;
				--timeLeftTip.Visibility = Visibility.Hidden;
				--btnHangUpElem.Visibility = Visibility.Hidden;
			end
		end
	end	
end

--========================================================================
--设置成就
function PveBarrierInfoPanel:setAchievement()
	print(123)
	--local achievementInfo = resTableManager:GetValue(ResTable.barriers, tostring(self.curBarrierId), 'achievement');
	FightManager.currentAchievement = FightAchievementClass.new(self.curBarrierId);
	local rankString = FightAchievementClass:getRankString(self.curBarrierId);
		print(3123)
	if rankString == '1' then 
		labelAchievementList.task.finish.Visibility = Visibility.Visible;	
	end
		print(1253)
	for i=1,3 do
		local res = FightManager.currentAchievement:getAchievementList()[i].isComplete;
		if res then
			labelAchievementList[i].finish.Visibility = Visibility.Visible;
			labelAchievementList[i].star.Visibility = Visibility.Visible;			
		end		
		labelAchievementList[i].label.Text = FightManager.currentAchievement:getAchievementList()[i].des;
	end
	
	
	
end

--========================================================================
--是否处于显示状态
function PveBarrierInfoPanel:IsVisible()
	return Visibility.Visible == panel.Visibility;
end
--========================================================================
--事件

--进入关卡信息界面
function PveBarrierInfoPanel:onEnterPveBarrierInfo(barrierID)
	--关卡id
	self.curBarrierId = barrierID;
	if (barrierID >= RoundIDSection.ZodiacBegin) and (barrierID <= RoundIDSection.ZodiacEnd) then
		isZodia = true;
	else
		isZodia = false;
	end	
	
	MainUI:Push(self);	
end

--关闭事件
function PveBarrierInfoPanel:onPveBarrierEnterInfoClose()
	MainUI:Pop();
end

--挂机事件
function PveBarrierInfoPanel:onHnagUpClick()
	if ActorManager.user_data.power < Configuration.NormalRequestPower then
		BuyCountPanel:ApplyData(VipBuyType.vop_buy_power);
		if isZodia then
			BuyCountPanel:SetTitle(LANG_pveBarrierInfoPanel_8);
		else
			BuyCountPanel:SetTitle(LANG_pveBarrierInfoPanel_9);
		end
	else
		if isHangUp then
			--先销毁现在的二级菜单
			MainUI:Pop();			
			--显示另一个二级菜单
			PveSweepPanel:onEnterHangUpPanel(self.curBarrierId);
			
		else
			local okDelegate = Delegate.new(PveBarrierInfoPanel, PveBarrierInfoPanel.onSendClearCd);
			--MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_pveBarrierInfoPanel_10, okDelegate);	
			local contents = {}
			table.insert(contents, {cType = MessageContentType.Text; text = LANG_pveBarrierInfoPanel_14});
			table.insert(contents, {cType = MessageContentType.Text; text = LANG_pveBarrierInfoPanel_15, color = QualityColor[3]});			
			table.insert(contents, {cType = MessageContentType.Text; text = LANG_pveBarrierInfoPanel_16});
			MessageBox:ShowDialog(MessageBoxType.OkCancel, contents, okDelegate);			
		end
		
	end	
end

--发送消除冷却时间
function PveBarrierInfoPanel:onSendClearCd()
	Network:Send(NetworkCmdType.req_round_pass_clear_cd, {});
end

--挑战事件
function PveBarrierInfoPanel:onChallengeClick()
	print("+++++Challenge+++++");
	MainUI:Pop();
	PveMutipleTeamPanel:onClick();
end

function PveBarrierInfoPanel:onChallenge()
	--向服务器发送统计数据
	if (Task.mainTask ~= nil) and (Task.mainTask['id'] <= MenuOpenLevel.statistics) then
		local taskItem = resTableManager:GetValue(ResTable.task, tostring(Task.mainTask['id']), {'type','value'});
		if (1 == taskItem['type']) and (self.curBarrierId == taskItem['value'][1]) then
			NetworkMsg_GodsSenki:SendStatisticsData(Task.mainTask['id'], 5);
		end	
	end	
	
	if ActorManager.user_data.power < needPower then
		BuyCountPanel:ApplyData(VipBuyType.vop_buy_power);
		if isZodia then
			BuyCountPanel:SetTitle(LANG_pveBarrierInfoPanel_11);
		else
			BuyCountPanel:SetTitle(LANG_pveBarrierInfoPanel_12);
		end
	else
		--请求进入关卡
		if Package:GetAllItemCount() > ActorManager.user_data.bagn - Configuration.WarningPackageCount then
			local okdelegate = Delegate.new(PveBarrierInfoPanel, PveBarrierInfoPanel.requestFight, 0);
			MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_pveBarrierInfoPanel_13, okdelegate);
		else
			self:requestFight();
		end	
	end
end

--进入战斗
function PveBarrierInfoPanel:requestFight()
	local msg = {};
	msg.resid = self.curBarrierId;
	if (0 == selectIndex) or (0 == #self.friendList) then
		msg.uid = 0;
		msg.pid = 0;
		Friend.helpFriend = nil;				--无助战好友
	else
		local friend = self.friendList[selectIndex];
		msg.uid = friend.uid;
		msg.pid = friend.pid;	
		if friend.isFriend then			--保存助战好友
			Friend.helpFriend = friend;
		else
			FightOverUIManager:SetStrangerInfo(friend.uid, friend.name, friend.lv);
			Friend.helpFriend = nil;			--无助战好友
		end
	end
	
	if isZodia then	
		msg.uid = 0;
		msg.pid = 0;
		Friend.helpFriend = nil;				--无助战好友
		
		Network:Send(NetworkCmdType.req_zodiac_enter, msg);
		MainUI:Pop();
	else
		Network:Send(NetworkCmdType.req_round_enter, msg);
	end	
	
	Loading.waitMsgNum = 1;
	Game:SwitchState(GameState.loadingState);
	
end	

--接受服务器发送的助战陌生人
function PveBarrierInfoPanel:onStrangerList(msg)
	for index,friend in ipairs(msg.strs) do
		friend.isFriend = false;
		table.insert(self.friendList, friend);		
	end	
	
	self:showAssistHero();
end	

--助战英雄点击事件
function PveBarrierInfoPanel:onFriendClick(Args)
	local args = UIControlEventArgs(Args);
	if args.m_pControl.Checked then
		selectIndex = 0;
	else
		selectIndex = args.m_pControl.Tag;
		for _,cb in ipairs(assistFrientCheckBoxList) do
			if selectIndex ~= cb.Tag then
				cb.Checked = false;
			end
		end
	end
end

--查看本关卡的怪物
function PveBarrierInfoPanel:onMonsterKind()
	pveGuardsPanel.Visibility = Visibility.Visible;
	mainDesktop.FocusControl = pveGuardsPanel;
	
	local data = resTableManager:GetValue(ResTable.barriers, tostring(self.curBarrierId), {'monster_name','boss_name'});

	if 0 == data['boss_name'] then
		bossNoName.Visibility = Visibility.Visible;
		bossName.Visibility = Visibility.Hidden;
	else
		local bName = resTableManager:GetValue(ResTable.monster, tostring(data['boss_name']), 'name');
		bossName.Text = '【' .. bName .. '】';
		bossName.Visibility = Visibility.Visible;
		bossNoName.Visibility = Visibility.Hidden;
	end
	
	local index = 1;
	while index <= 5 do
		local id = data['monster_name'][index];
		if nil ~= id then
			local name = resTableManager:GetValue(ResTable.monster, tostring(id), 'name');
			monsterNameList[index].Text = name;
			monsterNameList[index].Visibility = Visibility.Visible;
		else
			monsterNameList[index].Visibility = Visibility.Hidden;
		end
		index = index + 1;
	end
	
	pveGuardsPanel.Size = Size(260, 80 + 30*(#data['monster_name']));
	
end

--关闭关卡守卫
function PveBarrierInfoPanel:onCloseGuardsPanel()
	pveGuardsPanel.Visibility = Visibility.Hidden;
end

--点击图标的事件
function PveBarrierInfoPanel:onIconClick(Args)
	local args = UIControlEventArgs(Args);
	local itemid = args.m_pControl.Tag;

	local item = {};
	item.resid = args.m_pControl.Tag;
	item.itemType = resTableManager:GetValue(ResTable.item, tostring(itemid), 'type');
	if item.itemType == ItemType.material then
		TooltipPanel:ShowItem(panel, item, TooltipPanel.NoButton);
	else
		TooltipPanel:ShowItem(panel, item, TooltipPanel.NoButton);
	end
end
