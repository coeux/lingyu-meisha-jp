--unionScene.lua
--========================================================================
--依赖
LoadLuaFile("lua/scene/scene.lua");

--===========================================================================================
--公会场景

LuaUnionScene = class(LuaScene);


local redEnvelopesList = {};							--红包列表
local redEnvelopesOriginalPos = {1, 2, 3, 4, 5, 6};		--红包位置
local redEnvelopesCanUsePos = {};						--红包可用位置
local deltaOffset = 10;									--偏移

--初始化
function LuaUnionScene:constructor( resID )
	print("construct union scene")	
	self.width = 1448;--GlobalData.FightSceneLogicWidth;		--宽度
	self.height = 480;--GlobalData.FightSceneLogicHeight;		--高度

	self.isUnionScene = true;
	
	--加载npc
	self.npcList = {};
	local npcIdList = self:readNpcList(self.resID);
	for _,npcId in ipairs(npcIdList) do
		if npcId ~= 907 and npcId ~= 903 then 
			local npc = ActorManager:CreateNPC(npcId);
			npc:InitData();
			npc:InitAvatar();
			
			--npc:SetAwaitAimation();
			self:AddSceneNode(npc);
			
			table.insert(self.npcList, npc);
		end
	end

	local fileName = GlobalData:GetResDir() .. resTableManager:GetValue(ResTable.scene, self.resID, 'source');
	--local fileName = GlobalData:GetResDir() .. 'ui/background/default_bg.jpg';

	---[[
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
--]]
--[[	
	local sprite = Sprite( sceneManager:CreateSceneNode('Sprite') );
	sprite:SetImage( fileName, Rect(0, 0, 2025, 480) );
	sprite.ZOrder = FightZOrderList.bottom;	--设置在最底层
	sprite.Translate = Vector3(0, 0, 0);
	sprite.Scale = Vector3(1.1104, 1, 1);
	self:GetRootCppObject():AddChild(sprite);
	--]]
	self:GetRootCppObject():SortChildren();
	
	--红包
	self:RefreshUnionRedEnvelopes();

end

--销毁
function LuaUnionScene:Destroy()
	print("Union Scene Destroy")
	print("Union Scene Destroy")
	print("Union Scene Destroy")
	print("Union Scene Destroy")
	print("Union Scene Destroy")
	print("Union Scene Destroy")
	
	redEnvelopesList = {};
	LuaScene.Destroy(self);
end

--测试是否可以移动
function LuaUnionScene:CanMove( touchPos )
	--[[
	if touchPos.x <= GlobalData.UnionSceneMaxX then
		return true, touchPos;
	else
		local heroPos = ActorManager.hero:GetPosition();
		if (heroPos.x == GlobalData.BossSceneMaxX) and (heroPos.y == touchPos.y) then
			return false, nil;
		end
		
		return true, Vector2(GlobalData.BossSceneMaxX, touchPos.y);
	end
	--]]
	
		return true, touchPos;
	--return false, nil;
end

--该点是否为NPC位置
function LuaUnionScene:isNpcPos( pos )
	for _,npc in ipairs(self.npcList) do
		if npc:Hit(pos) then
			return true,tonumber(npc.resID);
		end
	end
	return false;
end

--读取城中的npc
function LuaUnionScene:readNpcList( resID )
	local strNpcList = resTableManager:GetValue(ResTable.scene, resID, 'npc_id');
	if strNpcList ~= nil then
		return strNpcList;
	end	
	return {};
end

--初始化NPC头顶
function LuaUnionScene:InitNPCHead()
	for _,npc in pairs(self.npcList) do
		npc:InitHead();
	end
end

--主角是否站在该NPC面前
function LuaUnionScene:isHeroStandInNpc(npcid)
	local pos = ActorManager.hero:GetPosition();
	local cor = resTableManager:GetValue(ResTable.npc, tostring(npcid), 'coord');
	if cor[2] > GlobalData.UnionSceneMaxY then
		cor[2] = GlobalData.UnionSceneMaxY;
	end
	if pos.x == cor[1] and pos.y == cor[2] then
		return true;
	else	
		return false;
	end
