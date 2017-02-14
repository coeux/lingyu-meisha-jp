--player.lua

--========================================================================
--依赖

LoadLuaFile("lua/actor/Actor.lua");
LoadLuaFile("lua/scene/astar.lua");

--========================================================================
--玩家类

Player = class(Actor)

function Player:constructor( id, resID )

  --========================================================================
  --属性相关

  self.state			= PlayerState.idle;			--状态

  self.hp				= 100;						--hp
  self.targetPos		= Vector2.ZERO;				--目标位置
  self.moveSpeed		= 200;						--移动速度
  self.moveSpeedRatio	= 1;						--移动速度加成系数
  self.avatarName		= nil;						--角色形象
  self.quality			= 1;						--角色品质
  self.wingid			= 0;						--翅膀id
  self.headUIYOffset	= 0;						--角色头上ui的高度偏移
  self.viptype 			= 0;						--vip状态
  self.unName			= nil;						--角色头上公会名
  self.path = {};                   --自动寻路路径
  self.title = {};
  self.level = 0
  self.season_rank = 63;            --排位赛段位
  --========================================================================

end

--更新
function Player:Update( Elapse )

  --更新头顶
  self:updateHead();

  --更新移动
  self:updateMove(Elapse);	

  --基类更新
  Actor.Update(self, Elapse)

end

--========================================================================
--设置动作
function Player:SetAnimation(id, timeScale)
  if (self.wingid ~= nil) and (self.wingid > 0) then
    if id == AnimationType.idle then
      id = AnimationType.fly_idle;
    elseif id == AnimationType.run then
      id = AnimationType.fly_run;
    end
  end

  Actor.SetAnimation(self, id, timeScale);
end

--添加翅膀
function Player:AttachWing(wingResid)
  Actor.AttachWing(self, wingResid);

  --更新动作
  if (self.animationID == AnimationType.idle) then
    Actor.SetAnimation(self, AnimationType.fly_idle);
  elseif (self.animationID == AnimationType.run) then
    Actor.SetAnimation(self, AnimationType.fly_run);
  end

  --更新速度
  self.moveSpeedRatio = resTableManager:GetValue(ResTable.wing, tostring(self.wingid), 'speed');
  if self.moveSpeedRatio == nil then
    self.moveSpeedRatio = 1;
  end

  --更新头顶UI的高度偏移
  --self.headUIYOffset = 20;
  self.wingid = wingResid;
end

--卸下翅膀
function Player:DettachWing()
  self.wingid = 0;

  Actor.DettachWing(self);

  --更新动作
  if (self.animationID == AnimationType.fly_idle) then
    Actor.SetAnimation(self, AnimationType.idle);
  elseif (self.animationID == AnimationType.fly_run) then
    Actor.SetAnimation(self, AnimationType.run);
  end

  --更新速度
  self.moveSpeedRatio = 1;

  --更新头顶UI的高度偏移
  --self.headUIYOffset = 0;
end

--添加宠物
function Player:AttachPet(petResid)
	Actor.AttachPet(self, petResid);
	self.petid = petResid;
end

--卸下宠物
function Player:DettachPet()
	self.petid = 0;
	Actor.DettachPet(self);
end

--重载宠物
function Player:RetachPet()
	if self.petid and self.petid ~= 0 then
		self:AttachPet(self.petid);
	end
end

--========================================================================
--数据初始化

--初始化数据
function Player:InitData( data )	
  self.name = data.name;
  self.weaponid = data.weaponid;
  self.viplevel = data.viplevel;
  self.wingid = data.wingid;
  self.quality = data.quality ;
  self.rare = Configuration:getRare(data.level);
  self:SetPosition( Convert2Vector3( Vector2(data.x, data.y) ) );
  self.unName = data.gangname;
  self.title = data.rankinfo;
  self.level = data.level
  self.viptype = data.viptype;
  self.season_rank = data.season_rank or 63;
  self.have_pet = data.have_pet;
  self.petid = data.petid;
end

