--========================================================================
--角色管理类
ActorManager =
	{
		globalActorID	= 900;				--全局角色ID
		actorList		= {};				--角色列表
	}

--更新
function ActorManager:Update( Elapse )
	
	--更新动画
	for k, v in pairs(self.actorList) do
		v:Update(Elapse);
	end

end

--========================================================================

--分配id
function ActorManager:allocActorID()
	self.globalActorID = self.globalActorID + 1;
	if self.globalActorID >= 1000 then
		self.globalActorID = 900;
	end

	return self.globalActorID;
end

--========================================================================
--角色管理

--创建战斗者(英雄)
function ActorManager:CreatePFighter( resID )

	local actor = Fighter_Player.new( self:allocActorID(), tostring(resID) );
	self.actorList[actor:GetID()] = actor;
	return actor;

end

--创建战斗者(怪物)
function ActorManager:CreateMFighter( resID, monsterData )

	local actor = Fighter_Monster.new( self:allocActorID(), tostring(resID), monsterData );
	self.actorList[actor:GetID()] = actor;
	return actor;

end

--创建怪物Boss
function ActorManager:CreateBFigher( resID, monsterData)
	
	local actor = Fighter_Boss.new( self:allocActorID(), tostring(resID), monsterData );
	self.actorList[actor:GetID()] = actor;
	return actor;
	
end

--销毁角色
function ActorManager:DestroyActor( id )
	self.actorList[id] = nil;
end

--删除所有角色
function ActorManager:DestroyAllActor()
	self.actorList = {};
	self.globalActorID	= 900;				--全局角色ID
end

--查找角色
function ActorManager:GetActor( id )
	return self.actorList[id];
end

function ActorManager:AdjustRoleSkill( role )
	table.sort(role.skls, function (s1, s2)
		return s1.resid < s2.resid;
	end);
end