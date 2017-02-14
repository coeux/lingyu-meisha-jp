--fighterAvatarData.lua
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

	self.m_scale = 1;						--缩放比例
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

	--加载角色形象
	AvatarManager:LoadFile(self.m_avatarPath);
	self:LoadArmature(self.m_actorForm);
	self.fighter:SetAnimation(AnimationType.f_idle);

	--设置影子
	-- self.fighter:SetShadow(self.m_shadow);

	--人物按照场景比例进行一定的缩放
	self.fighter:SetScale(GlobalData.ActorFightScale, GlobalData.ActorFightScale);

	--[[ 
	--战斗中不显示翅膀
	local wingid = self.fighter:GetWingID();
	if wingid > 0 then
		self.fighter:SetAnimation(AnimationType.fly_idle)
		self.fighter:AttachWing(wingid);
	end
	--]]
end

--初始化怪物的avatar数据
function FightAvatarData:InitMonsterAvatar(roundType)
	local avatarData = {};
	if roundType == MonsterRoundType.noviceBattle then
		avatarData = resTableManager:GetRowValue(ResTable.tutorial_monster, self.fighter:GetResID());
		self.m_name = avatarData['name'];
		self.m_actorForm = avatarData['img'];
	else
		avatarData = resTableManager:GetRowValue(ResTable.monster, self.fighter:GetResID());
		self.m_name = avatarData['name'];
		self.m_actorForm = avatarData['img'];
		--[[
		if roundType == MonsterRoundType.worldBoss or roundType == MonsterRoundType.unionBoss then
			self.m_name = ' Lv' .. self.fighter.m_level .. ' ' .. self.m_name;
		end
		]]
	end

	self.m_avatarPath = GlobalData.AnimationPath .. avatarData['path'] .. '/';
	self.m_shadow = avatarData['shadow'];	

	--加载角色形象
	AvatarManager:LoadFile(self.m_avatarPath);
	self:LoadArmature(self.m_actorForm);
	self.fighter:SetAnimation(AnimationType.f_idle);
	
	--设置影子
	-- self.fighter:SetShadow(self.m_shadow);

	--人物按照场景比例进行一定的缩放
	if (self.fighter:GetActorType() == ActorType.boss) or (self.fighter:GetActorType() == ActorType.eliteMonster) then
		self.m_scale = avatarData['bodytype'];
		self.fighter:SetScale(self.m_scale * GlobalData.ActorScale, self.m_scale * GlobalData.ActorScale);
		self.fighter:SetShapeScale(self.m_scale);
	else
		self.fighter:SetScale(GlobalData.ActorFightScale, GlobalData.ActorFightScale);
	end
	
end

--加载角色形象
function FightAvatarData:LoadArmature(armatureName)
	self.fighter:GetCppObject():LoadArmature(armatureName);
	self.fighter:GetCppObject():SetScriptAnimationCallback('fighterAnimationEnd', self.fighter:GetID());
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

--获取缩放比例
function FightAvatarData:GetScale()
	return self.m_scale;
end