--初始化人物形象
function Player:InitAvatar(skin)
	local playerData = resTableManager:GetRowValue(ResTable.actor, tostring(self.resID));
	if skin and skin > 5000000 then
		local skinPath = resTableManager:GetValue(ResTable.skin, tostring(skin), 'model');
		local path = GlobalData.AnimationPath .. skinPath .. '/';
 		AvatarManager:LoadFile(path);
		self.avatarName = string.sub(skinPath, 1, -8);
	else
		local path = GlobalData.AnimationPath .. playerData['path'] .. '/';
 		AvatarManager:LoadFile(path);
		self.avatarName = playerData['img'];
	end

  self:LoadArmature(self.avatarName);
  self:SetAnimation(AnimationType.idle);

  --体型
  self.bodyWidth = playerData['width'];
  self.bodyHeight = playerData['height'];
  
  --设置影子
  self:SetShadow( playerData['shadow'] );

  --人物按照场景比例进行一定的缩放
  self:SetScale(GlobalData.ActorScale, GlobalData.ActorScale);

  --显示翅膀
  if (self.wingid ~= nil) and (self.wingid > 0) then
    self:AttachWing(self.wingid);
  end

  if (self.have_pet) then
	  self:AttachPet(self.petid);
  end

--jp
--[[
  --vip特殊显示
  if self.viptype == -1 then
	if (self.wingid ~= nil) and (self.wingid > 0) then
		Actor.AttachVipToAvatar(self);
		Actor.UpdateVipHeight(self, VipAvatarHeight.wing)
	else
		Actor.AttachVipToAvatar(self)
		Actor.UpdateVipHeight(self, VipAvatarHeight.normal)
	end
  end
--]]
end

--初始化头顶
function Player:InitHead()
	 local tableinfo = {};
     for k,rankinfo in pairs(self.title) do
         local ishave = false;
         for _,infos in pairs(tableinfo) do
             if rankinfo.rankindex == infos.rankindex then
                 ishave = true;
             end
         end
		 if not ishave then
             table.insert(tableinfo,rankinfo);
         end
     end
     self.title = tableinfo;

  if self.uiHead == nil then
    self.uiHead = uiSystem:CreateControl('StackPanel');	
    self.uiHead.Pick = false;
    self.uiHead.Alignment = Alignment.Center;
    self.uiHead.AutoSize = true;
    self.uiHead.Scale = Vector2(0.8, 0.8);
    self.uiHead.Space = 1;

	local titleInfo = {};
	if self.title and #self.title > 0 then
		for _,info in pairs(self.title) do
			table.insert(titleInfo,info);
		end
		local sortFunc = function(a, b)
		   return a.rankindex < b.rankindex;
		end
		table.sort(titleInfo, sortFunc);

		--称号
		self.uiHead.title = uiSystem:CreateControl('CombinedElement');
		self.uiHead.title.Pick = false;
		self.uiHead.title.Alignment = Alignment.Center;
		--该枚举需要与服务器保持一致
		local ranktype = {
			['0'] = 'rank_fight1',
			['1'] = 'rank_arena1',
			['2'] = 'rank_yuan1',  
			['3'] = 'rank_role1',
			['4'] = 'rank_love1',
			['5'] = 'rank_lv1',
			['6'] = 'rank_fight2',
			['7'] = 'rank_arena2',
			['8'] = 'rank_yuan1',
			['9'] = 'rank_role2',
			['10'] = 'rank_love2',
			['11'] = 'rank_lv2',
		};
		for index = 1, 4 do
			if titleInfo[index] then
				self.uiHead.title[index] = uiSystem:CreateControl('ImageElement');
				if titleInfo[index].rankindex <= 5 then
					self.uiHead.title[index]:SetScale(0.95,0.95);
				end
				self.uiHead.title[index].Pick = false;
				self.uiHead.title[index].Image = uiSystem:FindImage(ranktype[tostring(titleInfo[index].rankindex)])
				self.uiHead.title:AddChild(self.uiHead.title[index]);
			end
		end
	end
	self.uiHead:AddChild(self.uiHead.title);

    --名字
    self.uiHead.nameline = uiSystem:CreateControl('CombinedElement');
    self.uiHead.nameline.Pick = false;
    self.uiHead.nameline.Alignment = Alignment.Center;
