--fightScene.lua

--========================================================================
--依赖

LoadLuaFile("lua/scene/scene.lua");

--========================================================================
--========================================================================
--战斗场景

LuaFightScene = class(LuaScene);

local common_scene_map = 'resource/scene/xuexiao/xx_zl_1.sce';

--初始化
function LuaFightScene:constructor( resID )

	self.width = GlobalData.FightSceneLogicWidth;		--宽度
	self.height = GlobalData.FightSceneLogicHeight;		--高度
	self.shaderSprite = nil;
	local fileName;										--场景文件名
	
	if FightType.arena == resID or FightType.FriendBattle == resID then
		fileName = GlobalData:GetResDir() .. Configuration.arenaScene;
		self.width = 426 * 2; 
	elseif FightType.scuffle == resID then
		fileName = GlobalData:GetResDir() .. Configuration.scuffleScene;
		self.width = 426 * 2;
	elseif FightType.trial == resID then
		fileName = GlobalData:GetResDir() .. Configuration.trialScene;
	elseif FightType.treasureGrabBattle == resID or FightType.treasureRobBattle == resID then				--巨龙宝库pvp战斗
		fileName = GlobalData:GetResDir() .. Configuration.treasureScene;
		self.width = 426 * 2;
	elseif RoundIDSection.NoviceBattleID == resID then
		fileName = GlobalData:GetResDir() .. resTableManager:GetValue(ResTable.tutorial_round, self.resID, 'source');
		self.width = resTableManager:GetValue(ResTable.tutorial_round, self.resID, 'scene_width');
	elseif FightType.worldBoss == resID then
		fileName = GlobalData:GetResDir() .. Configuration.worldBossScene;
		self.width = 426 * 2;
	elseif FightType.unionBoss == resID then
		fileName = GlobalData:GetResDir() .. Configuration.unionBossScene;
		self.width = 426 * 2;
	elseif (resID >= RoundIDSection.TreasureBegin) and (resID <= RoundIDSection.TreasureEnd) then		--巨龙宝库
		fileName = GlobalData:GetResDir() .. Configuration.grabScene;
		self.width = 426 * 2;
	elseif resID >= RoundIDSection.InvasionBegin and resID <= RoundIDSection.InvasionEnd then			--杀星
		fileName = GlobalData:GetResDir() .. resTableManager:GetValue(ResTable.invasion, self.resID, 'source');
		self.width = resTableManager:GetValue(ResTable.invasion, self.resID, 'scene_width');
	--elseif resID >= RoundIDSection.MiKuBegin and resID <= RoundIDSection.MiKuEnd then			--迷窟
	--	fileName = GlobalData:GetResDir() .. resTableManager:GetValue(ResTable.miku, self.resID, 'source');
	elseif resID >= RoundIDSection.LimitRoundBegin and resID <= RoundIDSection.LimitRoundEnd then			--限时副本
		fileName = GlobalData:GetResDir() .. resTableManager:GetValue(ResTable.limit_round, self.resID, 'source');
		self.width = resTableManager:GetValue(ResTable.limit_round, self.resID, 'sourse_width'); -- 策划填的字段名称 sourse_width
	elseif resID >= RoundIDSection.ExpeditionBegin and resID <= RoundIDSection.ExpeditionEnd then
		fileName = GlobalData:GetResDir() .. resTableManager:GetValue(ResTable.expedition, self.resID, 'source');
		self.width = resTableManager:GetValue(ResTable.expedition, self.resID, 'scene_width');
	elseif resID >= RoundIDSection.CardEventBegin and resID <= RoundIDSection.CardEventEnd then -- 临时使用这个
		fileName = GlobalData:GetResDir() .. 'resource/scene/senlin/sl_1_2.sce'
		self.width = 1706
	elseif FightType.rank == resID then
		fileName = GlobalData:GetResDir() .. 'resource/scene/senlin/sl_1_2.sce'
		self.width = 1706
	elseif FightType.unionBattle == resID then
		fileName = GlobalData:GetResDir() .. 'resource/scene/senlin/sl_1_2.sce'
		self.width = 1706
	else
		fileName = GlobalData:GetResDir() .. resTableManager:GetValue(ResTable.barriers, self.resID, 'source');
		self.width = resTableManager:GetValue(ResTable.barriers, self.resID, 'scene_width');
	end	
	
	local xfile = xmlParseFile( fileName );
	local rootNode = xfile[1];
	
	--路径
	local path;
	_,_,path = string.find(fileName, "(.*/)");

	if rootNode.n then

		local nodeNum = rootNode.n;
		for i = 1, nodeNum do

			local nodeXML = rootNode[i];
			local attr = nodeXML['attr'];

			if nodeXML.name == 'Sprite' then

				local sprite = Sprite( sceneManager:CreateSceneNode('Sprite') );
				
				local value = attr['Translate'];
				if value ~= nil then
					sprite.Translate = Converter.String2Vector3(value);
				end
				
				value = attr['Scale'];
				if value ~= nil then
					sprite.Scale = Converter.String2Vector3(value);
				end
				
				value = attr['Rotation'];
				if value ~= nil then
					sprite:SetRotationZ( Degree(tonumber(value)) );
				end
				
				value = attr['ImageArea'];
				if value ~= nil then
					sprite:SetImage( path .. attr['FileName'], Converter.String2Rect(value) );
				else
					sprite:SetImage(path .. attr['FileName']);
				end

				sprite.ZOrder = tonumber(attr['ZOrder']);
				self:GetRootCppObject():AddChild(sprite);

				local speed = tonumber(attr['MoveSpeed']);
				if speed ~= 1 then
					table.insert( self.moveNode, { sprite = sprite, speed = speed } );
				end

			elseif nodeXML.name == 'ParticleSystem' then

				local asyncLoadFlag = renderer.AsyncLoadFlag;
				renderer.AsyncLoadFlag = false;
		
				local particleSystem = Sprite( sceneManager:CreateSceneNode('ParticleSystem') );
				self:GetCppObject():AddChild(particleSystem);

				local value = attr['FileName'];
				if value ~= nil then
					particleSystem:LoadFromFile(GlobalData.ParticlePath .. value);
					particleSystem:Start();
				end
				
				renderer.AsyncLoadFlag = asyncLoadFlag;

			elseif nodeXML.name == 'Armature' then
		
				local armature = Armature( sceneManager:CreateSceneNode('Armature') );

				local value = attr['PathName'];
				if value ~= nil then
					AvatarManager:LoadFile(value);
				end
				
				value = attr['ArmatureName'];
				if value ~= nil then
					armature:LoadArmature(value);
				end
				
				value = attr['AnimationName'];
				if value ~= nil then
					armature:SetAnimation(value);
				end
				
				value = attr['Translate'];
				if value ~= nil then
					armature.Translate = Converter.String2Vector3(value);
				end
				
				value = attr['Scale'];
				if value ~= nil then
					armature.Scale = Converter.String2Vector3(value);
				end
				
				value = attr['Rotation'];
				if value ~= nil then
					armature:SetRotationZ( Degree(tonumber(value)) );
				end
				
				armature.ZOrder = tonumber(attr['ZOrder']);
				self:GetRootCppObject():AddChild(armature);

			else
				print("Don't know SceneNode type!");
			end

		end

	end

        --加载异次元背景
        local blackBg = Sprite( sceneManager:CreateSceneNode('Sprite') );
        blackBg:SetImage("resource/ui/common/black.jpg");
        blackBg.AutoSize = false;
        blackBg.Size = Size(4000, 2000);
        blackBg.ZOrder = -400;
        self:GetRootCppObject():AddChild(blackBg);
        self.blackBg = blackBg;
        self:GoBright(); -- 默认不进入异次元背景
	--[[
	--加载传送点-
	local leftTeleport = sceneManager:CreateSceneNode('Armature');
	if FightManager.isPvP or (FightManager.mFightType == FightType.worldBoss) or (FightManager.mFightType == FightType.unionBoss) then
		leftTeleport.Translate = Vector3( -1 * self.width / 2 + Configuration.FightTeleportPvpLeftOffset.x, Configuration.FightTeleportPvpLeftOffset.y, 0);
	else
		leftTeleport.Translate = Vector3( -1 * self.width / 2 + Configuration.FightTeleportPveLeftOffset.x, Configuration.FightTeleportPveLeftOffset.y, 0);
	end
	
	leftTeleport.ZOrder = FightZOrderList.teleport;
	leftTeleport:LoadArmature('teleport');
	leftTeleport:SetAnimation('play');
	self:GetRootCppObject():AddChild(leftTeleport);
	
	local rightTeleport = sceneManager:CreateSceneNode('Armature');
	rightTeleport.Translate = Vector3( self.width / 2 + Configuration.FightTeleportRightOffset.x, Configuration.FightTeleportRightOffset.y, 0);
	rightTeleport.ZOrder = FightZOrderList.teleport;
	rightTeleport:LoadArmature('teleport');
	rightTeleport:SetAnimation('play');
	self:GetRootCppObject():AddChild(rightTeleport);
	--]]
	
	self:GetRootCppObject():SortChildren();
	
