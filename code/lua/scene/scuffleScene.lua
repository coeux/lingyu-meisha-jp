--scuffleScene.lua

--========================================================================
--依赖

LoadLuaFile("lua/scene/scene.lua");

--========================================================================
--========================================================================
--乱斗场场景

ScuffleScene = class(LuaScene);

local obstacle = nil;
local obstacleRight = nil;
local obstacleLeftXPos = -600
local obstacleRightPos = 640
--初始化
function ScuffleScene:constructor( resID )
	self.width =1703 --GlobalData.FightSceneLogicWidth;		--宽度
	self.height =480 --GlobalData.FightSceneLogicHeight;		--高度
	
	local fileName = GlobalData:GetResDir() .. resTableManager:GetValue(ResTable.scene, self.resID, 'source');
	--[[
	local sprite = Sprite( sceneManager:CreateSceneNode('Sprite') );
	sprite:SetImage( fileName, Rect(0, 0, 1920, 1080));
	sprite.ZOrder = -10000;	--设置在最底层
	sprite.Translate = Vector3(0, 0, 0);
	sprite.Scale = Vector3(1.1104, 0.7, 0.5);
	self:GetRootCppObject():AddChild(sprite);
	]]
	local sprite = Sprite( sceneManager:CreateSceneNode('Sprite') );
	sprite:SetImage( fileName, Rect(0, 0, 1024, 480) );
	sprite.ZOrder = FightZOrderList.bottom;	--设置在最底层
	sprite.Translate = Vector3(-339,-150,0); --??
	self:GetRootCppObject():AddChild(sprite);	
	
	sprite = Sprite( sceneManager:CreateSceneNode('Sprite') );
	sprite:SetImage( fileName, Rect(0, 480, 680, 960) );
	sprite.ZOrder = FightZOrderList.bottom;	--设置在最底层
	sprite.Translate = Vector3(513, -150, 0);
	self:GetRootCppObject():AddChild(sprite);	
	self:GetRootCppObject():SortChildren();
end

--销毁
function ScuffleScene:Destroy()
	
	LuaScene.Destroy(self);
end

--更新
function ScuffleScene:Update( Elapse )

	LuaScene.Update(self, Elapse);

end

--该点是否选中可对战玩家，乱斗场开始时1分钟等待时间不可对战
function ScuffleScene:isPlayerPos( pos )
	--if ScufflePanel:isWaitTime() then
	--	return {isPlayerHit = false};
	--end
	for id,scufflePlayer in pairs(ActorManager.actorList) do
		--英雄id为0，选中对手条件：非英雄，点中，非战斗
		if id ~= 0 and scufflePlayer:Hit(pos) then
			return {isPlayerHit = true, id = scufflePlayer.id, name = scufflePlayer.name, inBattle = scufflePlayer.inBattle,posX = scufflePlayer:GetPosition().x};
		end
	end
	return {isPlayerHit = false};
end

--是否可以移动
function ScuffleScene:CanMove( touchPos )
--[[
	if ScufflePanel.reviveState then
		local heroPos = ActorManager.hero:GetPosition();
		if heroPos.x < obstacleLeftXPos and touchPos.x > obstacleLeftXPos-20 then
			touchPos = Vector2(obstacleLeftXPos-20, touchPos.y)
		elseif heroPos.x > obstacleRightPos and touchPos.x < obstacleRightPos+20  then
			touchPos = Vector2(obstacleRightPos+20, touchPos.y)
		end
	else
]]
		if touchPos.x < obstacleLeftXPos+20 then
			touchPos = Vector2(obstacleLeftXPos+20, touchPos.y)
		elseif touchPos.x > obstacleRightPos-20 then
			touchPos = Vector2(obstacleRightPos-20, touchPos.y)
		end
	--end
	--print('scuffleScene-x->'..tostring(touchPos.x)..' -y->'..tostring(touchPos.y));
	return true, touchPos;
end

--初始化NPC头顶
function ScuffleScene:InitNPCHead()
	return;
end
--设置复活区域
function ScuffleScene:setReviveArea()
	self:cancelReviveArea()
	
	AvatarManager:LoadFile(GlobalData.EffectPath .. 'gonghuiBOSS_output/');
	obstacleLeft = Armature( sceneManager:CreateSceneNode('Armature') );
	obstacleLeft:LoadArmature('gonghuiBOSS');
	obstacleLeft.Scale = Vector3(1, 1.4, 1);
	obstacleLeft.Translate = Vector3(obstacleLeftXPos, -253, 0);
	obstacleLeft:SetAnimation('play');
	obstacleLeft.ZOrder = FightZOrderList.obstacle;
	self:GetRootCppObject():AddChild(obstacleLeft);
	
	AvatarManager:LoadFile(GlobalData.EffectPath .. 'gonghuiBOSS_output/');
	obstacleRight = Armature( sceneManager:CreateSceneNode('Armature') );
	obstacleRight:LoadArmature('gonghuiBOSS');
	obstacleRight.Scale = Vector3(1, 1.4, 1);
	obstacleRight.Translate = Vector3(obstacleRightPos, -253, 0);
	obstacleRight:SetAnimation('play');
	obstacleRight.ZOrder = FightZOrderList.obstacle;
	self:GetRootCppObject():AddChild(obstacleRight);
end
function ScuffleScene:cancelReviveArea()
	if obstacleLeft ~= nil then
		self:GetRootCppObject():RemoveChild(obstacleLeft);
		obstacleLeft = nil;
	end
	if obstacleRight ~= nil then
		self:GetRootCppObject():RemoveChild(obstacleRight);
		obstacleRight = nil;
	end
end