--[[
    if self.viplevel ~= nil and self.viplevel > 0 then
      self.uiHead.nameline.vip = vipToImage(self.viplevel);
      self.uiHead.nameline:AddChild(self.uiHead.nameline.vip);

      -- self.uiHead.nameline.vip = uiSystem:CreateControl('TextElement');
      -- self.uiHead.nameline.vip.Pick = false;
      -- self.uiHead.nameline.vip:SetFont('huakang_20');
      -- self.uiHead.nameline.vip.TextColor = Configuration.VipColor;
      -- self.uiHead.nameline.vip.Text = 'V' .. self.viplevel;
      -- self.uiHead.nameline:AddChild(self.uiHead.nameline.vip);
    end
--]]
    self.uiHead.nameline.uiName = uiSystem:CreateControl('TextElement');
    self.uiHead.nameline.uiName.Pick = false;
    self.uiHead.nameline.uiName:SetFont('huakang_24');
    self.uiHead.nameline.uiName:SetScale(0.8,0.8);
     --主角名字根据最低一件装备的颜色确定装
    --找到等级最低的装备
    local equip_lvl = 100
    if ActorManager.user_data.role.equips then
      for i=1, 5 do
        if ActorManager.user_data.role.equips[tostring(i)] then
          local equip_resid = ActorManager.user_data.role.equips[tostring(i)].resid
          local equip_rank = resTableManager:GetValue(ResTable.equip, tostring(equip_resid), 'rank')
          if equip_rank < equip_lvl then
            equip_lvl = equip_rank
          end
        end
      end
    end

    local index = Configuration:getNameColorByEquip(equip_lvl);    --  QualityColor在enum.lua文件中，前五种是白色，绿色，蓝色，紫色，金色
 --   self.uiHead.nameline.uiName.TextColor = QualityColor[self.rare];
    if self.name == GlobalData.RoleName then
      self.uiHead.nameline.uiName.TextColor = QualityColor[index];
	else
		index = Configuration:getNameColorByEquip(self.quality);
		self.uiHead.nameline.uiName.TextColor = QualityColor[index];
    end
	GlobalData.roleNameColor = QualityColor[index];
    self.uiHead.nameline.uiName.Text = self.name;
    self.uiHead.nameline:AddChild(self.uiHead.nameline.uiName);

     --段位称号
    self.uiHead.nameline.uiRank = uiSystem:CreateControl('ImageElement');
    self.uiHead.nameline.uiRank.Pick = false;
    -- self.uiHead.nameline.uiRank:SetFont('huakang_20');
    local rankName = resTableManager:GetValue(ResTable.rank_season,tostring(self.season_rank),'name');
    self.uiHead.nameline.uiRank:SetScale(1.2,1.2);
    if rankName and self.level >= FunctionOpenLevel.rankMatch then
      self.uiHead.nameline.uiRank.Image = GetPicture('rank/rank_season_' .. math.floor(self.season_rank/10) .. '.ccz');
    else
      self.uiHead.nameline.uiRank.Visibility = Visibility.Hidden;
    end
    --self.uiHead.nameline:AddChild(self.uiHead.nameline.uiRank);

    self.uiHead.unionName = uiSystem:CreateControl('TextElement');
    self.uiHead.unionName.Pick = false;
    self.uiHead.unionName:SetFont('huakang_24');
    self.uiHead.unionName.TextColor = QuadColor(Color(155, 255, 75, 255));
    self.uiHead.unionName.Text = '';
    self.uiHead.unionName.Translate = Vector2(0, 5);
    self.uiHead.unionName:SetScale(0.8,0.8);
    self.uiHead:AddChild(self.uiHead.unionName);
    self:updateHeadUnion();

    self.uiHead:AddChild(self.uiHead.nameline);
	bottomDesktop:AddChild(self.uiHead);
  end


end

