--actor.lua

--========================================================================
--角色类

Actor = class();


function Actor:constructor( id, resID )

  --========================================================================
  --属性相关

  self.id				= id;						--ID
  self.resID 			= resID;					--角色ID

  self.animationID	= AnimationType.none;		--动作ID
  self.faceDir		= DirectionType.faceright;	--朝向
  self.shadow			= 0;
  self.armature		= sceneManager:CreateSceneNode('Armature');		--动画
  self.armature:IncRefCount();

  self.wingArmatures	= {};						--翅膀
  self.petArmatures = {};

  self.isAnimationPause = false;					--动画是否被暂停
  --========================================================================

end

--销毁
function Actor:Destroy()
  if self.uiHead ~= nil then
    bottomDesktop:RemoveChild(self.uiHead);
    self.uiHead = nil;
  end

  ActorManager:DestroyActor( self:GetID() );
  ActorManager:DestroyMainCityActor(self:GetID())
  self.armature:DecRefCount();
  self.armature = nil;
  self.wingArmatures = {};
  self.petArmatures = {};
end

--更新
function Actor:Update( Elapse )
end

--========================================================================
--属性

--id
function Actor:GetID()
  return self.id;
end

--resID
function Actor:GetResID()
  return self.resID;
end

--名字
function Actor:GetName()
  return self.name;
end

function Actor:SetName( name )
  self.Name = name;
end

--c++对象
function Actor:GetCppObject()
  return self.armature;
end

--动作暂停
function Actor:PauseAction(flag)
  if self.armature == nil then
    Debug.print("PauseAction: Error! " .. self.id);
    return;
  end

  if (self.animationID == AnimationType.death) then
    return;
  end

  self.isAnimationPause = true;
  self.armature:Pause(flag);
end

--动作暂停
function Actor:ContinueAction()
  if self.armature == nil then
    Debug.print("ContinueAction: Error! " .. self.id);
    return;
  end

  self.isAnimationPause = false;
  self.armature:Continue();
end

--动作是否暂停
function Actor:IsAnimationPause()
  return self.isAnimationPause;
end

--设置朝向
function Actor:SetDirection( dir )

  if self.faceDir == dir then
    return;
  end

  self.faceDir = dir;
  local armature = self:GetCppObject();
  local scale = armature.Scale;

  if dir == DirectionType.faceleft then
    armature.Scale = Vector3( -Math.Abs(scale.x), scale.y, scale.z );
  else
    armature.Scale = Vector3( Math.Abs(scale.x), scale.y, scale.z );
  end

end

--获取朝向
function Actor:GetDirection()
  return self.faceDir;
end

--获取位置
function Actor:GetPosition()
  if self.armature == nil then
    Debug.print("GetPosition: Error! " .. self.id);
    return Vector3(0, 0, 0);
  end

  return self:GetCppObject().Translate;
end

--设置位置
function Actor:SetPosition( pos )
  if self.armature == nil then
    Debug.print("SetPosition: Error! " .. self.id);
    return;
  end

  self:GetCppObject().Translate = pos;
  self:GetCppObject().ZOrder = Convert2ZOrder(pos.y);
end

--设置缩放
function Actor:SetScale( X, Y )
  local armature = self:GetCppObject();
  if self.faceDir == DirectionType.faceleft then
    armature.Scale = Vector3(-X, Y, 1);
  else
    armature.Scale = Vector3(X, Y, 1);
  end
end

--设置旋转
function Actor:SetRotation( Angle )
  self:GetCppObject():SetRotation(Degree(Angle), Vector3.UNIT_Z);
end

--获取挂点
function Actor:GetBone( name )
  return self.armature:GetBone(name);
end

--获取挂点位置
function Actor:GetBonePos( name )
  return self.armature:GetBonePos(name);
end

--获取挂点世界位置
function Actor:GetBoneAbsPos( name )
  return self.armature:GetBoneAbsPos(name);
end

--挂特效
function Actor:AttachEffect( avatarPos, effect )
  if self.armature == nil then
    Debug.print("AttachEffect: Error! " .. self.id);
    return;
  end

  return self.armature:AttachEffect(avatarPos, effect);
end

--卸载特效
function Actor:DetachEffect(effect)
  if self.armature == nil then
    Debug.print("DetachEffect: Error! " .. self.id);
    return;
  end

  return self.armature:DetachEffect(effect);
end

--卸载所有特效
function Actor:DetachAllEffect()
  if self.armature == nil then
    Debug.print("DetachAllEffect: Error! " .. self.id);
    return;
  end

  self.armature:DetachAllEffect();
end

