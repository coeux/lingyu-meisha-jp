--tipflag.lua
--===============================
--提示类


TipFlag = {
	RoleEquipTip 	= false,
	RoleSkillTip 	= false,
	RoleRankUpTip 	= false,
	RoleLoveTip 	= false,

};

TipIndex = {
	Equip 	= 1,
	Skill 	= 2,
	Rankup 	= 3;
	Lovetip = 4;
}

--更新技能标志位状态
function TipFlag:UpdateFlagSkill(flag)
	TipFlag.RoleSkillTip = flag;
	TipFlag:UpdateHomeTipFlag();
end

--更新爱恋标志位状态
function TipFlag:UpdateFlagLove(flag)
	TipFlag.RoleLoveTip = flag;
	TipFlag:UpdateHomeTipFlag();
end

--更新装备标志位状态
function TipFlag:UpdateFlagEquip(flag)
	TipFlag.RoleEquipTip = flag;
	TipFlag:UpdateHomeTipFlag();
end

--更新角色进阶标志位状态
function TipFlag:UpdateFlagRankUp(flag)
	TipFlag.RoleRankUpTip = flag;
	TipFlag:UpdateHomeTipFlag();
end

--刷新家界面红点状态标志位状态
function TipFlag:UpdateHomeTipFlag()
	if self.RoleEquipTip or self.RoleSkillTip or self.RoleRankUpTip or self.RoleLoveTip or self.RoleRankUpTip then
		MenuPanel:HomeTips(true);
	else
		MenuPanel:HomeTips(false);
	end
end