function Player:RefreshRankName(rank)
  if self.uiHead.nameline.uiRank == nil then
    self.uiHead.nameline.uiRank = uiSystem:CreateControl('ImageElement');
    self.uiHead.nameline.uiRank.Pick = false;
    self.uiHead.nameline.uiRank:SetScale(1.2,1.2);
    -- self.uiHead.nameline.uiRank:SetFont('huakang_20');
    --self.uiHead.nameline:AddChild(self.uiHead.nameline.uiRank);
  end
  self.uiHead.nameline.uiRank.Image = GetPicture('rank/rank_season_' .. math.floor(rank/10) .. '.ccz');
end

--修改名字
function Player:RefreshName( name )
  self.name = name;
  self.uiHead.nameline.uiName.Text = name;
end

--修改名字颜色
function Player:ChangeNameColor()
	local equip_lvl = 100
    for i=1, 5 do
        local equip_resid = ActorManager.user_data.role.equips[tostring(i)].resid
        local equip_rank = resTableManager:GetValue(ResTable.equip, tostring(equip_resid), 'rank')
        if equip_rank < equip_lvl then
          equip_lvl = equip_rank
        end
    end
    local index = Configuration:getNameColorByEquip(equip_lvl)    --  QualityColor在enum.lua文件中，前五种是白色，绿色，蓝色，紫色，金色
 --   self.uiHead.nameline.uiName.TextColor = QualityColor[self.rare];
    self.uiHead.nameline.uiName.TextColor = QualityColor[index]
	print('GlobalData.roleNameColor' .. index)
    GlobalData.roleNameColor = QualityColor[index]
end

--修改vip
function Player:RefreshVipLevel( level )
  -- if self.uiHead.nameline.vip == nil then
    self.uiHead.nameline:RemoveAllChildren();

    --vip等级
    self.uiHead.nameline.vip = vipToImage(level);
    self.uiHead.nameline:AddChild(self.uiHead.nameline.vip);

    -- self.uiHead.nameline.vip = uiSystem:CreateControl('TextElement');
    -- self.uiHead.nameline.vip.Pick = false;
    -- self.uiHead.nameline.vip:SetFont('huakang_20');
    -- self.uiHead.nameline.vip.TextColor = Configuration.VipColor;
    -- self.uiHead.nameline:AddChild(self.uiHead.nameline.vip);

    --名字
    self.uiHead.nameline.uiName = uiSystem:CreateControl('TextElement');
    self.uiHead.nameline.uiName.Pick = false;
    self.uiHead.nameline.uiName:SetFont('huakang_24');
    self.uiHead.nameline.uiName:SetScale(0.8,0.8);
    -- self.uiHead.nameline.uiName.TextColor = QualityColor[self.rare];
    self.uiHead.nameline.uiName.Text = self.name;
    self.uiHead.nameline:AddChild(self.uiHead.nameline.uiName);
  -- end

  -- local font = uiSystem:FindFont('vipWhite');
  -- local bg = 'godsSenki.vip_bg_red';
  -- local vipRank = 'V' .. level;
  -- if level > 13 and level <= 17 then
  --   font = uiSystem:FindFont('vipYellow');
  --   vipRank = 'VV' .. level;
  --   bg = 'godsSenki.vip_bg_gold';
  -- elseif level > 9 then
  --   font = uiSystem:FindFont('vipBlack');
  --   vipRank = '5V' .. level;
  --   bg = 'godsSenki.vip_bg_sliver';
  -- elseif level > 0 then 
  --   font = uiSystem:FindFont('vipWhite');
  --   vipRank = 'V' .. level;
  --   bg = 'godsSenki.vip_bg_red';
  -- end
  -- self.uiHead.nameline.vip:SetScale(1.5,1.5);
  -- self.uiHead.nameline.vip.Background = Converter.String2Brush(bg);
  -- self.uiHead.nameline.vip.Font = font;
  
  -- self.uiHead.nameline.vip.Text = 'V' .. level;
end

function Player:GetAvatarName()
  return self.avatarName;
end

--========================================================================
--行走控制

