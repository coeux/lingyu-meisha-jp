--pveAutoBattlePanel.lua

--========================================================================
--进入pve挂机界面

PveAutoBattlePanel =
	{
		count			= 1;		--选择的挂机次数
	};

--变量
local curBarrierId		= 0;		--选择进入的关卡id
local maxCount			= 1;		--最大挂机次数
local hangUpResult 		= {};		--挂机结果
local hangUpTimer 		= 0;		--挂机计时器
local hangUpCount		= 0;		--挂机次数
local autoBattleType	= AutoBattleType.normal;			--挂机类型

--控件
local mainDesktop;
local panel;
local brushElement;
local labelTitle;
local labelConsumePower;
local labelCount;
local btnClose;
local btnMinus;
local btnAdd;
local btnMaxCount;
local btnHangUp;

--初始化
function PveAutoBattlePanel:InitPanel(desktop)
	--变量初始化
	self.count			= 1;		--选择的挂机次数
	curBarrierId		= 0;		--选择进入的关卡id
	maxCount			= 1;		--最大挂机次数
	hangUpResult 		= {};		--挂机结果

	--控件初始化
	mainDesktop 		= desktop;
	panel				= Panel(desktop:GetLogicChild('pveGuaJiPanel'));
	panel:IncRefCount();
	brushElement		= BrushElement(panel:GetLogicChild('configure'));
	labelTitle			= Label(panel:GetLogicChild('guanQianName'));
	labelConsumePower	= Label(panel:GetLogicChild('xiaohao'));
	labelCount			= Label(panel:GetLogicChild('cishu'));
	btnClose			= Button(panel:GetLogicChild('close'));
	btnMinus			= Button(brushElement:GetLogicChild('minus'));
	btnAdd				= Button(brushElement:GetLogicChild('add'));
	btnMaxCount			= Button(brushElement:GetLogicChild('maxCount'));
	btnHangUp			= Button(panel:GetLogicChild('hangUp'));

	panel.Visibility = Visibility.Hidden;

end


--销毁
function PveAutoBattlePanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end


--显示
function PveAutoBattlePanel:Show()

	--显示关卡名
	if autoBattleType == AutoBattleType.normal then
		labelTitle.Text = resTableManager:GetValue(ResTable.barriers, tostring(curBarrierId), 'name');
	elseif autoBattleType == AutoBattleType.miku then
		labelTitle.Text = resTableManager:GetValue(ResTable.miku, tostring(curBarrierId), 'name');
	else
		labelTitle.Text = LANG_pveAutoBattlePanel_1;
	end

	--初始化显示
	labelCount.Text = tostring(self.count);
	labelConsumePower.Text = tostring(Configuration.NormalRequestPower * self.count);

	--设置模式对话框
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end


--隐藏
function PveAutoBattlePanel:Hide()
	--取消模式对话框
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
end

--==============================================================================
--功能
--获取关卡怪物id和个数
function PveAutoBattlePanel:GetAutoBattleKillMonster(barrierId)
	local monsterData = resTableManager:GetValue(ResTable.barriers, tostring(barrierId), {'initial_monster', 'monster'});
	local bossData = resTableManager:GetValue(ResTable.barriers, tostring(barrierId), {'initial_boss', 'boss'});
	local killedList = {};

	if autoBattleType == AutoBattleType.normal then
		monsterData = resTableManager:GetValue(ResTable.barriers, tostring(barrierId), {'initial_monster', 'monster'});
		bossData = resTableManager:GetValue(ResTable.barriers, tostring(barrierId), {'initial_boss', 'boss'});
	elseif autoBattleType == AutoBattleType.miku then
		monsterData = resTableManager:GetValue(ResTable.miku, tostring(barrierId), {'initial_monster', 'monster'});
		bossData = resTableManager:GetValue(ResTable.miku, tostring(barrierId), {'initial_boss', 'boss'});
	end

	for _,dataItem in pairs(monsterData) do
		if dataItem ~= nil then
			for _,item in ipairs(dataItem) do
				if killedList[item[1]] == nil then
					killedList[item[1]] = 1;
				else
					killedList[item[1]] = killedList[item[1]] + 1;
				end
			end
		end
	end

	for _,dataItem in pairs(bossData) do
		if dataItem ~= nil then
			if killedList[dataItem[1]] == nil then
				killedList[dataItem[1]] = 1;
			else
				killedList[dataItem[1]] = killedList[dataItem[1]] + 1;
			end
		end
	end

	local list = {{resid = 0, num = 0}};
	for resid,num in pairs(killedList) do
		table.insert(list, {resid = tonumber(resid), num = num});
	end

	return list;
end

--==============================================================================
--事件

