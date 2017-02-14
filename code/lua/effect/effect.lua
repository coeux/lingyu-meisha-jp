--effect.lua

--========================================================================
--========================================================================
--特效类

Effect = class();


--构造函数
function Effect:constructor( id )

	--========================================================================
	--属性相关

	self.id				= id;			--id
	self.runningState	= true;			--特效运行状态
	self.effectData		= nil;			--特效数据

	--========================================================================

end

--销毁
function Effect:Destroy()
	self.effectData:DecRefCount();
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
function Effect:SetEffectData( arg, isSaveEffect )

	self.effectData = arg

	if (arg ~= nil) and (isSaveEffect == true) then
		self.effectData:IncRefCount();
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
	if self.effectData ~= nil then
		self.effectData:Pause(false);
	end
end

--恢复特效更新
function Effect:Resume()
	self.runningState = true;
	if self.effectData ~= nil then
		self.effectData:Continue();
	end
end
--========================================================================
--========================================================================
--挂点特效类

AvatarPosEffect = class(Effect)

local playerArmature = nil;
local enemyArmature = nil;

function AvatarPosEffect:SetPlayerEnemyArmature(player, enemy)
	playerArmature = player;
	enemyArmature = enemy;
end

function AvatarPosEffect:GetPlayerArmature()
	return playerArmature;
end

--初始化
function AvatarPosEffect:Initialize( actorID, avatarPos, pos, effectScale, layer )
    if (FightManager.state == FightState.none) then
	--判断是否为UI上展示技能
	if playerArmature == nil or enemyArmature == nil then
	    return;
	end

	--设置成armature
	if actorID > 0 then
	    self.actor = playerArmature;		--释放者
	else
	    self.actor = enemyArmature;			--目标
	end
    else
	self.actor = ActorManager:GetActor(actorID);
    end

    if self.actor == nil then
	Debug.print("AvatarPosEffect:Initialize actor nil");
	return;
    end

    --挂特效
    if (FightManager.state == FightState.none) then
	self.effectData.Translate = Vector2(pos.x, -pos.y);
	self.effectData.ZOrder = layer;
	self.effectData.Scale = Vector2(effectScale, effectScale);
    else
	self.effectData.Translate = Vector3(pos.x, pos.y, 0);
	self.effectData.ZOrder = layer;
	self.effectData.Scale = Vector3(effectScale, effectScale, 1);
	self.effectScale = effectScale;
    end
    self.actor:AttachEffect(avatarPos, self.effectData);

    --播放特效
    self.effectData:SetAnimation('play');
    --Debug.print("AvatarPosEffect:Initialize " .. self.actor.resID .. " x = " .. pos.x .. " y = " .. pos.y );

end

--销毁
function AvatarPosEffect:Destroy()

	if self.actor == nil then
		return;
	end

	--self.actor:GetCppObject():DetachEffect( tostring(self:GetID()) );
	self.actor:DetachEffect( self.effectData );

	--父类销毁
	Effect.Destroy(self);

end

--========================================================================
--buff特效
BuffAvatarPosEffect = class(AvatarPosEffect)

--初始化
function BuffAvatarPosEffect:Initialize( actorID, avatarPos, pos, effectScale, layer )
	AvatarPosEffect.Initialize(self, actorID, avatarPos, pos, effectScale, layer);

	if self.actor == nil then
		return;
	end

	if (self.actor:IsEnemy()) then
		self.effectData.Scale = Vector3(-self.effectScale, self.effectScale, 1);
	end
end

--销毁
function BuffAvatarPosEffect:Destroy()

	if self.actor == nil then
		return;
	end

	--通过名字来删除特效
	self.actor:DetachEffect( self.effectData );

	--父类销毁
	Effect.Destroy(self);

end
--========================================================================
--定点特效
SceneEffect = class(Effect);

--初始化
function SceneEffect:Initialize(posType, posOffset, effectScale, layer)
	local targeter = FightManager:GetOrderedTargeterList(true)[1];
	if nil == targeter then
		return;
	end

	local effectCppObj = self:GetCppObject();
	effectCppObj.Scale = Vector3(effectScale, effectScale, 1);
	effectCppObj.ZOrder = layer + FightZOrderList.shader + 200;
	if SceneEffectPositionType.FirstEnemy == posType then
		--第一个敌方角色位置处播放场景特效
		effectCppObj.Translate = Vector3(targeter:GetPosition().x + posOffset.x, targeter:GetPosition().y + posOffset.y, 0);
	elseif SceneEffectPositionType.TopMiddleScene == posType then
		--屏幕中心上方
		local sceneCamera = FightManager.scene:GetCamera();
		local uiCamera = FightManager.desktop.Camera;
		local scenePos = UIToScenePT(uiCamera, sceneCamera, Vector2(FightManager.desktop.Width/2, 0));
		effectCppObj.Translate = scenePos;
	elseif SceneEffectPositionType.MiddleScene == posType then
		--屏幕中心
		local sceneCamera = FightManager.scene:GetCamera();
		local uiCamera = FightManager.desktop.Camera;
		local scenePos = UIToScenePT(uiCamera, sceneCamera, Vector2(FightManager.desktop.Width/2, FightManager.desktop.Height/2));
		effectCppObj.Translate = scenePos;
	end

	--场景特效直接挂到当前活动场景上
	local scene = SceneManager:GetActiveScene();
	scene:GetRootCppObject():AddChild(effectCppObj);

	--播放特效
	self.effectData:SetAnimation('play');