function Player:ForceSetPosition( Pos )
  self.state = PlayerState.idle;
  self.targetPos = Pos;
  self:SetPosition(Convert2Vector3(Pos));
  self:SetAnimation(AnimationType.idle);
end

--移动
function Player:MoveTo( Pos, isKeepDirection )

  if self.targetPos == Pos then
    return;
  end

  local startPos = {
    x = self:GetPosition().x,
    y = self:GetPosition().y
  };


  if MainUI:GetSceneType() == SceneType.MainCity then
    self.path = PathFinder:findPath(startPos, Pos);
  else
    self.path = {Pos};
  end


  --做一次判断，如果已经在不可到达的点，就先回到地图中间再走。
  if MainUI:GetSceneType() == SceneType.MainCity then
    if not PathFinder:canStay(startPos) and not self.path and self.state == PlayerState.idle then -- 已经在不可达点上了。
      self:SetPosition( Vector3(202, 56, 0) );
      return;
    end
  end

  if not self.path then
    self.path = nil
    return;
  end

  self.targetPos = Pos;
  self.state = PlayerState.moving;

  self:SetAnimation(AnimationType.run);

  if (Pos.x == WOUBossPanel.x) and (Pos.y == WOUBossPanel.y) then
    --瞬间移动
    self:SetPosition(Vector3(Pos.x, Pos.y, Pos.y));
  end
end

--更新头顶
function Player:updateHead()

  --[[
  local scale = GlobalData.ActorScale;

  if MainUI:GetSceneType() == SceneType.FightScene then
    scale = GlobalData.ActorFightScale;
  end

  if (self.uiHead ~= nil) and (sceneManager.ActiveScene ~= nil) then
    local pos = self:GetPosition();
    local y = pos.y + self.bodyHeight * scale + self:getHeadUIYOffset();
    local uiPos = SceneToUiPT( sceneManager.ActiveScene.Camera, bottomDesktop.Camera, Vector3(pos.x, y, pos.z) );
    self.uiHead.Translate = uiPos;
    self.uiHead.ZOrder = Convert2ZOrder(pos.y);
  end
  --]]
  if (self.uiHead ~= nil) and (sceneManager.ActiveScene ~= nil) then
    local pos = self:GetPosition();
    local y = pos.y + self.bodyHeight * GlobalData.ActorScale + self:getHeadUIYOffset();
    local uiPos = SceneToUiPT( sceneManager.ActiveScene.Camera, bottomDesktop.Camera, Vector3(pos.x, y, pos.z) );
    self.uiHead.Translate = uiPos;
    self.uiHead.ZOrder = Convert2ZOrder(pos.y);
  end
end

--设置公会名
function Player:setUnionName(name)
  self.unName = name;
  self:updateHeadUnion();
end

--更新头顶公会
function Player:updateHeadUnion()
  if self.uiHead.unionName == nil then
    return;
  end

  if (MainUI:GetSceneType() == SceneType.MainCity or MainUI:GetSceneType() == SceneType.Union) and not string.isNilOrTemp(self.unName) then
    self.uiHead.unionName.Visibility = Visibility.Visible;	
    self.uiHead.unionName.Text = '【' .. self.unName .. '】';	
  else
    self.uiHead.unionName.Visibility = Visibility.Hidden;
  end
end

--获取头顶偏移
function Player:getHeadUIYOffset()

  if self.wingid == 0 and (self.uiHead.unionName == nil or self.uiHead.unionName.Visibility == Visibility.Hidden) then
    --无翅膀，无公会
    self.headUIYOffset = 10;
  elseif self.wingid ~= 0 and (self.uiHead.unionName == nil or self.uiHead.unionName.Visibility == Visibility.Hidden) then
    --有翅膀，无公会
    self.headUIYOffset = 20;
  elseif self.wingid == 0 and self.uiHead.unionName.Visibility ~= Visibility.Hidden then
    --无翅膀，有公会
    self.headUIYOffset = 30;
  else
    --有翅膀,有公会
    self.headUIYOffset = 40;
  end
  if self.title and #self.title > 0 then
	  self.headUIYOffset = self.headUIYOffset + 20;
  end
  return self.headUIYOffset;
