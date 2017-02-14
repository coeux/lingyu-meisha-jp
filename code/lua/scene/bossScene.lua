--bossScene.lua

--========================================================================
--依赖

LoadLuaFile("lua/scene/scene.lua");

--========================================================================
--========================================================================
--Boss场景

LuaBossScene = class(LuaScene);

local obstacleSlope = 3.1;				--障碍斜率
local obstacle = nil;					--障碍


--初始化
function LuaBossScene:constructor( resID )
	self.AllowFight = false;										--允许战斗

	local fileName = GlobalData:GetResDir() .. resTableManager:GetValue(ResTable.scene, self.resID, 'source');
	--背景图（1448*480 =》 1024*1024）
	--切分成2个区域（0,0,1024,480）和（0,480,424,960）


	if resID == GlobalData.UnionBossSceneId then
		self.width = 1448;--GlobalData.FightSceneLogicWidth;					--宽度
		self.height = 480;--GlobalData.FightSceneLogicHeight;					--高度

		local sprite = Sprite( sceneManager:CreateSceneNode('Sprite') );
		sprite:SetImage( fileName, Rect(0, 0, 1024, 480) );
		sprite.ZOrder = FightZOrderList.bottom;	--设置在最底层
		sprite.Translate = Vector3(-212, 0, 0); --??
		self:GetRootCppObject():AddChild(sprite);

		sprite = Sprite( sceneManager:CreateSceneNode('Sprite') );
		sprite:SetImage( fileName, Rect(0, 480, 424, 960) );
		sprite.ZOrder = FightZOrderList.bottom;	--设置在最底层
		sprite.Translate = Vector3(512, 0, 0);
		self:GetRootCppObject():AddChild(sprite);

	else -- 世界BOSS
		self.width = 1024;--GlobalData.MainSceneLogicWidth;					--宽度
		self.height = 480; --GlobalData.MainSceneLogicHeight;					--高度

		local sprite = Sprite( sceneManager:CreateSceneNode('Sprite') );
		sprite:SetImage( fileName, Rect(0, 0, 1024, 480) );
		sprite.ZOrder = FightZOrderList.bottom;	--设置在最底层
		sprite.Translate = Vector3(-212, 0, 0);
		self:GetRootCppObject():AddChild(sprite);

		sprite = Sprite( sceneManager:CreateSceneNode('Sprite') );
		sprite:SetImage( fileName, Rect(0, 480, 424, 960) );
		sprite.ZOrder = FightZOrderList.bottom;	--设置在最底层
		sprite.Translate = Vector3(512, 0, 0);
		self:GetRootCppObject():AddChild(sprite);
	end
end

--销毁
function LuaBossScene:Destroy()
	obstacle = nil;

	LuaScene.Destroy(self);
end

--更新
function LuaBossScene:Update( Elapse )

	LuaScene.Update(self, Elapse);

end

--测试是否可以移动
function LuaBossScene:CanMove( touchPos )
	if touchPos.y > -90 then return false, nil end;
	if self.AllowFight then
		return true, touchPos;
	elseif touchPos.x <= self:GetObstacleXPosition(touchPos.y) then
		return true, touchPos;
	else
		local heroPos = ActorManager.hero:GetPosition();
		if (heroPos.x == self:GetObstacleXPosition(touchPos.y)) and (heroPos.y == touchPos.y) then
			return false, nil;
		elseif (heroPos.x >= self:GetObstacleXPosition(touchPos.y) - 10) then
			return true, Vector2(self:GetObstacleXPosition(touchPos.y), touchPos.y), true;
		end

		return true, Vector2(self:GetObstacleXPosition(touchPos.y), touchPos.y);
	end

	return false, nil;
end

--添加boss
function LuaBossScene:AddBoss( bossID )
	self.npc = ActorManager:CreateNPC(bossID);
	self.npc:InitData();
	self.npc:InitAvatar();

	self:AddSceneNode(self.npc);

	self.rightEventRect = Rect(Vector2(self.npc:GetPosition().x - 180, self.npc:GetPosition().y - 50), Size(250,300));
end

--获取boss位置
function LuaBossScene:GetBossPosition()
	return Vector2(self.npc:GetPosition().x, self.npc:GetPosition().y);
end

--设置状态
function LuaBossScene:SetObstacleState( cd, isRevive )

	if cd > 0 then
		self.AllowFight = false;
		self:SetObstacle(isRevive);
	else
		self.AllowFight = true;
	end

end

--设置障碍
function LuaBossScene:SetObstacle(isRevive)
	if obstacle == nil then
		if isRevive then		--是否复活倒计时的障碍
			AvatarManager:LoadFile(GlobalData.EffectPath .. 'gonghuiBOSS_output/');
			obstacle = Armature( sceneManager:CreateSceneNode('Armature') );
			if WOUBossPanel.bossType == 1 then
				-- obstacle:LoadArmature('gonghuiBOSS_2');
				obstacle:LoadArmature('gonghuiBOSS');
				obstacle.Scale = Vector3(1, 1, 1);
				obstacle.Translate = Vector3(GlobalData.BossSceneMaxX + 20, -120, 0);
			else
				obstacle:LoadArmature('gonghuiBOSS');
				obstacle.Scale = Vector3(1, 0.85, 1);
				obstacle.Translate = Vector3(GlobalData.BossSceneMaxX + 20, -150, 0);
			end
			obstacle:SetAnimation('play');

		else
			AvatarManager:LoadFile(GlobalData.EffectPath .. 'gonghuiBOSS_output/');
			obstacle = Armature( sceneManager:CreateSceneNode('Armature') );
			if WOUBossPanel.bossType == 1 then
				obstacle:LoadArmature('gonghuiBOSS');
				obstacle.Scale = Vector3(1, 0.85, 1);
				obstacle.Translate = Vector3(GlobalData.BossSceneMaxX + 20, -120, 0);
			else
				obstacle:LoadArmature('gonghuiBOSS');
				obstacle.Scale = Vector3(1, 0.85, 1);
				obstacle.Translate = Vector3(GlobalData.BossSceneMaxX + 20, -150, 0);
			end
			obstacle:SetAnimation('play');

		end
		obstacle.ZOrder = FightZOrderList.obstacle;
		self:GetRootCppObject():AddChild(obstacle);
	end
end

--取消障碍
function LuaBossScene:CancelObstacle()
	self.AllowFight = true;

	if obstacle ~= nil then
		self:GetRootCppObject():RemoveChild(obstacle);
		obstacle = nil;
	end
end

--获取障碍X坐标
function LuaBossScene:GetObstacleXPosition(y)
	if obstacle ~= nil then
           return CheckDiv((y + obstacleSlope * GlobalData.BossSceneMaxX + 110) / obstacleSlope);
	end
end

--初始化NPC头顶
function LuaBossScene:InitNPCHead()
	return;
end
