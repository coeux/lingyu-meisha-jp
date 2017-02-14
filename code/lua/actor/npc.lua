--npc.lua

--========================================================================
--依赖

LoadLuaFile("lua/actor/player.lua");

--========================================================================
--NPC类

NPC = class(Player)

local NpcTypePlot = 1;        --剧情NPC
local NpcTypeDefault = 0;      --NPC
local NpcTypeCityBoss = 2;      --杀星


function NPC:constructor( id, resID )
  
  --========================================================================
  --属性相关

  self.hp        = 100;        --hp
  self.awaitTimer    = 0;        --待机小动作计时器
  self.npcType     = NpcTypeDefault;  --默认为主城NPC
  --========================================================================

end

--更新
function NPC:Update( Elapse )
  Player.Update(self, Elapse);
	--self:lazyShow();
end

function NPC:Destroy()
  
  --去除待机小动作计时器
  if self.awaitTimer ~= 0 then
    timerManager:DestroyTimer(self.awaitTimer);
    self.awaitTimer = 0;
  end
  
  Actor.Destroy(self);

end

--初始化数据
function NPC:InitData( data )
  if self.id == 118 or self.id == 125 then
    self.name =''
    self.title = ''
  else
      self.name = resTableManager:GetValue(ResTable.npc, self.resID, 'name');
      self.title = resTableManager:GetValue(ResTable.npc, self.resID, 'title');
  end
end

--初始化人物形象
function NPC:InitAvatar()

  self:loadNpc();
  
end

--初始化头顶
function NPC:InitHead()
  self.uiHead = uiSystem:CreateControl('StackPanel');  
  self.uiHead.Pick = false;
  self.uiHead.Alignment = Alignment.Center;
  self.uiHead.AutoSize = true;
  self.uiHead.Scale = Vector2(0.8, 0.8);
  
  --称号
  self.uiHead.uiTitle = uiSystem:CreateControl('Label');
  self.uiHead.uiTitle.Pick = false;
  self.uiHead.uiTitle.Size = Size(200, 20);
  self.uiHead.uiTitle.Margin = Rect(-100, -15, 0, 0);
  self.uiHead.uiTitle.TextAlignStyle = TextFormat.MiddleCenter;
  self.uiHead.uiTitle:SetFont('JP_20_miaobian');
  self.uiHead.uiTitle.TextColor = QualityColor[10];
  self.uiHead.uiTitle.Text = self.title;
  
  --名字
  self.uiHead.uiName = uiSystem:CreateControl('Label');
  self.uiHead.uiName.Pick = false;
  self.uiHead.uiName.Size = Size(200, 20);
  self.uiHead.uiName.Margin = Rect(-100, -15, 0, 0);
  self.uiHead.uiName.TextAlignStyle = TextFormat.MiddleCenter;
  self.uiHead.uiName:SetFont('JP_20_miaobian_1');
  self.uiHead.uiName.TextColor = QualityColor[10];
  self.uiHead.uiName.Text = self.name;
  
  if tonumber(self.resID) < 900 then
    self.uiHead.taskInfo = ImageElement(uiSystem:CreateControl('ImageElement'));
    self.uiHead.taskInfo.Pick = false;
    
    --设置图片  
    self.uiHead.taskInfo.Image = GetPicture('dynamicPic/task_3.ccz');
    self.uiHead.taskInfo.Visibility = Visibility.Visible;
    self.uiHead.taskInfo.AutoSize = true;
    self.uiHead:AddChild(self.uiHead.taskInfo);
    --self.uiHead.taskInfo.Size = Size(65, 70);  
    --self.uiHead.taskInfo.Margin = Rect(, -15, 0, 0);
  end

  self.uiHead:AddChild(self.uiHead.uiName);
  self.uiHead:AddChild(self.uiHead.uiTitle);  
  bottomDesktop:AddChild(self.uiHead);
end

--更新NPC头顶任务标示图标
function NPC:UnpdateHeadStatus(status)
  self:SetTaskStatus( status );
  --还没初始化
  if nil == self.uiHead then
    return;
  end
  self.uiHead.taskInfo.Visibility = Visibility.Visible;
  if NpcStatus.noLevel == self.taskStatus then
    self.uiHead.taskInfo.Image = GetPicture('dynamicPic/' .. NpcStatusImage.noLevel .. '.ccz');
  elseif NpcStatus.undone == self.taskStatus then
    self.uiHead.taskInfo.Image = GetPicture('dynamicPic/' .. NpcStatusImage.undone .. '.ccz');
  elseif NpcStatus.receive == self.taskStatus then
    self.uiHead.taskInfo.Image = GetPicture('dynamicPic/' .. NpcStatusImage.receive .. '.ccz');
  elseif NpcStatus.complete == self.taskStatus then
    self.uiHead.taskInfo.Image = GetPicture('dynamicPic/' .. NpcStatusImage.complete .. '.ccz');
  else
    self.uiHead.taskInfo.Visibility = Visibility.Hidden;
  end
  