end

--该点是否为NPC位置
function LuaUnionScene:isRedEnvelopesPos( pos )
	for _,hongbao in pairs(redEnvelopesList) do
		if hongbao:Hit(pos) then
			return true, hongbao.id;
		end
	end
	return false;
end

--刷新公会红包
function LuaUnionScene:RefreshUnionRedEnvelopes()
--[[
	--删除之前的
	for k, hongbao in pairs(redEnvelopesList) do
		self:RemoveSceneNode(hongbao);
	end
	redEnvelopesList = {};
	redEnvelopesCanUsePos = clone(redEnvelopesOriginalPos);
	
	--建立新的红包
	for _,v in pairs(ActorManager.user_data.hongbao) do
		local hongbao = ActorManager:CreateRedEnvelopes(v.id);
		hongbao:InitData();
		hongbao:InitAvatar();
		hongbao:InitHead();
		hongbao:RefreshName(v.nickname .. LANG__39);
		hongbao:SetAnimation(AnimationType.idle);
		
		local data = resTableManager:GetRowValue(ResTable.guild_bonus_coordinate, tostring(self:GetCanUsePos()) );
		local x = data['x'] + Math.IRangeRandom(-deltaOffset, deltaOffset);
		local y = data['y'] + Math.IRangeRandom(-deltaOffset, deltaOffset);
		
		hongbao:SetPosition( Vector3(x, y, 0) );
	
		redEnvelopesList[v.id] = hongbao;
		self:AddSceneNode(hongbao);
	end
--]]
end

--添加红包
function LuaUnionScene:AddUnionRedEnvelopes( hongbaoData )
	local hongbao = ActorManager:CreateRedEnvelopes(hongbaoData.id);
	hongbao:InitData();
	hongbao:InitAvatar();
	hongbao:InitHead();
	hongbao:RefreshName(hongbaoData.nickname.. LANG__40);
	hongbao:SetAnimation(AnimationType.idle);
	
	local data = resTableManager:GetRowValue(ResTable.guild_bonus_coordinate, tostring(self:GetCanUsePos()) );
	local x = data['x'] + Math.IRangeRandom(-deltaOffset, deltaOffset);
	local y = data['y'] + Math.IRangeRandom(-deltaOffset, deltaOffset);
	
	hongbao:SetPosition( Vector3(x, y, 0) );

	redEnvelopesList[hongbaoData.id] = hongbao;
	self:AddSceneNode(hongbao);
end

--删除红包
function LuaUnionScene:RemoveUnionRedEnvelopes( id )
	local hongbao = redEnvelopesList[id];
	if hongbao == nil then
		print('remove not exist hongbao!');
		return;
	end
	
	redEnvelopesList[id] = nil;
	self:RemoveSceneNode(hongbao);
end

--获取可用位置
function LuaUnionScene:GetCanUsePos()
	if #redEnvelopesCanUsePos == 0 then
		return redEnvelopesOriginalPos[ Math.IRangeRandom(1, 6) ];
	end

	local pos = Math.IRangeRandom(1, #redEnvelopesCanUsePos);
	local ret = redEnvelopesCanUsePos[pos];
	table.remove(redEnvelopesCanUsePos, pos);
	
	return ret;
end
--[[

function LuaUnionScene:Leave()
	print("leaving union scene")
	for _, npc in ipairs(self.npcList) do
		if npc.awaitTimer ~= 0 then
			timerManager:DestroyTimer(npc.awaitTimer);
			npc.awaitTimer = 0;
		end
	end
end

function LuaUnionScene:Enter()
	print("enter union scene")
	for _, npc in ipairs(self.npcList) do
		npc:SetAwaitAimation();
	end
end
]]