--roleMiKuInfoPanel.lua

--========================================================================
--进入迷窟信息关卡

RoleMiKuInfoPanel =
	{
		curBarrierId	= 0;						--选择进入的关卡id
	};

--变量
local needPower;
local selectIndex = 0;								--选择的助战好友下标
local isHangUp 	= true;						--是否挂机，或清除挂机CD
local cdTimer = 0;									--挂机cd计时器
local lefttimes = 0;								--剩余次数

--控件
local mainDesktop;
local panel;
local btnReset;
local btnHangUp;
local btnHangUpElem;
local btnChallenge;
local labelTitle;
local labelPower;
local labelExp;
local labelCoin;
local labelSoul;
local labelLeftTimes;
local labelOpenLevel;
local assistFrientCheckBoxList = {};

local bossHeadPic;
local bossName;
local bossDesc;

local mikuGuardsPanel;
local bossName;
local bossNoName;
local itemNameList = {};

local timeLeftTip;
local timeLeft;

--初始化
function RoleMiKuInfoPanel:InitPanel(desktop)
	--变量初始化
	self.curBarrierId	= 0;						--选择进入的关卡id
	needPower = Configuration.NormalRequestPower;
	selectIndex = 0;								--选择的助战好友下标
	assistFrientCheckBoxList = {};
	itemNameList = {};
	isHangUp = true;
	lefttimes = 0;

	--控件初始化
	mainDesktop 	= desktop;
	panel 			= Panel(desktop:GetLogicChild('roleMikuGuanQiaEnterPanel'));
	panel:IncRefCount();
	btnReset		= Button(panel:GetLogicChild('reset'));
	btnHangUp		= Button(panel:GetLogicChild('btnList'):GetLogicChild('guaiji'));
	btnHangUpElem	= btnHangUp:GetLogicChild('btnText');
	btnChallenge	= Button(panel:GetLogicChild('btnList'):GetLogicChild('tiaozhan'));
	timeLeftTip		= panel:GetLogicChild('leftTimeTip')
	timeLeft		= timeLeftTip:GetLogicChild('time');
	labelTitle		= panel:GetLogicChild('title');
	labelPower		= panel:GetLogicChild('tili');
	labelExp		= panel:GetLogicChild('exp');
	labelCoin		= panel:GetLogicChild('jinbi');
	labelSoul		= panel:GetLogicChild('soul');
	labelLeftTimes	= panel:GetLogicChild('lefttimes');
	labelOpenLevel	= panel:GetLogicChild('openlevel');
	
	bossHeadPic		= panel:GetLogicChild('bossHeadPic');
	bossName		= panel:GetLogicChild('bossname');
	bossDesc		= panel:GetLogicChild('bossdesc');
	
	mikuGuardsPanel	= panel:GetLogicChild('mikuGuardsPanel');
	mikuGuardsPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'RoleMiKuInfoPanel:onCloseGuardsPanel');
	for index = 1, 5 do
		local itemName = mikuGuardsPanel:GetLogicChild('item' .. index);
		table.insert(itemNameList, itemName);
	end
	
	for index = 1, 3 do
		local cb = panel:GetLogicChild(tostring(index));
		cb.Tag = index;
		cb:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RoleMiKuInfoPanel:onFriendClick');
		table.insert(assistFrientCheckBoxList, cb);
	end
	
	--初始化时隐藏panel
	panel.Visibility = Visibility.Hidden;
	mikuGuardsPanel.Visibility = Visibility.Hidden;
	timeLeftTip.Visibility = Visibility.Hidden;
end

--销毁
function RoleMiKuInfoPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end	