--挂接翅膀
function Actor:AttachWing(wingResid)
	--卸载当前身上的翅膀
	Actor.DettachWing(self);

	local wingType = resTableManager:GetValue(ResTable.wing, tostring(wingResid), 'type') or 23001;

	if WingType.w1_101 == wingType then
		armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/wing_output/');
		self:AttachWingToAvatar(AvatarPos.head_wing, 'wing01_halo');
	elseif WingType.w1_201 == wingType then
		armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/wing_output/');
		self:AttachWingToAvatar(AvatarPos.head_wing, 'wing01_halo');
		self:AttachWingToAvatar(AvatarPos.head_wing, 'wing01_head_right_1');
		self:AttachWingToAvatar(AvatarPos.head_wing, 'wing01_head_left_1');
	elseif WingType.w1_301 == wingType then
		armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/wing_output/');
		self:AttachWingToAvatar(AvatarPos.head_wing, 'wing01_halo');
		self:AttachWingToAvatar(AvatarPos.head_wing, 'wing01_head_right_1');
		self:AttachWingToAvatar(AvatarPos.head_wing, 'wing01_head_left_1');
		self:AttachWingToAvatar(AvatarPos.right_up_wing, 'wing01_up_right_1');
		self:AttachWingToAvatar(AvatarPos.left_up_wing, 'wing01_up_left_1');
	elseif WingType.w1_401 == wingType then
		armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/wing_output/');
		self:AttachWingToAvatar(AvatarPos.head_wing, 'wing01_halo');
		self:AttachWingToAvatar(AvatarPos.head_wing, 'wing01_head_right_1');
		self:AttachWingToAvatar(AvatarPos.head_wing, 'wing01_head_left_1');
		self:AttachWingToAvatar(AvatarPos.right_up_wing, 'wing01_up_right_2');
		self:AttachWingToAvatar(AvatarPos.left_up_wing, 'wing01_up_left_2');
		self:AttachWingToAvatar(AvatarPos.right_down_wing, 'wing01_down_right_2');
		self:AttachWingToAvatar(AvatarPos.left_down_wing, 'wing01_down_left_2');
	elseif WingType.w1_501 == wingType then
		armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/wing_output/');
		self:AttachWingToAvatar(AvatarPos.head_wing, 'wing01_halo');
		self:AttachWingToAvatar(AvatarPos.head_wing, 'wing01_head_right_2');
		self:AttachWingToAvatar(AvatarPos.head_wing, 'wing01_head_left_2');
		self:AttachWingToAvatar(AvatarPos.right_up_wing, 'wing01_up_right_3');
		self:AttachWingToAvatar(AvatarPos.left_up_wing, 'wing01_up_left_3');
		self:AttachWingToAvatar(AvatarPos.right_down_wing, 'wing01_down_right_texiao');
		self:AttachWingToAvatar(AvatarPos.left_down_wing, 'wing01_down_left_texiao');
		self:AttachWingToAvatar(AvatarPos.right_down_wing, 'wing01_down_right_3');
		self:AttachWingToAvatar(AvatarPos.left_down_wing, 'wing01_down_left_3');
	elseif WingType.w1_601 == wingType then
		armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/wing_output/');
		self:AttachWingToAvatar(AvatarPos.head_wing, 'wing01_halo');
		self:AttachWingToAvatar(AvatarPos.head_wing, 'wing01_head_right_5');
		self:AttachWingToAvatar(AvatarPos.head_wing, 'wing01_head_left_5');
		self:AttachWingToAvatar(AvatarPos.right_up_wing, 'wing01_up_right_5');
		self:AttachWingToAvatar(AvatarPos.left_up_wing, 'wing01_up_left_5');
		self:AttachWingToAvatar(AvatarPos.right_down_wing, 'wing01_down_right_texiao');
		self:AttachWingToAvatar(AvatarPos.left_down_wing, 'wing01_down_left_texiao');

		--特效特殊处理
		if wingResid == 23055 then
			self:AttachWingToAvatar(AvatarPos.left_down_wing, 'wing01_left_texiao_1');
			self:AttachWingToAvatar(AvatarPos.right_down_wing, 'wing01_right_texiao_1');
		end

		self:AttachWingToAvatar(AvatarPos.right_down_wing, 'wing01_down_right_4');
		self:AttachWingToAvatar(AvatarPos.left_down_wing, 'wing01_down_left_4');

		--特效特殊处理
		if wingResid == 23055 then
			self:AttachWingToAvatar(AvatarPos.left_up_wing, 'wing01_left_texiao_2');
			self:AttachWingToAvatar(AvatarPos.right_up_wing, 'wing01_right_texiao_2');
		end
	end
end

--挂载某个翅膀
function Actor:AttachWingToAvatar(avatarPos, avatarName)
  local wing = sceneManager:CreateSceneNode('Armature');
  wing:LoadArmature(avatarName);
  wing:SetAnimation('play');
  self.armature:AttachEffect(avatarPos, wing, true);
  if self.wingArmatures[avatarPos] == nil then
    self.wingArmatures[avatarPos] = {};
  end
  table.insert(self.wingArmatures[avatarPos], wing);
end

--挂载宠物
function Actor:AttachPet(petResid)
	--卸载当前身上的宠物
	self:DettachPet();

	local pet_arm_name = resTableManager:GetValue(ResTable.pet, tostring(petResid), 'animation');
	--TODO
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/pet_1_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/pet_2_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/pet_3_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/pet_4_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/pet_5_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/pet_6_output/');
	if (self.wingid and self.wingid > 23035) then
		self:AttachPetToAvatar(AvatarPos.pet_wing, pet_arm_name);
	else
		self:AttachPetToAvatar(AvatarPos.pet_no_wing, pet_arm_name);
	end
