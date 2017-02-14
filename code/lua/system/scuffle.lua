-- scuffle.lua
-- ============================================
Scuffle =
{
}

function Scuffle:Init()
	self.allyTeam = {};
	self.enemyTeam = {};
end

function Scuffle:SetAllyHP(team)
	self.allyTeam = {};
	for _, partner in pairs(team) do
		self.allyTeam[partner.pid] = {pid = partner.pid, hp = partner.hp};
	end
end

function Scuffle:GetAllyHP(pid)
	if self.allyTeam[pid] then
		return self.allyTeam[pid].hp;
	end
	return 1;
end

function Scuffle:SetEnemyHP(team)
	self.enemyTeam = {};
	for _, partner in pairs(team) do
		self.enemyTeam[partner.pid] = {pid = partner.pid, hp = partner.hp};
	end
end

function Scuffle:GetEnemyHP(pid)
	if self.enemyTeam[pid] then
		return self.enemyTeam[pid].hp;
	end
	return 1;
end

function Scuffle:updateAllyHp(allyTeam)
	for _, actor in pairs(self.allyTeam) do
		actor.mark = false;
	end
	for _,actor in pairs(allyTeam) do
		local hp = CheckDiv(actor:GetCurrentHP() / actor:GetMaxHP());
		self.allyTeam[actor.pid].hp = hp - hp % 0.0001;
		self.allyTeam[actor.pid].mark = true;
	end
	for _, actor in pairs(self.allyTeam) do
		if not actor.mark then
			actor.hp = 0;
		end
	end
end

function Scuffle:getFinalHp(team)
	for _,actor in pairs(self.allyTeam) do
		table.insert(team, {pid = actor.pid, hp = actor.hp});
	end
end

