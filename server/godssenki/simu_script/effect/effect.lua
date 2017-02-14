
--========================================================================
--========================================================================
--特效类

Effect = class();


--构造函数
function Effect:constructor( id )

	--========================================================================
	--属性相关
	
	self.id			= id;			--id
	self.effectData	= nil;			--特效数据

	--========================================================================

end

--销毁
function Effect:Destroy()
	self.effectData = nil;
end

--更新
function Effect:Update( Elapse )
end

--id
function Effect:GetID()
	return self.id;
end

--获取特效数据
function Effect:GetEffectData()
	return self.effectData;
end

--设置特效数据
function Effect:SetEffectData( arg )

	self.effectData = arg

	if arg ~= nil then
		arg.Name = tostring(self.id);
	end

end

--获取C++对象
function Effect:GetCppObject()
	return self.effectData;
end	

--========================================================================
--========================================================================
--追踪特效类
TraceEffect = class(Effect);

--销毁
function TraceEffect:Destroy()

	--父类销毁
	Effect.Destroy(self);

end

--追踪者id
function TraceEffect:Initialize( actorID, startOffsetPos, isHorizontalTrajectory, flyXSpeed, flyYInitSpeed, effectScale, tracerID, tracerAvatarPos, tracerOffsetPos, effectScript )

	local attacker = ActorManager:GetActor(actorID);
	self.dir = 1;
	if attacker:GetDirection() == DirectionType.faceleft then
		self.dir = -1;
	end

	--开始位置
	local position = attacker:GetPosition();	
	self.Translate = Vector3(position.x + self.dir * startOffsetPos.x, position.y + startOffsetPos.y, position.z);
	--记录追踪特效的初始位置
	self.startPosition = Vector3(position.x + self.dir * startOffsetPos.x, position.y + startOffsetPos.y, position.z);	
	self.tracerID = tracerID;								--追踪者ID
	self.tracerAvatarPos = tracerAvatarPos;					--追踪者受击位置骨骼
	self.tracerOffsetPos = Vector3(self.dir*tracerOffsetPos.x, tracerOffsetPos.y, 0);	--追踪者受击偏移
	self.isHorizontalTrajectory = isHorizontalTrajectory;	--是否水平轨迹
	self.xSpeed = flyXSpeed;								--x轴追踪速度
	self.ySpeed = flyYInitSpeed;							--y轴追踪速度
	self.effectScript = effectScript;		--特效脚本	
	self.yAddSpeed = nil;
	
	effectScript:Pause();
end

--更新
function TraceEffect:Update( Elapse )

	local tracer = ActorManager:GetActor(self.tracerID);

	if tracer == nil then
		--相当于打到了，脚本继续执行
		self.effectScript:ContinueNext();
	else
		--目标位置
		local targetPos = tracer:GetPosition();
		targetPos = Vector3(targetPos.x + self.tracerOffsetPos.x, targetPos.y + self.tracerOffsetPos.y, 0);
		
		--特效当前位置
		local curPos = self.Translate;

		if ((self.dir == 1) and (curPos.x >= targetPos.x)) or ((self.dir == -1) and (curPos.x <= targetPos.x)) then
			--到达	
			self.effectScript:ContinueNext();		--脚本继续执行
		else
			
			local xDistance = math.abs(targetPos.x - curPos.x);		--攻击者释放的追踪特效的位置与目标当前位置之间的X距离	
			local leftTime = xDistance / self.xSpeed;					--计算特效运行到目标的总时间						
			self.ySpeed = 0;							
			
			--设置特效位置
			self.Translate = Vector3(curPos.x + Elapse * self.xSpeed * self.dir, curPos.y + Elapse * self.ySpeed, 0);
		end
	end

	--父类更新
	Effect.Update(self, Elapse)

end