end

--更新
function SceneEffect:Update(Elapse)
	if not self.runningState then
		return;
	end

	--父类更新
	Effect.Update(self, Elapse);
end

--销毁
function SceneEffect:Destroy()
	--卸载特效
	local scene = SceneManager:GetActiveScene();
	scene:DetachEffect( self:GetCppObject() );
	--父类销毁
	Effect.Destroy(self);
end

--========================================================================
--========================================================================
--追踪特效类
TraceEffect = class(Effect);

--销毁
function TraceEffect:Destroy()

	--卸载特效
	local scene = SceneManager:GetActiveScene();
	scene:DetachEffect( self:GetCppObject() );
  self.effectScript:EndWaiting();

	--父类销毁
	Effect.Destroy(self);

	FightUIManager:destroyTraceItem(self);
	--Debug.print("TraceEffect:Destroy " .. self.id);

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
	local effectCppObj = self:GetCppObject();
	local position = attacker:GetPosition();
	effectCppObj.Scale = Vector3(self.dir * effectScale, effectScale, 1);
	effectCppObj.Translate = Vector3(position.x + self.dir * startOffsetPos.x, position.y + startOffsetPos.y, position.z);
	effectCppObj.ZOrder = attacker:GetZOrder();

	--Debug.print("startPosition " .. tostring(position.x + self.dir * startOffsetPos.x) .. " " .. tostring(position.y + startOffsetPos.y) .. " " .. tostring(position.z));
	--追踪特效直接挂到当前活动场景上
	local scene = SceneManager:GetActiveScene();
	scene:AttachEffect(effectCppObj);

	self.lastTime = 0;										--特效飞行时间
	self.attackClassID = attackClassID;
	self.tracerID = tracerID;								--追踪者ID
	self.ZOrder = attacker:GetZOrder();
	self.tracerAvatarPos = tracerAvatarPos;					--追踪者受击位置骨骼
	self.tracerOffsetPos = Vector3(self.dir*tracerOffsetPos.x, tracerOffsetPos.y, 0);	--追踪者受击偏移
	self.flightPathType = flightPathType;					--是否水平轨迹

	--初始状态
	self.startPosition = Vector3(position.x + self.dir * startOffsetPos.x, position.y + startOffsetPos.y, position.z);
	self.xSpeed = flyXSpeed;								--x轴追踪速度
	if FlightPathType.StraightLine == flightPathType then
		self.ySpeed = nil;									--设置y轴初始速度为空
	else
		self.ySpeed = flyYInitSpeed;						--y轴追踪速度
	end

	--特效脚本
	self.effectScript = effectScript;
	effectScript:StartWaiting();

	--播放特效
	self.effectData:SetAnimation('play');
	self.effectData.Visibility = Visibility.Hidden;

	--Debug.print("StartWaiting: SetAnimation Play and Update");
	self:Update(0);
end

--更新
function TraceEffect:Update( Elapse )
	if debugtracemode then
	    FightUIManager:updateTraceItem(self)
	end

	if not self.runningState then
		return;
	end

	self.lastTime = self.lastTime + Elapse;

	local tracer = ActorManager:GetActor(self.tracerID);
	self:GetCppObject().Visibility = Visibility.Visible;


	if tracer == nil then
		--相当于打到了，脚本继续执行
		Debug.print("Tracer nil EndWaiting");
		self.effectScript:EndWaiting();

		local attackClass = FightAttackManager:GetAttackClass(self.attackClassID);
		if attackClass ~= nil then
			self:AddDisappearEffect(self:GetCppObject(), attackClass:GetAttackerSkill(), attackClass:GetAttacker());
		end
	else
		--目标位置
		local targetPos = tracer:GetBoneAbsPos( self.tracerAvatarPos );
		targetPos = Vector3(targetPos.x + self.tracerOffsetPos.x, targetPos.y + self.tracerOffsetPos.y, 0);

		local nextPosition = nil;
		local angle = nil;

		if self.flightPathType == FlightPathType.HorizontalTrajectory then
			--水平轨迹
			nextPosition, angle = self:CaculateCurHorizontalPosition();

		elseif self.flightPathType == FlightPathType.Parabola then
			--抛物线轨迹
			nextPosition, angle = self:CaculateCurParabolaPosition(targetPos);

		elseif self.flightPathType == FlightPathType.StraightLine then
			--直线
			nextPosition, angle = self:CaculateCurStraightPosition(targetPos);

		end

		if not self:IsEnd(nextPosition, targetPos) then
			--设置特效位置
			self:GetCppObject().Translate = Vector3(nextPosition.x, nextPosition.y, self.startPosition.z);
			self:GetCppObject():SetRotation(angle, Vector3.UNIT_Z);


			if self.lastTime > 7 then
			    local pos = self:GetCppObject().Translate;
			    --[[
			    Debug.print("traceEffect update longer than 6 seconds. x = " .. pos.x .. ", y = " .. pos.y ..
			    ", dir = " .. self.dir .. ", path = " .. self.fightPathType ..
			    ", nextPos = " .. nextPosition .. ", angle = " .. angle);
			    --]]
			    Debug.print("traceEffect update longer than 6 seconds. x = " .. pos.x .. ", y = " .. pos.y)
			    Debug.print(", dir = " .. self.dir .. ", path = " .. self.flightPathType)
			    Debug.print(", nextPos = " .. nextPosition.x .. "/" .. nextPosition.y .. ", angle = " .. angle:Value());
			end
		end
	end

	--父类更新
	Effect.Update(self, Elapse)

