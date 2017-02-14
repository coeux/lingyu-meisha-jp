--============================================================================
--战斗者动画数据
FightAvatarData = class();

function FightAvatarData:constructor(actor)
	self.fighter = actor;
	
	self.m_actorForm = nil;					--角色形象名称
	self.m_name = nil;						--角色名
	self.m_avatarPath = nil;      		    --角色形象路径
	self.m_isTombstone = false;				--角色是否已经变成墓碑
	self.m_ZOrder = 0;						--角色图层
end

--初始化玩家角色avatar数据
function FightAvatarData:InitPlayerAvatar(isNoviceBattle)
	local tableid = 0;
	if isNoviceBattle then
		tableid = ResTable.tutorial_role;
	else
		tableid = ResTable.actor;
	end
	local avatarData = resTableManager:GetRowValue(tableid, self.fighter:GetResID());

	self:initPAvatar(avatarData);
end

--加载角色形象
function FightAvatarData:initPAvatar(avatarData)
	self.m_actorForm = avatarData['img'];
	self.m_avatarPath = GlobalData.AnimationPath .. avatarData['path'] .. '/';
	self.m_shadow = avatarData['shadow'];
end

--初始化怪物的avatar数据
function FightAvatarData:InitMonsterAvatar(roundType)
	local avatarData = {};
	if roundType == MonsterRoundType.noviceBattle then
		avatarData = resTableManager:GetRowValue(ResTable.tutorial_role, self.fighter:GetResID());
		self.m_name = avatarData['name'];
		self.m_actorForm = avatarData['img'];
	else
		avatarData = resTableManager:GetRowValue(ResTable.monster, self.fighter:GetResID());
		self.m_name = avatarData['name'];
		self.m_actorForm = avatarData['img'];
	end

	self.m_avatarPath = GlobalData.AnimationPath .. avatarData['path'] .. '/';
	self.m_shadow = avatarData[LANG_fighterAvatarData_1];
end

--加载角色形象
function FightAvatarData:LoadArmature(armatureName)
end

--===============================================================================
--获取avatar属性值
function FightAvatarData:GetActorForm()
	return self.m_actorForm;
end

--获取角色姓名
function FightAvatarData:GetActorName()
	return self.m_name;
end

--获取是否变成墓碑
function FightAvatarData:IsTombstone()
	return self.m_isTombstone;
end

--设置是否变成墓碑
function FightAvatarData:SetTombstone(flag)
	self.m_isTombstone = flag;
end

