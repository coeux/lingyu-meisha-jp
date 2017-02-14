--expedition.lua
--========================================================================
Expedition =
{
	partners = {};
	enemyTeamList = {}; -- ok
	allyTeamList = {}; -- ok
	leaveAnger = 0;
};

function Expedition:Init()
	self.partners = {};
	self.leaveAnger = 0;
  Network:Send(NetworkCmdType.req_expedition_t, {});
	Network:Send(NetworkCmdType.req_expedition_partners_t, {});
end

function Expedition:onHandlePartners(msg)
  self.partners = {};
	self.partners = msg.partners;
end

function Expedition:HP(pid)
	local hp = 1;
	__.each(self.partners, function(partner)
		if partner.pid == pid then
			hp = partner.hp;
		end
	end);
	return hp;
end

function Expedition:EnemyHP(resid)
	local hp = 0;
	__.each(self.enemyTeamList, function(e)
		if e.resid == resid then
			hp = e.hp;
		end
	end);
	return hp;
end

function Expedition:AllyHP(resid)
	local hp = 0;
	__.each(self.allyTeamList, function(a)
		if a.resid == resid then
			hp = a.hp;
		end
	end);
	return hp;
end

function Expedition:FightOver()
	for _, actor in pairs(self.enemyTeamList) do
		actor.hp = 0;
	end
	for _, actor in pairs(self.allyTeamList) do
		actor.hp = 0;
	end
end

function Expedition:reqExitExpedition(is_win)
	local msg = {};
	msg.is_win = is_win and 1 or 0;
	msg.anger = self.leaveAnger;
	msg.enemy = {};
	for _, actor in pairs(self.enemyTeamList) do
		table.insert(msg.enemy, {pid = actor.pid, hp = (actor.hp - actor.hp % 0.0001)});
	end
	msg.ally = {};
	for _, actor in pairs(self.allyTeamList) do
		table.insert(msg.ally, {pid = actor.pid, hp = (actor.hp - actor.hp % 0.0001)});
	end
	msg.salt = _G['salt#expedition'];
	Network:Send(NetworkCmdType.req_exit_expedition_round_t, msg);
end
--========================================================================
