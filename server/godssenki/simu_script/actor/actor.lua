--========================================================================
--角色类

Actor = class();


function Actor:constructor( id, resID )

	--========================================================================
	--属性相关
	
	self.id				= id;						--ID
	self.resID 			= resID;					--角色ID
	self.job			= JobType.warrior;			--职业
	self.jobName		= nil;						--职业名
	self.sex			= SexType.boy;				--性别
	
	self.faceDir		= DirectionType.faceright;	--朝向
	
	--========================================================================

end

--销毁
function Actor:Destroy()
	ActorManager:DestroyActor( self:GetID() );
end

--更新
function Actor:Update( Elapse )
end

--========================================================================
--属性

--id
function Actor:GetID()
	return self.id;
end

--resID
function Actor:GetResID()
	return self.resID;
end

--名字
function Actor:GetName()
	return self.name;
end

function Actor:SetName( name )
	self.Name = name;
end

--设置朝向
function Actor:SetDirection( dir )

	if self.faceDir == dir then
		return;
	end
	
	self.faceDir = dir;
end

--获取朝向
function Actor:GetDirection()
	return self.faceDir;
end