--显示
function RoleMiKuInfoPanel:Show()
--[[	--向服务器发送统计数据
	local taskID = Task:getMainTaskId();
	if (Task.mainTask ~= nil) and (taskID <= MenuOpenLevel.statistics) then
		local taskItem = resTableManager:GetValue(ResTable.task, tostring(taskID), {LANG_roleMiKuInfoPanel_1,LANG_roleMiKuInfoPanel_2});
		if (1 == taskItem[LANG_roleMiKuInfoPanel_3]) and (self.curBarrierId == taskItem[LANG_roleMiKuInfoPanel_4][1]) then
			NetworkMsg_GodsSenki:SendStatisticsData(taskID, 4);
		end	
	end	--]]
	
	local data = resTableManager:GetRowValue(ResTable.miku, tostring(self.curBarrierId));
	
	labelTitle.Text = data['name'];
	labelExp.Text 	= '+' .. data['exp'];
	labelCoin.Text 	= '+' .. data['coin'];
	labelSoul.Text = '+' .. data['soul'];
	labelPower.Text = '-' .. Configuration.NormalRequestPower;			--显示体力
	
	--boss内容显示
	local roleData = resTableManager:GetValue(ResTable.actor, tostring(data['boss_name']), {'name', 'rare'});
	bossName.Text = roleData['name'];
	bossName.TextColor = QualityColor[roleData['rare']];
	
	bossDesc.Text = data['boss_story'];
	
	--挂机按钮是否显示以及是否可用
	self:RefreshHangUpBtn();
	
	--刷新重置次数
	self:RefreshResetCount();
	
	--挂机时间
	
	--设置模式对话框 
	mainDesktop:DoModal(panel);	

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--对外刷扫荡
function RoleMiKuInfoPanel:RefreshHangUpBtn()
	if Hero:GetLevel() < FunctionOpenLevel.HangUpOpenLevel then
		btnHangUp.Visibility = Visibility.Hidden;
	else
		btnHangUp.Visibility = Visibility.Visible;

		if self.curBarrierId <= ActorManager.user_data.round.caveid then
			btnHangUp.Enable = true;					--可点击
			self:refreshHangUpBtn();
			if cdTimer == 0 then
				cdTimer = timerManager:CreateTimer(1, 'RoleMiKuInfoPanel:refreshHangUpBtn', 0);
			end
		else
			btnHangUp.Enable = false;					--不可点击
			btnHangUp.Text = LANG_roleMiKuInfoPanel_5;
			btnHangUp.Font = uiSystem:FindFont('huakang_20');	
			isHangUp = false;
			timeLeftTip.Visibility = Visibility.Hidden;
			btnHangUpElem.Visibility = Visibility.Hidden;
		end
	end
end

function RoleMiKuInfoPanel:refreshHangUpBtn()
	if LuaTimerManager.pass_cave_left > 0 then
		--btnHangUp.Text = LANG_roleMiKuInfoPanel_6 .. Time2MinSecStr( LuaTimerManager.pass_cave_left );
		--btnHangUp.Font = uiSystem:FindFont('huakang_20');	
		timeLeft.Text = Time2MinSecStr( LuaTimerManager.pass_cave_left );
		timeLeft.Font = uiSystem:FindFont('huakang_20');
		timeLeftTip.Visibility = Visibility.Visible;
		btnHangUpElem.Visibility = Visibility.Visible;
		btnHangUp.Text = '';
		isHangUp = false;
	else
		btnHangUp.Text = LANG_roleMiKuInfoPanel_7;
		btnHangUp.Font = uiSystem:FindFont('huakang_20');	
		isHangUp = true;
		timeLeftTip.Visibility = Visibility.Hidden;
		btnHangUpElem.Visibility = Visibility.Hidden;
	end
end

--隐藏
function RoleMiKuInfoPanel:Hide()
	selectIndex = 0;
	PveBarrierInfoPanel.friendList = {};
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

--刷新重置次数
function RoleMiKuInfoPanel:RefreshResetCount()
	
	local roundData = ActorManager.user_data.round.cave[ tostring(self.curBarrierId) ];
	
	--剩余次数
	lefttimes = Configuration.MikuChangeMaxCount;
	if roundData ~= nil then
		lefttimes = lefttimes - roundData.n_enter;
	end
	labelLeftTimes.Text = tostring(lefttimes);

	--重置次数
	local totalResetTimes = resTableManager:GetValue(ResTable.vip, tostring(ActorManager.user_data.viplevel), 'reset_miku');
	local flushTimes = 0;
	if roundData ~= nil then
		flushTimes = roundData.n_flush;
	end
	
	local text = '重置(' ..
					totalResetTimes - flushTimes ..
					'/'..
					totalResetTimes	.. ')';
	btnReset.Text = text;
end

--========================================================================
--添加助战英雄

function RoleMiKuInfoPanel:addAssistHero(index, friend)
	local itemCell = assistFrientCheckBoxList[index]:GetLogicChild('image');
	local labelName = assistFrientCheckBoxList[index]:GetLogicChild('name');
	local labelLevel = assistFrientCheckBoxList[index]:GetLogicChild('level');
	local labelFs = assistFrientCheckBoxList[index]:GetLogicChild('fs');
	local labelInfo = assistFrientCheckBoxList[index]:GetLogicChild('info');
	local labelType = assistFrientCheckBoxList[index]:GetLogicChild('type');
	
	local icon = resTableManager:GetValue(ResTable.actor, tostring(friend.resid), 'img');
	itemCell.Background = Converter.String2Brush( QualityType[Configuration:getRare(friend.lv)] );
	
	labelName.Text = friend.name;
	labelName.TextColor = QualityColor[Configuration:getRare(friend.lv)];
	labelLevel.Text = 'Lv' .. friend.lv;
	
	if friend.isFriend == false then
		labelFs.Text = '+' .. Configuration.StrangerGetFriendShip;
		labelType.Text = LANG_roleMiKuInfoPanel_8;
	else
		labelFs.Text = '+' .. Configuration.FriendGetFriendShip;
		labelType.Text = LANG_roleMiKuInfoPanel_9;
	end
	
	labelInfo.Visibility = Visibility.Hidden;
	assistFrientCheckBoxList[index].Visibility = Visibility.Visible;
	if 1 == index then
		assistFrientCheckBoxList[index].Checked = true;
		selectIndex = 1;
	else
		assistFrientCheckBoxList[index].Checked = false;
	end
