--mainScene.lua
--========================================================================
--依赖

LoadLuaFile("lua/scene/scene.lua");

--========================================================================
--========================================================================
--主城场景

LuaMainScene = class(LuaScene);


--初始化
function LuaMainScene:constructor( resID )

  self.isMainScene = true;

  self.width = GlobalData.MainSceneLogicWidth;					--宽度
  self.height = GlobalData.MainSceneLogicHeight;					--高度

  --加载npc
  self.npcList = {};
  local npcIdList = self:readNpcList(self.resID);
  for _,npcId in ipairs(npcIdList) do
    local npc = ActorManager:CreateNPC(npcId);
    npc:InitData();
    npc:InitAvatar();
    npc:SetAwaitAimation();
    self:AddSceneNode(npc);

    table.insert(self.npcList, npc);
  end

  --加载杀星boss NPC
  self.bossList = {}
  StarKillBossMgr:InitBossScene(self)




  --构建全局寻路系统
  PathFinder = AStar.new()


  local fileName = GlobalData:GetResDir() .. "resource/scene/map001/map001_merge.sce";
  local xfile = xmlParseFile( fileName );
  self.mapNode = xfile[1];
end

function LuaMainScene:Enter()
  self.garbage_node = {}
  self.garbage_image = {}

  self.shaderSprite = nil;

  --路径
  local max_box = {
    top = 0,
    bottom = 0,
    left = 0,
    right = 0,
  };

  function max_box:calc(sprite)
    local top = sprite.Translate.y + sprite.Height/2;
    local bottom = sprite.Translate.y - sprite.Height/2;
    local left = sprite.Translate.x - sprite.Width/2;
    local right = sprite.Translate.x + sprite.Width/2;


    self.top = math.max(self.top, top);
    self.bottom = math.min(self.bottom, bottom);
    self.left = math.min(self.left, left);
    self.right = math.max(self.right, right);
  end

  local path = "resource/scene/map001/";

  if self.mapNode.n then

    local nodeNum = self.mapNode.n;
    for i = 1, nodeNum do

      local nodeXML = self.mapNode[i];
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

        value = attr['Opacity'];
        if value ~= nil then
          sprite.Opacity = tonumber(value);
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

        --主城建筑物ZOrder
        if tonumber(attr['ZOrder']) == -9999 then
          local bottom = sprite.Translate.y - sprite.Height/2;
          sprite.ZOrder = Convert2ZOrder(bottom);
          sprite.Opacity = 0.8;
        end

        self:GetRootCppObject():AddChild(sprite);

        table.insert(self.garbage_node, sprite);
        table.insert(self.garbage_image, path .. attr['FileName']);

        -- if attr['FileName'] == 'b05.png' then
        --   local path = GlobalData.EffectPath .. 'xinwen_output/'
        --   AvatarManager:LoadFile(path)
        --   local armature = Armature(sceneManager:CreateSceneNode('Armature'))
        --   armature.ZOrder = 1
        --   armature.Translate = Vector3(-42,-28,0)
        --   armature.Scale = Vector3(0.88,1.1,0)
        --   armature:LoadArmature('xinwen')
        --   armature:SetAnimation('play')
        --   sprite:AddChild(armature)
        -- end


        local speed = tonumber(attr['MoveSpeed']);
        if speed ~= 1 then
          table.insert( self.moveNode, { sprite = sprite, speed = speed } );
        end
        --计算场景大小
        max_box:calc(sprite);

      end

    end

  end

  --[[
  print("top = " .. max_box.top);
  print("bottom" .. max_box.bottom);
  print("left = " .. max_box.left);
  print("right = " .. max_box.right);
  --]]

  self.height = max_box.right * 2;
  self.width = max_box.top * 2;

  self:GetRootCppObject():SortChildren();
end

--更新
function LuaMainScene:Update( Elapse )

  --.insert(self.npcList, npc);
  if ActorManager.hero ~= nil then
    ActorManager.hero:Update(Elapse);
  end

  --更新动画
  for k, v in pairs(self.childrenList) do
    if ActorManager.hero ~= k then
      k:Update(Elapse);
    end
  end

end

--初始化NPC头顶
function LuaMainScene:InitNPCHead()
  for _,npc in pairs(self.npcList) do
    npc:InitHead();
  end
  self:UpdateNPCHeadStatus();
end

--更新NPC头顶任务标示图标
function LuaMainScene:UpdateNPCHeadStatus()
  for _,npc in pairs(self.npcList) do
    npc:UnpdateHeadStatus(Task:GetNpcTaskStatus(tonumber(npc:GetResID())));
  end
end

--读取城中的npc
function LuaMainScene:readNpcList( resID )
  local strNpcList = resTableManager:GetValue(ResTable.scene, resID, 'npc_id');
  if strNpcList ~= nil then
    return strNpcList;
  end
  return {};
end

--该点是否为NPC位置
function LuaMainScene:isNpcPos( pos )
  for _,npc in ipairs(self.npcList) do
    if npc:Hit(pos) then
      return true,tonumber(npc.resID);
    end
  end
  return false;
end

--清除杀星boss
function LuaMainScene:ClearSceneBoss(bossids)
  for bossID, boss in pairs(self.bossList) do
    for k, curBossId in pairs(bossids) do
      if tonumber(curBossId) == tonumber(bossID) then
        --self:RemoveSceneNode(boss);
        boss:HideSelf()
      end
    end
  end
end

function LuaMainScene:UpdateBossStatus(bossids, state)
  for bossID, boss in pairs(self.bossList) do
    for k, curBossId in pairs(bossids) do
      if curBossId == bossID then
        boss:RefreshStatus(state);
      end
    end
  end
end

function LuaMainScene:Leave()
  --清理节点
  __.each( self.garbage_node, function(node)
    self:GetRootCppObject():RemoveChild(node);
    node = nil
  end)
	EventManager:FireEvent(EventType.RecoverDisplayMemory, true);	

end