end

--更新移动
function Player:updateMove( Elapse )

  if self.state == PlayerState.idle then
    return;
  end

  --如果当前正在自动寻路
  --

  local curPos3 = self:GetPosition();
  local curPos2 = Vector2(curPos3.x, curPos3.y);

  if self.path and #self.path > 0 then
    local node = self.path[1];
    self.targetPos = Vector2(node.x, node.y);
    if curPos2.x < self.targetPos.x then
      --朝右
      self:SetDirection(DirectionType.faceright);
    elseif curPos2.x > self.targetPos.x then
      --朝左
      self:SetDirection(DirectionType.faceleft);
    end
  end

  local dir = self.targetPos - curPos2;
  local length = dir:Normalise();

  local dis = self.moveSpeed * self.moveSpeedRatio * Elapse;

  if dis >= length  then
    --到达目标
    if self.path and #self.path > 0 then
      table.remove(self.path, 1);
    else
      self:SetPosition( Convert2Vector3(self.targetPos) );
      self:SetAnimation(AnimationType.idle);
      self.state = PlayerState.idle;
      self:MoveToTarget();
      PlotManager:FinishPlotStep(PlotStepType.npcMove, self.id);
    end
  else

    --没有到达，就移动
    dis = dir * dis;
    curPos2 = curPos2 + dis;
    self:SetPosition( Convert2Vector3(curPos2) );

  end

end

--到达目标
function Player:MoveToTarget()
end

--更新乱斗场英雄头顶状态(Hero和ScufflePlayer中使用)
function Player:UpdateScuffleHead()

  local cbPlayer = CombinedElement(self.uiHead:GetLogicChild('headList'):GetLogicChild('player'));

  --军衔
  local icon = BrushElement(cbPlayer:GetLogicChild('icon'));
  local rowNum = resTableManager:GetRowNum(ResTable.kof_rank_reward);
  for index = 1, rowNum do
    local rankData = resTableManager:GetRowValue(ResTable.kof_rank_reward, tostring(index));
    if self.winNum >= rankData['minround'] and self.winNum <= rankData['maxround'] then
      icon.Background = Converter.String2Brush( 'godsSenki.pvp_jx00' .. index );
      break;
    end
  end

  --等级
  local textLevel = TextElement(cbPlayer:GetLogicChild('level'));
  textLevel.Text ='';	
  local textName = TextElement(cbPlayer:GetLogicChild('name'));
  textName.TextColor = QualityColor[4];	
  --加空格使整体居中
  local num = math.random(1,10);
  textName.Text = LANG_scufflePanel_playername[num] .. '         ';

  local headY = 0;
  local textWin = TextElement(self.uiHead:GetLogicChild('headList'):GetLogicChild('win'));
  textWin.Visibility = Visibility.Hidden
  self.uiHead:GetLogicChild('headList').Translate = Vector2(0, 0);
--[[
  --胜利场次
  local textWin = TextElement(self.uiHead:GetLogicChild('headList'):GetLogicChild('win'));
  if self.winNum == 0 then
    textWin.Visibility = Visibility.Hidden;
    self.uiHead:GetLogicChild('headList').Translate = Vector2(0, 0);
  else
    textWin.Text = '<' .. self.winNum .. LANG_player_1 .. self.conWinNum .. LANG_player_2;
    textWin.Visibility = Visibility.Visible;
    --减去剩场的高度
    headY = headY - 21;
  end
]]
  --是否战斗中
  local arm = ArmatureUI( self.uiHead:GetLogicChild('headList'):GetLogicChild('effect'));
  if ScuffleFightStatus.yes == self.inBattle then
    arm.Visibility = Visibility.Visible;
  else
    arm.Visibility = Visibility.Hidden;
    headY = headY + 36;
  end

  self.uiHead:GetLogicChild('headList').Translate = Vector2(0, headY);

end
function Player:Hit(PT)

	return self:GetActorBoundBox():Contain(PT);
end
--========================================================================
--伤害

