--========================================================================
--角色管理类
ActorManager =
{
    globalActorID	= 0;				--全局角色ID
    actorList		= {};				--角色列表
}

--========================================================================

--分配id
function ActorManager:allocActorID()
	self.globalActorID = self.globalActorID + 1;
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
function ActorManager:CreateMFighter( resID, monsterLevel )
	local actor = Fighter_Monster.new( self:allocActorID(), tostring(resID), monsterLevel );
	self.actorList[actor:GetID()] = actor;
	return actor;

end

--销毁角色
function ActorManager:DestroyActor( id )
	self.actorList[id] = nil;
end

--查找角色
function ActorManager:GetActor( id )
	return self.actorList[id];
end


function ActorManager:Update( Elapse )
    for k, v in pairs(self.actorList) do
        v:Update(Elapse);
    end
end
--========================================================================