end

--挂载宠物的一部分
function Actor:AttachPetToAvatar(avatarPos, avatarName)
	local pet = sceneManager:CreateSceneNode('Armature');
	pet:LoadArmature(avatarName);
	pet:SetAnimation('play');
	local scale = pet.Scale;
	pet.Scale = Vector3( scale.x*1.4, scale.y*1.4, scale.z );
	self.armature:AttachEffect(avatarPos, pet, true);
	if self.petArmatures[avatarPos] == nil then
		self.petArmatures[avatarPos] = {};
	end
	table.insert(self.petArmatures[avatarPos], pet);
end

--高级vip特殊显示
function Actor:AttachVipToAvatar()
--[[
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/effect/danke_output/');
	local vip = sceneManager:CreateSceneNode('Armature');
	vip:LoadArmature('danke');
	vip.AlwaysTop = true;
	
	--vip.Scale = Vector3(1, 1, 1)
	vip:SetAnimation('play');
	vip.ZOrder = 30000; 
	self.armature:AddChild(vip);
	self.vipinfo = vip;
	--]]
end

function Actor:UpdateVipHeight(height)
	if self.vipinfo and self.armature then
		self.vipinfo.Translate = Vector3(0, height, 0)
	end
end

--去掉翅膀
function Actor:DettachWing()
  for k, pos in pairs(self.wingArmatures) do
    for _, wing in pairs(pos) do
      self.armature:DetachEffect(wing);
    end
  end
  self.wingArmatures = {};
end

--去掉宠物
function Actor:DettachPet()
	for k, pos in pairs(self.petArmatures) do
		for _, pet in pairs(pos) do 
			self.armature:DetachEffect(pet);
		end
	end
	self.petArmatures = {};
end

--设置颜色
function Actor:SetColor( color )
  self.armature:SetColor(color);
end

--设置阴影
function Actor:SetShadow( shadowID )
  --[[
    self.shadow = Sprite( sceneManager:CreateSceneNode('Sprite') );
    self.shadow:SetImage(GlobalData.OtherPath .. 'shadow' .. shadowID .. '.ccz', Configuration.ShadowSize[shadowID] );
    self.shadow.ZOrder = -200;	--影子在最后面
    self:GetCppObject():AddChild(self.shadow);
    self:GetCppObject():SortChildren();
  --]]
end

--移除阴影
function Actor:RemoveShadow()
  --[[
    if self.shadow ~= nil then
    self:GetCppObject():RemoveChild(self.shadow);
    self.shadow = nil;
    end
  --]]
end

--获取边界区域
function Actor:GetBoundBox()
  local pos = self:GetPosition();
  return Rect( Vector2(pos.x - self.bodyWidth * 0.5, pos.y), Size(self.bodyWidth, self.bodyHeight) );
end

function Actor:GetActorBoundBox()
  local pos = self:GetPosition();
  return Rect( Vector2(pos.x - self.bodyWidth * 0.3, pos.y), Size(self.bodyWidth*0.6, self.bodyHeight*0.7) );
end

--点击测试
function Actor:Hit( PT )
  return false;
end

--碰撞测试
function Actor:AreaCollision( area )
  return false;
end

--========================================================================
--动作

--加载Armature
function Actor:LoadArmature( fileName )
  self.armature:LoadArmature(fileName);
  self.armature:SetScriptAnimationCallback('actorAnimationEnd', self:GetID());
end

--测试是否包含动作
function Actor:IsHaveAnimation( name )
  return self.armature:IsHaveAnimation(name);
end

--获得当前动作id
function Actor:GetAnimationID()
  return self.animationID;
end


--设置动作
function Actor:SetAnimation( id, timeScale )
  if self.armature == nil then
    Debug.print("SetAnimation: Error! " .. self.id);
    return;
  end

  --动作相同
  if self.animationID == id then
    return;
  end

  --死亡动作不能被别的动作替换
  if (self.animationID == AnimationType.death) then
    return;
  end

  self.animationID = id;

  if timeScale == nil then
    timeScale = -1;		--默认使用配置文件缩放
  end

  if self.armature:IsHaveAnimation(id) then
    self.armature:SetAnimation(id, timeScale);
    return;
  end

  --不包含动作则按规则匹配
  if id == AnimationType.idle then
    self.armature:SetAnimation(AnimationType.f_idle, timeScale);
  elseif id == AnimationType.run then
    self.armature:SetAnimation(AnimationType.f_run, timeScale);
  elseif id == AnimationType.skill then
    self.armature:SetAnimation(AnimationType.attack, timeScale);
  elseif id == AnimationType.win then
    self.armature:SetAnimation(AnimationType.f_idle, timeScale);
  else
    -- print(LANG_actor_1 .. id);
  end

end

--动作结束
function actorAnimationEnd( armature, id )

  if armature:IsCurAnimationLoop() then
    --循环动作
    armature:Replay();
    return;
  end

  --不循环，设置待机动作
  local actor = ActorManager:GetActor(id);
  if actor ~= nil then
    actor:SetAnimation(AnimationType.idle);
  end

end