end

--显示助战英雄
function RoleMiKuInfoPanel:showAssistHero()
	--加载助战的好友或者陌生人
	for index,friend in ipairs(PveBarrierInfoPanel.friendList) do	
		self:addAssistHero(index, friend);
	end	
end

--刷新助战英雄
function RoleMiKuInfoPanel:RefreshAssistFriend()
	PveBarrierInfoPanel.friendList = {};
	selectIndex = 0;
	for _,cb in ipairs(assistFrientCheckBoxList) do
		cb.Visibility = Visibility.Hidden;					--隐藏助战英雄checkbox
	end
	
	if FunctionOpenLevel.assist > ActorManager.user_data.role.lvl.level then
		--等级不足，无法开启好友助战
		labelOpenLevel.Visibility = Visibility.Visible;
	else
		labelOpenLevel.Visibility = Visibility.Hidden;
		
		local list = Friend:getSortFriendList();
		for _,friend in ipairs(list) do
			if friend.ishelped == 0 then
				friend.isFriend = true;
				table.insert(PveBarrierInfoPanel.friendList, friend);
				if #PveBarrierInfoPanel.friendList == Configuration.ShowAssistFriendCount then
					break;
				end	
			end
		end

		--判断可助战好友数是否达到上限
		if #PveBarrierInfoPanel.friendList < Configuration.ShowAssistFriendCount then	
			if Friend.isRemain then
				local msg = {};
				msg.page = Friend.page;
				Network:Send(NetworkCmdType.req_friend_list, msg, true);
				Friend.isHelpApply = true;									--代表是战斗时候拉好友助战时申请好友列表信息
			else
				--好友已经遍历结束，向服务器申请陌生人信息
				local msg = {};
				msg.count = Configuration.ShowAssistFriendCount - #PveBarrierInfoPanel.friendList;
				Network:Send(NetworkCmdType.req_helphero_stranger, msg, true);
			end
			
		else
			--加载助战的好友或者陌生人
			for index,friend in ipairs(PveBarrierInfoPanel.friendList) do		
				self:addAssistHero(index, friend);
			end	
		end	
	end
end

--是否处于显示状态
function RoleMiKuInfoPanel:IsVisible()
	return Visibility.Visible == panel.Visibility;
end

--========================================================================
--事件

--进入关卡信息界面
function RoleMiKuInfoPanel:onEnterBarrierInfo(barrierID)
	--关卡id
	self.curBarrierId = barrierID;
	
	self:RefreshAssistFriend();	
	
	MainUI:Push(self);	
end

--关闭事件
function RoleMiKuInfoPanel:onClose()
	MainUI:Pop();
end

--挂机事件
function RoleMiKuInfoPanel:onHnagUpClick()
	if ActorManager.user_data.power < Configuration.NormalRequestPower then
		BuyCountPanel:ApplyData(VipBuyType.vop_buy_power);
		BuyCountPanel:SetTitle(LANG_roleMiKuInfoPanel_10);
	elseif lefttimes <= 0 then
		BuyCountPanel:ApplyData(VipBuyType.vop_flush_cave, self.curBarrierId);
		BuyCountPanel:SetTitle(LANG_roleMiKuInfoPanel_11);
	else
		if isHangUp then
			--先销毁现在的二级菜单
			MainUI:Pop();			
			--显示另一个二级菜单
			PveAutoBattlePanel:onEnterMiKuHangUpPanel(self.curBarrierId, lefttimes);
		else
			local okDelegate = Delegate.new(RoleMiKuInfoPanel, RoleMiKuInfoPanel.onSendClearCd);
			MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_roleMiKuInfoPanel_12, okDelegate);
		end
		
	end	
end

--发送消除冷却时间
function RoleMiKuInfoPanel:onSendClearCd()
	Network:Send(NetworkCmdType.req_cave_pass_clear_cd, {});
end

--挑战事件
function RoleMiKuInfoPanel:onChallengeClick()
	--向服务器发送统计数据
