--==========================================================================
--新手战斗中的本方角色

Fighter_Novice_Player = class(Fighter);

function Fighter_Novice_Player:constructor(id, resID)
	self.m_level = 1;														--角色等级
	self.m_avatarData:InitPlayerAvatar(true);								--初始化角色形象
	self.m_propertyData:InitPlayerBaseData(true);							--初始化角色基本数据
	self.m_propertyData:InitNovicePlayerFightData();						--初始化新手战斗的战斗数据

	local skillID = resTableManager:GetRowValue(ResTable.tutorial_role, self.resID, 'skill_id');
	self.m_fightSkill = FightSkill.new(self, skillID, 1);
end