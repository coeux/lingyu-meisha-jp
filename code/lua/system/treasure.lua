--treasure.lua
--========================================================================
Treasure =
{
	is_help = false; -- 和协守者战斗是否胜利
	leaveHp = {};
	target_data = nil;
	isRobFight = false;
}

function Treasure:updateTreasureHp()
	self.leaveHp = {};
	if FightManager.result == Victory.left then
		for _, actor in pairs(FightManager.leftActorList) do
                   table.insert(self.leaveHp, {resid = actor.resID, hp = CheckDiv(actor:GetCurrentHP() / actor:GetMaxHP())});
		end
	end
end

function Treasure:setHp(actor, role)
	for _, lhp in pairs(self.leaveHp) do
		if tonumber(actor.resID) == tonumber(lhp.resid) then
			local tmp = (lhp.hp + 0.30) > 1 and 1 or (lhp.hp + 0.30);
			actor.m_propertyData:SetCurrentHP(actor.m_propertyData.m_maxHP * tmp);
			return;
		end
	end
end