end

--添加场景遮罩
function LuaFightScene:AddShader()
	self.shaderSprite = Sprite( sceneManager:CreateSceneNode('Sprite') );	
	self.shaderSprite.AutoSize = false;
	self.shaderSprite.Size = Size(GlobalData.FightSceneLogicWidth, GlobalData.FightSceneLogicHeight);	
	self.shaderSprite:SetImage(GlobalData:GetResDir() .. 'resource/other/sceneShader.ccz', Rect(0, 0, 1024, 480));
	
	self.shaderSprite.ZOrder = FightZOrderList.shader;	--设置在最底层
	self.shaderSprite.Translate = Vector3(0, 0, 0);
	self:GetRootCppObject():AddChild(self.shaderSprite);
	
	self:GetRootCppObject():SortChildren();
end

--删除场景遮罩
function LuaFightScene:RemoveShader()
	if self.shaderSprite ~= nil then
		self:GetRootCppObject():RemoveChild(self.shaderSprite);
		self.shaderSprite = nil;
	end
end

function LuaFightScene:GoDark()
   self.blackBg.ZOrder = -400;
   self:GetRootCppObject():SortChildren();
end

function LuaFightScene:GoBright()
   self.blackBg.ZOrder = -10000000;
   self:GetRootCppObject():SortChildren();
end


function LuaFightScene:Enter()
	print("entering fight=================================");
    for k, v in pairs(_G["fileImageMap"]) do 
			if true then uiSystem:DestroyImage(k) end
    end
  EventManager:FireEvent(EventType.RecoverDisplayMemory, true);	
end
