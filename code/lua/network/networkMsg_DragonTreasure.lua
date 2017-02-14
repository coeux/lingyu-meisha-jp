--networkMsg_DragonTreasure.lua

--======================================================================
--训练

NetworkMsg_DragonTreasure = 
{
	pvp_msg = nil;
};
	

--巨龙宝库战斗
local treasureFightTimer = -1;
local treasureFightMsg = {};
function NetworkMsg_DragonTreasure:onTreasureFight( msg )
	_G['salt#treasure'] = msg.salt;
	FightManager:PvePreLoad(msg.resid);
	
	--初始化战斗管理类
	FightManager:Initialize(msg.resid);

	treasureFightMsg = msg;
	treasureFightTimer = timerManager:CreateTimer(0.1, 'NetworkMsg_DragonTreasure:onRealTreasureFight', 0);
	Loading:SetProgress(80);
end

function NetworkMsg_DragonTreasure:onRealTreasureFight()
	if not threadPool:IsThreadFuncFinished() then
		--等待预加载完成
		return;
	end		

	timerManager:DestroyTimer(treasureFightTimer);
	treasureFightTimer = -1;
	
	--初始化所有角色的形象
	FightManager:InitAllFightersAvatar();
	
	FightManager:SetFallingCoin(resTableManager:GetValue(ResTable.treasure, tostring(treasureFightMsg.resid), 'gold'));
	--[[
	if treasureFightMsg.drop ~= 0 then
		FightManager:SetFallingGoods({{resid = treasureFightMsg.drop, num = treasureFightMsg.count}});
	end
	--]]

	Loading:DecWaitNum();
	Loading:SetProgress(90);
end	

--巨龙宝库占领穴位战斗
function NetworkMsg_DragonTreasure:onDragonTreasureGrabSlotPvp(msg)
	self.pvp_msg = msg;
	--进入loading状态
	Loading.waitMsgNum = 1;
	Game:SwitchState(GameState.loadingState);
	Treasure.is_help = false;
	if string.len(msg.help_data) == 0 then
		NetworkMsg_Fight:onEnterBackstagePvP(FightType.treasureGrabBattle, msg.target_data, nil, {});
	else
		Treasure.target_data = msg.target_data;
		NetworkMsg_Fight:onEnterBackstagePvP(FightType.treasureGrabBattle, msg.help_data, nil, {});
		Treasure.is_help = true;
	end
end

--巨龙宝库抢劫战斗
function NetworkMsg_DragonTreasure:onDragonTreasureRobPvp(msg)
	self.pvp_msg = msg;

	--进入loading状态
	Loading.waitMsgNum = 1;
	Game:SwitchState(GameState.loadingState);
	Treasure.is_help = false;
	Treasure.isRobFight = true;
	if string.len(msg.help_data) == 0 then
		NetworkMsg_Fight:onEnterBackstagePvP(FightType.treasureRobBattle, msg.target_data, nil, {});
	else
		Treasure.target_data = msg.target_data;
		NetworkMsg_Fight:onEnterBackstagePvP(FightType.treasureGrabBattle, msg.help_data, nil, {});
		Treasure.is_help = true;
	end
	
	if not Treasure.is_help then
		--抢劫返回抢劫次数就减1，和服务器端同步
		NetworkMsg_Data:onChangeRobTimes();
	end
end

function NetworkMsg_DragonTreasure:onDragonTreasureRobPvpEnd(msg)
	if msg.code == 0 then
		-- NetworkMsg_Data:onChangeRobTimes();
    	TreasurePanel:setRewardCoin(msg.money);
    	PvpWinPanel:setGold(msg.money);
	end
end

function NetworkMsg_DragonTreasure:onDragonTreasureFightPvpEnd(msg)
	if msg.code == 0 then
		--刷新探宝界面右侧拥有者信息
		if msg.pos then
			TreasurePanel:setCurRoundPos(msg.pos)
		end
		TreasurePanel:onGrabFightCallBack(1)
	end
end
