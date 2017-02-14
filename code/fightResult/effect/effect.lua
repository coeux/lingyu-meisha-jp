
--========================================================================
--========================================================================
--特效类

Effect = class();


--构造函数
function Effect:constructor( id )

	--========================================================================
	--属性相关
	
	self.id			= id;			--id
	self.runningState	= true;		--特效运行状态
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

--暂停特效更新
function Effect:Pause()
	self.runningState = false;
end

--恢复特效更新
function Effect:Resume()
	self.runningState = true;
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
function TraceEffect:Initialize( attackClassID, startOffsetPos, flightPathType, flyXSpeed, flyYInitSpeed, effectScale, tracerID, tracerAvatarPos, tracerOffsetPos, effectScript )
	local attackClass = FightAttackManager:GetAttackClass(attackClassID);
	local attacker = attackClass:GetAttacker();
	self.dir = 1;
	if attacker:GetDirection() == DirectionType.faceleft then
		self.dir = -1;
	end

	--开始位置
	local position = attacker:GetPosition();
	self.Translate = Vector3(position.x + self.dir * startOffsetPos.x, position.y + startOffsetPos.y, position.z);
	--记录追踪特效的初始位置
	self.startPosition = Vector3(position.x + self.dir * startOffsetPos.x, position.y + startOffsetPos.y, position.z);
	self.lastTime = 0;										--特效飞行时间
	self.attackClassID = attackClassID;
	self.tracerID = tracerID;								--追踪者ID
	self.tracerAvatarPos = tracerAvatarPos;					--追踪者受击位置骨骼
	self.tracerOffsetPos = Vector3(self.dir*tracerOffsetPos.x, tracerOffsetPos.y, 0);	--追踪者受击偏移
	self.isHorizontalTrajectory = isHorizontalTrajectory;	--是否水平轨迹
	self.yAddSpeed = nil;									--y轴方向加速度
	self.xSpeed = flyXSpeed;								--x轴追踪速度
	self.ySpeed = flyYInitSpeed;							--y轴追踪速度
	self.effectScript = effectScript;						--特效脚本

	effectScript:StartWaiting();
end

--更新
function TraceEffect:Update( Elapse )
	if not self.runningState then
		return;
	end
	
	self.lastTime = self.lastTime + Elapse;
	
	local tracer = ActorManager:GetActor(self.tracerID);
	
	if tracer == nil then
		--相当于打到了，脚本继续执行
		self.effectScript:EndWaiting();
	else
		--目标位置
		local targetPos = tracer:GetPosition();
		targetPos = Vector3(targetPos.x + self.tracerOffsetPos.x, targetPos.y + self.tracerOffsetPos.y, 0);
		
		--特效当前位置
		local curPos = self.Translate;

		if ((self.dir == 1) and (curPos.x >= targetPos.x)) or ((self.dir == -1) and (curPos.x <= targetPos.x)) then
			--到达
			self.effectScript:EndWaiting();		--脚本继续执行
			--添加追踪特效飞行时间
			local attackClass = FightAttackManager:GetAttackClass(self.attackClassID);
			if attackClass ~= nil then
				attackClass:GetAttackerSkill():AddExtraTime(self.lastTime);
			end
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