--[[	if (Task.mainTask ~= nil) and (Task.mainTask['id'] <= MenuOpenLevel.statistics) then
		local taskItem = resTableManager:GetValue(ResTable.task, tostring(Task.mainTask['id']), {'type','value'});
		if (1 == taskItem['type']) and (self.curBarrierId == taskItem['value'][1]) then
			NetworkMsg_GodsSenki:SendStatisticsData(Task.mainTask['id'], 5);
		end	
	end	--]]
	
	if ActorManager.user_data.power < needPower then
		BuyCountPanel:ApplyData(VipBuyType.vop_buy_power);
		BuyCountPanel:SetTitle(LANG_roleMiKuInfoPanel_13);
	elseif lefttimes <= 0 then
		BuyCountPanel:ApplyData(VipBuyType.vop_flush_cave, self.curBarrierId);
		BuyCountPanel:SetTitle(LANG_roleMiKuInfoPanel_14);
	else
		--请求进入关卡
		if Package:GetAllItemCount() > ActorManager.user_data.bagn - Configuration.WarningPackageCount then
			local okdelegate = Delegate.new(RoleMiKuInfoPanel, RoleMiKuInfoPanel.requestFight, 0);
			MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_roleMiKuInfoPanel_15, okdelegate);
		else
			self:requestFight();
		end	
	end
end

--进入战斗
function RoleMiKuInfoPanel:requestFight()
	local msg = {};
	msg.resid = self.curBarrierId;
	if (0 == selectIndex) or (0 == #PveBarrierInfoPanel.friendList) then
		msg.uid = 0;
		msg.pid = 0;
		Friend.helpFriend = nil;				--无助战好友
	else
		local friend = PveBarrierInfoPanel.friendList[selectIndex];
		msg.uid = friend.uid;
		msg.pid = friend.pid;	
		if friend.isFriend then			--保存助战好友
			Friend.helpFriend = friend;
		else
			FightOverUIManager:SetStrangerInfo(friend.uid, friend.name, friend.lv);
			Friend.helpFriend = nil;			--无助战好友
		end
	end
	
	Network:Send(NetworkCmdType.req_cave_enter, msg);
	
	Loading.waitMsgNum = 1;
	Game:SwitchState(GameState.loadingState);
	
end	

--接受服务器发送的助战陌生人
function RoleMiKuInfoPanel:onStrangerList(msg)
	for index,friend in ipairs(msg.strs) do
		friend.isFriend = false;
		table.insert(PveBarrierInfoPanel.friendList, friend);		
	end	
	
	self:showAssistHero();
end	

--助战英雄点击事件
function RoleMiKuInfoPanel:onFriendClick(Args)
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

--查看本关卡的掉落
function RoleMiKuInfoPanel:onItemKind()
	mikuGuardsPanel.Visibility = Visibility.Visible;
	mainDesktop.FocusControl = mikuGuardsPanel;
	
	local data = resTableManager:GetValue(ResTable.miku, tostring(self.curBarrierId), 'item_drop');

	local index = 1;
	while index <= 5 do
		if data[index] == nil then
			itemNameList[index].Visibility = Visibility.Hidden;
		else
			local id = data[index][1];
			local itemData = resTableManager:GetValue(ResTable.item, tostring(id), {'name', 'quality'});
			itemNameList[index].Text = itemData['name'];
			itemNameList[index].TextColor = QualityColor[itemData['quality']];
			itemNameList[index].Visibility = Visibility.Visible;
		end
		index = index + 1;
	end
	
	mikuGuardsPanel.Size = Size(236, 70 + 30 * #data);
	
end

--关闭详细信息
function RoleMiKuInfoPanel:onCloseGuardsPanel()
	mikuGuardsPanel.Visibility = Visibility.Hidden;
end

--重置按钮点击事件
function RoleMiKuInfoPanel:onReset()
	local times = resTableManager:GetValue(ResTable.vip, tostring(ActorManager.user_data.viplevel), 'reset_miku');
	local resetCount = 0;
	if ActorManager.user_data.round[ tostring(self.curBarrierId) ] ~= nil then
		resetCount = ActorManager.user_data.round[ tostring(self.curBarrierId) ].n_flush;
	end

	if resetCount >= times then
        MessageBox:ShowDialog(MessageBoxType.Ok, LANG_roleMiKuInfoPanel_16);
	else
		BuyCountPanel:ApplyData(VipBuyType.vop_flush_cave, self.curBarrierId);
	end	
end

--重置按钮点击事件
function RoleMiKuInfoPanel:onResetRequest()
	local msg = {};
	msg.resid = RoleMiKuInfoPanel.curBarrierId;
	
	Network:Send(NetworkCmdType.req_cave_flush, msg);
end
