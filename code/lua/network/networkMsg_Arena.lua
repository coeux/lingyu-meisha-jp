--networkMsg_Arena.lua

--======================================================================
--竞技场

NetworkMsg_Arena = 
  {
  };

--获取排名奖励信息
function NetworkMsg_Arena:onRankRewardInfo(msg)
  -- none
end  

--领取竞技场奖励
function NetworkMsg_Arena:onGetRankReward(msg)
  -- none
end  

--返回竞技场信息
function NetworkMsg_Arena:onArenaInfo(msg)
  ArenaPanel.flag = msg.flag;
  ArenaPanel:onShowArena(msg);
end

function NetworkMsg_Arena:onEndArenaPvP(msg)
  print("arena fight end!!!!!!!!!!!!!!!")
  local goodsList = {};
  if msg.honor and msg.honor > 0 then
    goodsList[1] = {};
	if ArenaPanel.flag == 0 then
		goodsList[1].resid = 10010;
	elseif ArenaPanel.flag == 1 then
		goodsList[1].resid = 16013;
	end
    goodsList[1].num = msg.honor;
  end
  if msg.meritorious and msg.meritorious > 0 then
    goodsList[2] = {};
    goodsList[2].resid = 10002;
    goodsList[2].num = msg.meritorious;
  end
  PvpWinPanel:setGoodsList(goodsList);
  PvpLosePanel:setGoodsList(goodsList);
end

--竞技场战斗
function NetworkMsg_Arena:onEnterArenaPvP(msg)
  ArenaPanel:ReStartTimer(msg.time);
  _G['salt#arena'] = msg.salt;
  NetworkMsg_Fight:onEnterBackstagePvP(FightType.arena, msg.target_data, msg.is_win, {money = msg.money; battlexp = msg.battlexp; honor = msg.honor});
end

--获取竞技场排名
function NetworkMsg_Arena:onGetArenaRank(msg)
  SkillPanel:RefreshArenaRank(msg.rank);
end

--获取竞技场冷却时间
function NetworkMsg_Arena:onGetCoolDown(msg)
  LuaTimerManager.fightArenaCDTime = msg.time
  ArenaPanel.remainTimes = msg.fight_count
end

--挑战的人正在打别人
function NetworkMsg_Arena:in_fight(msg)
	local okDelegate = Delegate.new(Loading, Loading.realLoadingQuit, 0);
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_1605, okDelegate);
end