end

--设置NPC任务状态
function NPC:SetTaskStatus( status )
  self.taskStatus = status;
end

--点击测试
function NPC:Hit( PT )
  return self:GetBoundBox():Contain(PT);
end

--碰撞测试
function NPC:AreaCollision( area )
  return self:GetBoundBox():Contain(area);
end

--========================================================================

--更新头顶
function NPC:updateHead()
  if self.uiHead ~= nil then
    local pos = self:GetPosition();
    local y = pos.y + self.bodyHeight * GlobalData.ActorScale;
    local uiPos = SceneToUiPT( sceneManager.ActiveScene.Camera, bottomDesktop.Camera, Vector3(pos.x, y, pos.z) );    
    self.uiHead.Translate = Vector2(uiPos.x, uiPos.y - self.uiHead.Height - 20);
    self.uiHead.ZOrder = Convert2ZOrder(pos.y);
  end
end

function NPC:lazyShow()
  
	--已经加载则不加载了
	if self.loaded then return end;

	local npcData = self.npcData;
	if not npcData then return end;

	local pos = self:GetPosition();
	local uiPos = SceneToUiPT( sceneManager.ActiveScene.Camera, bottomDesktop.Camera, Vector3(pos.x, pos.y, 1) );    

	local screenWidth  = appFramework.ScreenWidth
	local screenHeight = appFramework.ScreenHeight;

	local delta = 50
	if uiPos.x < delta or uiPos.x > screenWidth - delta then
		return
	end
	if uiPos.y < delta or uiPos.y > screenHeight - delta then
		return
	end

  --形象
  local path = GlobalData.AnimationPath .. npcData['path'] .. '/';
  AvatarManager:LoadFile(path);
  local avatarName = npcData['img'];
  self:LoadArmature(avatarName);
  self:SetAnimation(AnimationType.idle);
	self:SetAwaitAimation();
	self.loaded = true;
end


--加载npc形象
function NPC:loadNpc()
  
  local npcData = resTableManager:GetRowValue(ResTable.npc, self.resID);
--	self.npcData = npcData;
  
  --体积
  self.bodyWidth = npcData['width'];
  self.bodyHeight = npcData['height'];

  local path = GlobalData.AnimationPath .. npcData['path'] .. '/';
  AvatarManager:LoadFile(path);
  local avatarName = npcData['img'];
  self:LoadArmature(avatarName);
  self:SetAnimation(AnimationType.idle);

  --位置
  local x;
  local y;
  if NpcTypePlot == self.npcType then
    x = self.posx;
    y = self.posy;
  else
    x = npcData['coord'][1];
    y = npcData['coord'][2];
  end  
  
  self:SetPosition(Vector3(x, y, 0));
  
  --设置影子
  -- self:SetShadow( npcData['shadow'] );
  
  if tostring(Configuration.StatueNPCID) == self.resID then
    --self:SetScale(1, 1);
  else
    --人物按照场景比例进行一定的缩放
    local scale = npcData['bodytype'];
    if scale == nil then
      scale = 1;
    end
    self:SetScale(GlobalData.ActorNPCScale * scale , GlobalData.ActorNPCScale * scale);
  end  
  
  --朝向
  self:SetDirection( npcData['headto'] );
  
end

--========================================================================
--动作

--待机小动作
function NPC:SetAwaitAimation()
  onNPCnAwaitCallback( self:GetID() );
end

--待机小动作
function onNPCnAwaitCallback( npcID )

  local npc = ActorManager:GetActor(npcID);
  if npc.awaitTimer ~= 0 then
    timerManager:DestroyTimer(npc.awaitTimer);
  end
  
  if npc:IsHaveAnimation(AnimationType.await) then
    npc:SetAnimation(AnimationType.await);
  else
    npc:SetAnimation(AnimationType.idle);
  end

  npc.awaitTimer = timerManager:CreateTimer( Math.RangeRandom(6, 15), 'onNPCnAwaitCallback', npcID);

end

--剧情NPC参数初始化
function NPC:InitPlotNpc( x, y )
  self.npcType = NpcTypePlot;
  self.posx = x;
  self.posy = y;
end

function NPC:MoveTo(pos)
  if pos.y > GlobalData.MainSceneMaxY then
    pos.y = GlobalData.MainSceneMaxY;
  end  
  Player.MoveTo(self, pos);  
end
