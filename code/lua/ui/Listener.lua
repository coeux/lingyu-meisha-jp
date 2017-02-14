--Listener.lua
--==============================================================================
--通用Listener接口(少用本文件，会影响性能)
Listener =
{
};

--ActorManager.user_data.chronicle
function Listener:Chronicle(k, v)
  if k == 'is_sign' then
    TipFlag:UpdateFlagLove(not v)
    -- HomePanel:ChronicleTips(v)	--编年史不显示
  end
end

--ActorManager.user_data.round
function Listener:Round(k, v)
  if k == 'n_rob' then
    TreasurePanel:onTimes(v)
  elseif k == 'profit' then
    TreasurePanel:onGold(v)
  end
end

--ActorManager.user_data.functions.card_event
function Listener:CardEvent(k, v)
  if k == 'score' then
    CardEventPanel:setScore(v)
  elseif k == 'coin' then
    CardEventPanel:setCoin(v)
  elseif k == 'rank' then
    CardEventPanel:setRank(v)
  elseif k == 'round' then
    --CardEventPanel:setRound(v)
  elseif k == 'goal_level' then
    CardEventPanel:setGoalLevel(v)
  elseif k == 'open_times' then
	CardEventPanel:setOpen(v);
  end
end

--ActorManager.user_data.functions.combo_pro
function Listener:ComboPro(k, v)
	if k == 'c1_level' then
		ComboPro.c1_level = v;
	elseif k == 'c2_level' then
		ComboPro.c2_level = v;
	elseif k == 'c3_level' then
		ComboPro.c3_level = v;
	elseif k == 'c4_level' then
		ComboPro.c4_level = v;
	elseif k == 'c5_level' then
		ComboPro.c5_level = v;
	elseif k == 'c1_exp' then
		ComboPro.c1_exp = v
	elseif k == 'c2_exp' then
		ComboPro.c2_exp = v
	elseif k == 'c3_exp' then
		ComboPro.c3_exp = v
	elseif k == 'c4_exp' then
		ComboPro.c4_exp = v
	elseif k == 'c5_exp' then
		ComboPro.c5_exp = v
	end
	ComboPro:reGenAttribute();
end
	
--==============================================================================