--进入挂机界面
function PveAutoBattlePanel:onEnterHangUpPanel(barrierId)
	autoBattleType = AutoBattleType.normal;
	curBarrierId = barrierId;
	self.count = 1;
	maxCount = Math.Floor(CheckDiv(ActorManager.user_data.power / Configuration.NormalRequestPower));
	MainUI:Push(self);
end

--进入迷窟挂机界面
function PveAutoBattlePanel:onEnterMiKuHangUpPanel( barrierId, totalCount )
	autoBattleType = AutoBattleType.miku;
	curBarrierId = barrierId;
	self.count = 1;
	maxCount = totalCount;
	if maxCount > Math.Floor(CheckDiv(ActorManager.user_data.power / Configuration.NormalRequestPower)) then
           maxCount = Math.Floor(CheckDiv(ActorManager.user_data.power / Configuration.NormalRequestPower));
	end
	MainUI:Push(self);
end

--挂机
function PveAutoBattlePanel:onHangUp()
	MainUI:Pop();

	if autoBattleType == AutoBattleType.miku then
		--迷窟挂机请求
		local msg = {};
		msg.resid = curBarrierId;
		msg.count = self.count;
		msg.killed = self:GetAutoBattleKillMonster(curBarrierId);
		Network:Send(NetworkCmdType.req_cave_pass, msg);
	elseif autoBattleType == AutoBattleType.normal then
		--向服务器发送挂机请求
		local msg = {};
		msg.resid = curBarrierId;
		msg.count = self.count;
		msg.killed = self:GetAutoBattleKillMonster(curBarrierId);
		Network:Send(NetworkCmdType.req_round_pass_new, msg);
	end
end

--挂机返回
function PveAutoBattlePanel:onHangUpCallBack(msg)
	if (0 == #msg.results) then
		return;
	end

	hangUpResult = msg.results;									--保存挂机结果

	if autoBattleType == AutoBattleType.normal then
		AutoBattleInfoPanel:onEnterPveAutoBattleInfoPanel(msg.resid);		--打开Pve挂机信息界面
	elseif autoBattleType == AutoBattleType.miku then
		AutoBattleInfoPanel:onEnterMikuAutoBattleInfoPanel(msg.resid);		--打开迷窟挂机信息界面
		if ActorManager.user_data.round.cave[ tostring(msg.resid) ] == nil then
			ActorManager.user_data.round.cave[ tostring(msg.resid) ] = { n_enter = 0; n_flush = 0; };
		end
		local caveData = ActorManager.user_data.round.cave[ tostring(msg.resid) ];
		caveData.n_enter = caveData.n_enter + #hangUpResult;
	end


	hangUpCount = 0;
	if (0 == hangUpTimer) then
		hangUpTimer = timerManager:CreateTimer(0.4, 'PveAutoBattlePanel:addHangUpResult', 0);
	end
end

--添加十二宫快速扫荡的关卡结果
function PveAutoBattlePanel:addHangUpResult()
	hangUpCount = hangUpCount + 1;
	AutoBattleInfoPanel:onAddPveAutoBattleInfo(hangUpResult[1], hangUpCount);
	table.remove(hangUpResult, 1);

	if (0 == #hangUpResult) then				--结束，删除计时器
		timerManager:DestroyTimer(hangUpTimer);
		hangUpTimer = 0;

		AutoBattleInfoPanel:SetOkPick();			--挂机界面ok按钮可点击
	end
end


--关闭
function PveAutoBattlePanel:onPveAutoBattlePanelClose()
	MainUI:Pop();

	if autoBattleType == AutoBattleType.miku then
		--迷窟挂机
		MainUI:Push(RoleMiKuInfoPanel);
		RoleMiKuInfoPanel:RefreshAssistFriend();
	elseif autoBattleType == AutoBattleType.normal then
		MainUI:Push(PveBarrierInfoPanel);
		PveBarrierInfoPanel:RefreshAssistFriend();
	end
end

--增加次数
function PveAutoBattlePanel:onAddHangUpTimes()
	if self.count < math.min(maxCount, 10) then
		self.count = self.count + 1;
		self:changeShowInfo();
	end
end


--减少次数
function PveAutoBattlePanel:onMinusHangUpTimes()
	if self.count > 1 then
		self.count = self.count - 1;
		self:changeShowInfo();
	end
end


--最大次数
function PveAutoBattlePanel:onMaxHangUpTimes()
	self.count = math.min(maxCount, 10);
	self:changeShowInfo();
end


--更改显示
function PveAutoBattlePanel:changeShowInfo()
	labelCount.Text = tostring(self.count);
	labelConsumePower.Text = tostring(Configuration.NormalRequestPower*self.count);
end
