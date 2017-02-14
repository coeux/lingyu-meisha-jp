--scene.lua

--========================================================================
--场景类

LuaScene = class()


--初始化
function LuaScene:constructor( resID )

	--========================================================================
	--属性相关
	
	self.resID		= tostring(resID);						--资源ID
	self.sceneNode	= Scene( sceneManager:CreateSceneNode('Scene') );		--场景
	self.rootNode	= Sprite( sceneManager:CreateSceneNode('Sprite') );			--root点

	self.enterEventArea = false;							--进入事件块
	self.leftEventRect	= Rect.ZERO;						--左侧事件块
	self.rightEventRect	= Rect.ZERO;						--右侧事件块
	self.bossRects = {};									--杀星boss响应区域
	
	self.moveNode	= {};									--需要移动的节点（战斗场景背景，不在childrenList中）
	self.childrenList = {};									--子节点
	
	--========================================================================
	self.sceneNode:AddChild(self.rootNode);
	
end

--销毁
function LuaScene:Destroy()

	for k, v in pairs(self.childrenList) do
		k:Destroy();
	end

	self.childrenList = {};

end

--更新
function LuaScene:Update( Elapse )

	--更新动画
	for k, v in pairs(self.childrenList) do
		k:Update(Elapse);
	end

end

--c++对象
function LuaScene:GetCppObject()
	return self.sceneNode
end

--root节点
function LuaScene:GetRootCppObject()
	return self.rootNode
end

--获取场景相机
function LuaScene:GetCamera()
	return self.sceneNode.Camera;
end

--========================================================================
--节点管理

--添加节点
function LuaScene:AddSceneNode( node )
	self.childrenList[node] = true;
	self.rootNode:AddChild( node:GetCppObject() );
end

--移除节点
function LuaScene:RemoveSceneNode( node )
	self.childrenList[node] = nil;
	self.rootNode:RemoveChild( node:GetCppObject() )
	node:Destroy();
end

--移除节点但不销毁
function LuaScene:RemoveSceneNodeNoDestroy( node )
	self.childrenList[node] = nil;
	self.rootNode:RemoveChild( node:GetCppObject() );
end

--添加特效
function LuaScene:AttachEffect( effect )
	self:GetRootCppObject():AddChild(effect)
end

--卸载特效
function LuaScene:DetachEffect( effect )
	if effect == nil then
		return;
	end
	self:GetRootCppObject():RemoveChild(effect);
end

--========================================================================
--移动

--测试是否可以移动
function LuaScene:CanMove( touchPos )
	return true, touchPos;	
end

function LuaScene:MoveScene( heroPos, deltaX , deltaY)
  if not deltaY then
    deltaY = 0;
  end
	
--判断相机是否需要移动
	local camera = self:GetCamera();
	local cameraPos = camera.Translate;
	local width = camera.ViewFrustum.Right;		--屏宽度的一半	
	local height = -camera.ViewFrustum.Bottom;		--屏高度的一半	
	local sceneWidth = self.width / 2;
	local sceneHeight = self.height / 2;
	local x = heroPos.x;	
	local y = heroPos.y;	
	local moveCamera = false;	
	if x > 0 then
		if x + width <= sceneWidth or deltaX < 0  then
			moveCamera = true
			camera.Translate = Vector3(x, cameraPos.y, cameraPos.z);
		end
		
	else
		if x - width >= -sceneWidth or deltaX > 0 then
			moveCamera = true
			camera.Translate = Vector3(x, cameraPos.y, cameraPos.z);
		end
	end	

	if y > 0 then
		if y + height <= sceneHeight or deltaY < 0  then
			camera.Translate = Vector3(cameraPos.x, y, cameraPos.z);
		end
		
	else
		if y - height >= -sceneHeight or deltaY > 0 then
			camera.Translate = Vector3(cameraPos.x, y, cameraPos.z);
		end
	end	

	if moveCamera then
		--相机移动则移动场景物件
		for _,v in ipairs(self.moveNode) do
			local pos = v.sprite.Translate;
			v.sprite.Translate = Vector3(pos.x + v.speed * deltaX, pos.y, pos.z);			
		end	
	end

  
  if ActorManager.hero:IsFindingWay() then
    return;
  end

	if self.rightEventRect:Contain( Vector2(heroPos.x, heroPos.y)) and self.rightEventRect:Contain( Vector2(ActorManager.hero.targetPos.x, ActorManager.hero.targetPos.y) ) then
		if self.enterEventArea then
		else
			if MainUI:GetSceneType() == SceneType.MainCity then
				self.enterEventArea = true;		
				EventManager:FireEvent(EventType.EnterFightArea);
				TaskFindPathPanel:Hide();
				self.enterEventArea = false;
				
			elseif MainUI:GetSceneType() == SceneType.WorldBoss then			--进入世界boss战斗区域
				self.enterEventArea = true;
				EventManager:FireEvent(EventType.EnterBossFightArea);	
				self.enterEventArea = false;
				
			elseif MainUI:GetSceneType() == SceneType.UnionBoss then			--进入公会boss战斗区域
				self.enterEventArea = true;
				EventManager:FireEvent(EventType.EnterBossFightArea);	
				self.enterEventArea = false;
				
			end
		end
	elseif self.leftEventRect:Contain( Vector2(heroPos.x, heroPos.y) ) and self.leftEventRect:Contain( Vector2(ActorManager.hero.targetPos.x, ActorManager.hero.targetPos.y) ) then
		if self.enterEventArea then
		else	
			if MainUI:GetSceneType() == SceneType.MainCity then
				self.enterEventArea = true;				
				EventManager:FireEvent(EventType.EnterWorldMapArea);
				self.enterEventArea = false;
				
			elseif MainUI:GetSceneType() == SceneType.WorldBoss then	
				
			elseif MainUI:GetSceneType() == SceneType.UnionBoss then
			
			end
		end
	else
		self.enterEventArea = false;
	end	
	
	for k, v in pairs(self.bossRects) do
		local curRect = v
		if self:PointInRect(Vector2(heroPos.x, heroPos.y), curRect) and self:PointInRect(Vector2(ActorManager.hero.targetPos.x, ActorManager.hero.targetPos.y), curRect) then
			if self.enterEventArea then
			else
				if MainUI:GetSceneType() == SceneType.MainCity and StarKillBossMgr:IsTheSameTarget(ActorManager.hero.targetPos) == false then				
					print("Will fight boss, index: "..k);
					StarKillBossMgr:SetKillBossId(k);
					EventManager:FireEvent(EventType.EnterFightBoss);
					StarKillBossMgr:OnSetTargetPos(ActorManager.hero.targetPos);
					self.enterEventArea = true;					
				end
			end
		else
			self.enterEventArea = false;
		end
	end

end

function LuaScene:PointInRect(pointVal, rectVal)
	if pointVal.x > rectVal[1] and pointVal.y > rectVal[2] and pointVal.x < rectVal[3] and pointVal.y < rectVal[4] then
		return true;
	else
		return false;
	end
end

function LuaScene:ClearBossRects()
	self.bossRects = {}
end

function LuaScene:InitSceneBoss(bossData)
	self.bossRects = {}
	
	local theRect;
	for k,v in pairs(bossData) do
		theRect = {v.x-50, v.y-50, v.x+50, v.y+50};
		--table.insert(self.bossRects, theRect);
		self.bossRects[v.id] = theRect;
	end
end

function LuaScene:Leave()
  print("Leave Scene: " .. self.resID)
end

function LuaScene:Enter()
  print("Enter Scene: " .. self.resID)
end
