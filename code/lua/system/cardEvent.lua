CardEvent =
{
	partners = {},
	enemyTeamList = {},
	allyTeamList = {},
	leaveAnger = 0,
	special = false,
}

function CardEvent:init()
	ActorManager.user_data.functions.card_event = 
	listener(ActorManager.user_data.functions.card_event,
	Listener, Listener.CardEvent);
	self.partners = ActorManager.user_data.functions.card_event.partners
	self.allyTeamList = ActorManager.user_data.functions.card_event.team.actors
	__.each(self.allyTeamList, function(at)
		local actor = ActorManager:GetRole(at.pid)
		at.resid = actor.resid
	end)
end

function CardEvent:isOpen()
	local card_event = ActorManager.user_data.functions.card_event
	return card_event.is_open
end

function CardEvent:check()
	if true then
		return
	end
	if self:isOpen() then
		CardEventPosterPanel:Show()
	end
end

function CardEvent:reset()
	__.each(self.partners, function(partner)
		partner.hp = 1.0
	end)
	__.each(self.allyTeamList, function(a)
		a.hp = 1.0
	end)
	return hp
end

function CardEvent:event()
	local event_id = ActorManager.user_data.functions.card_event.event_id
	local data = resTableManager:GetRowValue(ResTable.event, tostring(event_id))
	return data
end

function CardEvent:getEventCard()
	local event_id = ActorManager.user_data.functions.card_event.event_id
	local card_id = resTableManager:GetValue(ResTable.event, tostring(event_id), 'role_id');
	return card_id;
end

function CardEvent:HP(pid)
	local hp = 1
	__.each(self.partners, function(partner)
		if partner.pid == pid then
			hp = partner.hp
		end
	end)
	return hp
end

function CardEvent:AllyHP(resid)
	local hp = 0
	__.each(self.allyTeamList, function(a)
		if a.resid == resid then
			hp = a.hp
		end
	end)
	return hp
end

function CardEvent:EnemyHP(resid)
	local hp = 0
	__.each(self.enemyTeamList, function(e)
		if e.resid == resid then
			hp = e.hp
		end
	end)
	return hp;
end

function CardEvent:FightOver()
	for _, actor in pairs(self.enemyTeamList) do
		actor.hp = 0
	end
	for _, actor in pairs(self.allyTeamList) do
		actor.hp = 0
	end
end

function CardEvent:checkAddPartner(pid, hp)
	local find = false;
	for _,actor in pairs(self.partners) do
		if actor.pid == pid then
			find = true;
			break;
		end
	end

	if not find then
		table.insert(self.partners, {pid = pid, hp = hp});
	end
end

function CardEvent:SetAllyHP(pid, hp)
	for _, actor in pairs(self.partners) do
		if actor.pid == pid then
			actor.hp = hp
			break
		end
	end
end

function CardEvent:Revive(msg)
	__.each(self.allyTeamList, function(a)
		if a.pid == msg.pid then
			a.hp = 1.0
			return
		end
	end)
	local partners = ActorManager.user_data.functions.card_event.partners
	for _, actor in pairs(partners) do
		if actor.pid == msg.pid then
			actor.hp = 1.0
			break
		end
	end
	SelectActorPanel:retCardEventRevive(msg.pid)
end

function CardEvent:reqExitCardEvent(is_win)
	local msg = {}
	msg.is_win = is_win and 1 or 0
	msg.anger = self.leaveAnger

	msg.enemy = {}
	for _, actor in pairs(self.enemyTeamList) do
		table.insert(msg.enemy, {
			pid = actor.pid, hp = (actor.hp - actor.hp % 0.0001)
		})
	end

	msg.ally = {}
	for _, actor in pairs(self.allyTeamList) do
		local hp = actor.hp - actor.hp % 0.0001
		actor.hp = hp;
		self:SetAllyHP(actor.pid, hp) --[[ 更新本地伙伴血量 ]]
		table.insert(msg.ally, {pid = actor.pid, hp = hp})
	end

	Network:Send(NetworkCmdType.req_card_event_round_exit_t, msg)
end

function CardEvent:getDate()
	local cardEvent = ActorManager.user_data.functions.card_event;
	return cardEvent.begin_month or '99',
	cardEvent.begin_day or '99',
	cardEvent.begin_hour or '99',
	cardEvent.end_month or '99',
	cardEvent.end_day or '99',
	cardEvent.end_hour or '99';
end

function CardEvent:is_close()
	return ActorManager.user_data.functions.card_event.is_close;
end

function CardEvent:getMaxLevel()
	local round_max = ActorManager.user_data.functions.card_event.round_max;
	local lvNum = resTableManager:GetRowNum(ResTable.event_difficulty);
	local maxLv = 1;
	for i=lvNum,2,-1 do
		local data = resTableManager:GetRowValue(ResTable.event_difficulty, tostring(i));
		local dataPre = resTableManager:GetRowValue(ResTable.event_difficulty, tostring(i-1));
		local isLegal = true; --后面来分层使得难度有大的阶梯
		if round_max == data['max_round'] then
			maxLv = i;
			break;
		elseif (round_max < data['max_round'] and round_max >= dataPre['max_round']) and isLegal then
			maxLv = i;
			break;
		end
	end
	if maxLv < Configuration.CardEventMinOpenLv then
		maxLv = Configuration.CardEventMinOpenLv;
	end
	return maxLv;
end

function CardEvent:getIsPass(difficult)
	local temp_digit = ActorManager.user_data.functions.card_event.difficult or 0;
	local res = 0;
	for i=1, difficult do
		res = temp_digit % 2;
		temp_digit = (temp_digit - res) / 2;
	end
	return (res == 1);
end

function CardEvent:updateDifficult()
	local max_round = ActorManager.user_data.functions.card_event.round_max;
	local temp_digit = ActorManager.user_data.functions.card_event.difficult or 0;
	local aim = math.floor((max_round % 1000)/100)+1;
	print(ActorManager.user_data.functions.card_event.difficult);
	if aim == 1 then
		ActorManager.user_data.functions.card_event.difficult = math.floor(temp_digit / 2)*2 + 1;
	else
		local aim_pre = 2 ^ (aim-1);
		local aim_next = 2 ^ (aim+1);
		ActorManager.user_data.functions.card_event.difficult = (temp_digit % aim_pre) + (2^(aim-1)) + math.floor(temp_digit/aim_next)*aim_next;
	end
	print(ActorManager.user_data.functions.card_event.difficult);
end
function CardEvent:retSweep(msg)
	--print('start_round->'..tostring(msg.start_round));
	--print('end_round->'..tostring(msg.end_round));
	--print('score->'..tostring(msg.score));
	if msg.end_round then
		ActorManager.user_data.functions.card_event.round = msg.end_round+1;
	end
	CardEventPanel:showSweepPanel(msg)
end
function CardEvent:retNextRound(msg)
	ActorManager.user_data.functions.card_event.round_max = msg.max_round;
	ActorManager.user_data.functions.card_event.next_count = msg.next_count;
	CardEventPanel:retNextRound(msg.goal_level);
end
function CardEvent:retFirstEnter(msg)
	CardEventPanel:retFirstEnter(msg);
end
function CardEvent:change_state(msg)
	ActorManager.user_data.functions.card_event.is_close = (msg.state == 0);
	MenuPanel:UpdateEventPanel();
end