end

--计算抛物线当前位置
function TraceEffect:CaculateCurParabolaPosition(endPosition)
	local totalTime = CheckDiv(math.abs(endPosition.x - self.startPosition.x) / self.xSpeed);			--飞行总时间
	local yOffset = endPosition.y - self.startPosition.y;									--y方向偏移
	local yAddSpeed = CheckDiv(2 * (yOffset - self.ySpeed * totalTime) / (totalTime * totalTime));	--y方向加速度
	local ty = (self.ySpeed * self.lastTime + 0.5 * yAddSpeed * self.lastTime * self.lastTime) + self.startPosition.y;
	local tx = self.startPosition.x + self.xSpeed * self.lastTime * self.dir;
	local ySpeed = self.ySpeed + self.lastTime * yAddSpeed;

	return {x = tx, y = ty, z = self.startPosition.z}, Math.ATan(CheckDiv(-ySpeed / self.xSpeed));
end

--计算水平当前位置
function TraceEffect:CaculateCurHorizontalPosition()
	local tx = self.startPosition.x + self.xSpeed * self.lastTime * self.dir;
	return {x = tx, y = self.startPosition.y, z = self.startPosition.z}, Math.ATan(0);
end

--计算直线当前位置
function TraceEffect:CaculateCurStraightPosition(endPosition)
    local totalTime = CheckDiv(math.abs(endPosition.x - self.startPosition.x) / self.xSpeed);			--飞行总时间
    if totalTime == 0 then
        return self.startPosition, 0;
    end

    local yOffset = endPosition.y - self.startPosition.y;									--y方向偏移
    local ySpeed = CheckDiv(yOffset / totalTime);
    local ty = self.startPosition.y + ySpeed * self.lastTime;
    local tx = self.startPosition.x + self.xSpeed * self.lastTime * self.dir;

    return {x = tx, y = ty, z = self.startPosition.z}, Math.ATan(CheckDiv(-ySpeed / self.xSpeed));
end

--飞行是否结束
function TraceEffect:IsEnd(curPos, targetPos)

	if ((self.dir == 1) and (curPos.x >= targetPos.x)) or ((self.dir == -1) and (curPos.x <= targetPos.x)) or self.lastTime > 2.5 then
		--设置特效位置
		--self:GetCppObject().Translate = Vector3(targetPos.x, targetPos.y, curPos.z);

		--到达,脚本结束等待，继续开始
		self.effectScript:EndWaiting();
		--Debug.print("IsEnd EndWaiting" .. self.lastTime);

		--添加追踪特效飞行时间
		local attackClass = FightAttackManager:GetAttackClass(self.attackClassID);
		if attackClass ~= nil then
			attackClass:GetAttackerSkill():AddExtraTime(self.lastTime);
			self:AddDisappearEffect(self:GetCppObject(), attackClass:GetAttackerSkill(), attackClass:GetAttacker());
		end

		return true;
	end

	return false;
end

--添加追踪特效失效特效
function TraceEffect:AddDisappearEffect(tracerEffect, tracerSkill, attacker)
    --[[
	local hitEffectName = tracerSkill:GetHitEffectName();
	if hitEffectName ~= nil and hitEffectName ~= '' then
		tracerSkill:SetPlayedHitEffect(true);

		if attacker:GetFighterState() ~= FighterState.death then
			local effectData = EffectManager:createEffectData( hitEffectName );
			effectData.Translate = Vector3(tracerEffect.Translate.x, tracerEffect.Translate.y, tracerEffect.Translate.z);
			effectData.ZOrder = tracerEffect.ZOrder;

			--场景特效直接挂到当前活动场景上
			local scene = SceneManager:GetActiveScene();
			scene:GetRootCppObject():AddChild(effectData);
			effectData:SetAnimation('play');
		end
	end

	--]]
end
