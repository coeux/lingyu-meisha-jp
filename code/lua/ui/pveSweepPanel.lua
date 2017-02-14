--pveSweepPanel.lua

--========================================================================
--进入pve挂机界面

PveSweepPanel =
	{
	};
	
	
--变量
local curBarrierId		= 0;		--选择进入的关卡id
local maxCount			= 1;		--最大挂机次数
local hangUpResult 		= {};		--挂机结果
local hangUpTimer 		= 0;		--挂机计时器
local hangUpCount		= 0;		--挂机次数

--控件
local mainDesktop;
local panelBg;
local btnAgain;
local btnClose;
local chapterName;
local rewardPanel;
local teamList = {};
local dropList = {};
local panel;
local starList;
	
--初始化
function PveSweepPanel:InitPanel(desktop)
	--变量初始化
	curBarrierId		= 0;		--选择进入的关卡id
	hangUpResult 		= {};		--挂机结果	
	autoBattleType = AutoBattleType.normal;

	--控件初始化
	mainDesktop 		= desktop;
	panel				= Panel(desktop:GetLogicChild('win_pve2'):GetLogicChild('center'));
	panel:IncRefCount();
	panel.Visibility = Visibility.Hidden;	
	panel.ZOrder = PanelZOrder.saodang;
	
	--标题成就个数
	starList = {};
	starList.setNum = function(num)
		for i=1, 4 do
			if i <= num then
				panel:GetLogicChild('starPanel'):GetLogicChild('star' .. i).Visibility = Visibility.Visible;
			else
				panel:GetLogicChild('starPanel'):GetLogicChild('star' .. i).Visibility = Visibility.Hidden;
			end
		end
	end

	--获取经验和金钱
	
	--获取物品
	
	--人物状态
	
	--按钮
	panel:GetLogicChild('btn_sure'):SubscribeScriptedEvent('Button::ClickEvent', 'PveSweepPanel:onSureClick');
	panel:GetLogicChild('btn_reChallenge'):SubscribeScriptedEvent('Button::ClickEvent', 'PveSweepPanel:onReChanllenge');
end

--销毁
function PveSweepPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function PveSweepPanel:Show()
	
	--显示关卡名
	if autoBattleType == AutoBattleType.normal then
		chapterName.Text = resTableManager:GetValue(ResTable.barriers, tostring(curBarrierId), 'name');	
	elseif autoBattleType == AutoBattleType.miku then
		chapterName.Text = resTableManager:GetValue(ResTable.miku, tostring(curBarrierId), 'name');
	else
		chapterName.Text = LANG_pveAutoBattlePanel_1;
	end
	
end

function PveSweepPanel:Hide()
	panel.Visibility = Visibility.Hidden;
end

--进入挂机界面
function PveSweepPanel:onEnterHangUpPanel(barrierId)
	autoBattleType = AutoBattleType.normal;
	curBarrierId = barrierId;
	self:onHangUp();
end

--挂机
function PveSweepPanel:onHangUp()
	if autoBattleType == AutoBattleType.miku then
		--迷窟挂机请求
		local msg = {};
		msg.resid = curBarrierId;
		msg.killed = self:GetAutoBattleKillMonster(curBarrierId);
		Network:Send(NetworkCmdType.req_cave_pass, msg);
	elseif autoBattleType == AutoBattleType.normal then
		--向服务器发送挂机请求
		local msg = {};
		msg.resid = curBarrierId;
		msg.count = 1;
		msg.killed = self:GetAutoBattleKillMonster(curBarrierId);
		Network:Send(NetworkCmdType.req_round_pass_new, msg);
	end
end

--获取关卡怪物id和个数
function PveSweepPanel:GetAutoBattleKillMonster(barrierId)
	local monsterData;
	local bossData;
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
	
	local list = {};
	for resid,num in pairs(killedList) do
		table.insert(list, {resid = tonumber(resid), num = num});
	end
	
	return list;
end

--挂机返回
function PveSweepPanel:onHangUpCallBack(msg)
	if (0 == #msg.results) then
		return;
	end

	hangUpResult = msg.results;									--保存挂机结果
	--Debug.print_var_dump("msg:")
	--Debug.print_var_dump(msg)
end

--========================================================================
--事件

--点击确认按钮
function PveSweepPanel:onSureClick()
	self:Hide();
end

--点击再次扫荡按钮
function PveSweepPanel:onReChanllenge()
end
