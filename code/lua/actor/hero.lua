--hero.lua

--========================================================================
--依赖

LoadLuaFile("lua/actor/player.lua");

--========================================================================
--本地英雄类

Hero = class(Player)


function Hero:constructor( id, resID )
	
	--========================================================================
	--属性相关

	self.scene = nil;				--所属场景

	--========================================================================

end

--更新
function Hero:Update( Elapse )

	--基类更新
	Player.Update(self, Elapse)

end

--========================================================================

--初始化
function Hero:InitData( data )

	local weapon = data.equips[EquipmentPos.weapon];
	if weapon ~= nil then
		self.weaponid = weapon.resid;
	else
		self.weaponid = 0;
	end

	self.name = ActorManager.user_data.name;
	self.rare = data.rare;
	self.title = ActorManager.user_data.userguide.rankinfo;
	self.viplevel = ActorManager.user_data.viplevel;
	self.findPathType = FindPathType.no;
	self.season_rank = data.season_rank;
	self.viptype = data.viptype;
	self.level = ActorManager.user_data.role.lvl.level;

	--初始化翅膀id
	local wingData = ActorManager.user_data.role.wings;
	if (wingData ~= nil) and (#wingData > 0) then
		self.wingid = wingData[1].resid;
	end
	self.have_pet = ActorManager.user_data.role.have_pet;
	if self.have_pet then
		self.petid = ActorManager.user_data.role.pet.resid;
	end
end

--初始化头顶,乱斗场的带n_win和n_con_win，其他的没有
function Hero:InitHead(n_win, n_con_win)
	bottomDesktop:RemoveChild(self.uiHead);
	self.uiHead = nil;
	if n_win ~= nil and n_con_win ~= nil then
		self:InitScuffleHead(n_win, n_con_win);
	else
		Player.InitHead(self);
	end
	
end

--初始化乱斗场英雄头顶
function Hero:InitScuffleHead(n_win, n_con_win)
	--胜利场次
	self.winNum = n_win;
	--连胜场次
	self.conWinNum = n_con_win;
	--战斗状态
	self.inBattle = ScuffleFightStatus.no;
	
	--英雄等级
	self.level = self:GetLevel();
	
	local t = uiSystem:CreateControl('scufflePlayerTemplate');
	self.uiHead = StackPanel(t:GetLogicChild(0));
	bottomDesktop:AddChild(self.uiHead);
	local arm = ArmatureUI( self.uiHead:GetLogicChild('headList'):GetLogicChild('effect'));
	arm:LoadArmature('zhandouzhong');
	arm:SetAnimation('play');
	self:UpdateScuffleHead();
end

function Hero:UpdateScuffleInfo(n_win, n_con_win, in_battle)
	--胜利场次
	self.winNum = n_win;
	--连胜场次
	self.conWinNum = n_con_win;
	--战斗状态
	self.inBattle = in_battle;
	
	self:UpdateScuffleHead();
end

--设置向公会NPC移动
function Hero:SetFindPathType(flag)
	self.findPathType = flag;
end

--========================================================================
--属性

--获取等级
function Hero:GetLevel()
	return ActorManager.user_data.role.lvl.level;
end

--功能点是否点击过
function Hero:IsFunctionFirstClick( pos )
	return bit.band(ActorManager.user_data.func, pos) == 0;
end

--设置功能点击
function Hero:SetFunctionFirstClick( pos )
	ActorManager.user_data.func = bit.bor(ActorManager.user_data.func, pos);
	return ActorManager.user_data.func;
end

--修改名字
function Hero:ChangeName()
	self.name = ActorManager.user_data.name;
	self.uiHead.nameline.uiName = QualityColor[self.rare];
end

--========================================================================
--行走控制

--更新头顶
function Hero:updateHead()

	if self.uiHead ~= nil then
		local pos = self:GetPosition();
		local y = pos.y + self.bodyHeight * GlobalData.ActorScale + self:getHeadUIYOffset();
		local uiPos = SceneToUiPT( sceneManager.ActiveScene.Camera, bottomDesktop.Camera, Vector3(pos.x, y, pos.z) );
		self.uiHead.Translate = uiPos;
		self.uiHead.ZOrder = GlobalData.MainSceneLogicHeight;
	end
end

--设置位置
function Hero:SetPosition( pos )

	--人物移动
	Actor.SetPosition(self, pos);
	
	--场景相机及物件移动
	if self.scene ~= nil then
		local lastPos = self:GetCppObject().Translate;
		local deltaX = pos.x - lastPos.x;
		local deltaY = pos.y - lastPos.y;
		--print('pos.x->'..pos.x..' -lastPos.x->'..lastPos.x..' -pos.y->'..pos.y..' -lastPos.y->'..lastPos.y);
		self.scene:MoveScene(pos, deltaX, deltaY);
	end

	MainUI:SetHeroPos(pos);

end

function Hero:IsFindingWay()
  if not self.path then 
    return false
  else
    return #self.path > 0
  end
end
function Hero:SetScuffleRevivePostion(pos)
	local camera = self.scene:GetCamera();
	local cameraPos = camera.Translate;
	
	local width = camera.ViewFrustum.Right;
	local sceneWidth = self.scene.width*0.5;
	local x = pos.x;
	if x > 0 then
		camera.Translate = Vector3(sceneWidth-width, cameraPos.y, cameraPos.z);
	else
		camera.Translate = Vector3(width-sceneWidth, cameraPos.y, cameraPos.z);
	end
	--设置位置
	Actor.SetPosition(self, pos);
	--print('SetScuffleRevivePostion------------->');
end
--设置开始位置
function Hero:SetStartPosition( pos )

	--判断相机位置
	local camera = self.scene:GetCamera();
	local cameraPos = camera.Translate;

	local width = camera.ViewFrustum.Right;		--屏宽度的一半
	local height = - camera.ViewFrustum.Bottom;		--屏宽度的一半
	local sceneWidth = self.scene.width * 0.5;
	local sceneHeight = self.scene.height * 0.5;
	local x = pos.x;	
	local y = pos.y;	
	--print('width->'..width..' height->'..height)
	if x > 0 then
		if x + width > sceneWidth  then
			x = sceneWidth - width;
		end
	else
		if x - width < -sceneWidth then
			x = width - sceneWidth;
		end
	end

	if y > 0 then
		if y + height > sceneHeight  then
			y = sceneHeight - height;
		end
	else
		if y - height < -sceneHeight then
			y = height - sceneHeight;
		end
	end
	
	camera.Translate = Vector3(x, y, cameraPos.z);
	
	--设置位置
	Actor.SetPosition(self, pos);

end

--停止移动
function Hero:StopMove()
	self:SetAnimation(AnimationType.idle);
	self.state = PlayerState.idle;
	self.findPathType = FindPathType.no;
	
	local curPos = self:GetPosition();
	self.targetPos = Vector2(curPos.x, curPos.y);
end

--到达目标
function Hero:MoveToTarget()
	if MainUI:GetSceneType() == SceneType.MainCity then
		if FindPathType.npc == self.findPathType then
			TaskDialogPanel:onShowDialog();
		elseif FindPathType.union == self.findPathType then
			MainUI:RequestUnionScene();
		elseif FindPathType.npcshop == self.findPathType then
			-- NpcShopPanel:OpenNormalClick();
			ShopSetPanel:show(ShopSetType.mysteryShop)
		elseif FindPathType.worboss == self.findPathType then
			MainUI:onWorldClick();
		end
		TaskFindPathPanel:Hide();
	elseif MainUI:GetSceneType() == SceneType.Union then
		if FindPathType.union == self.findPathType then
			if UnionDialogPanel:GetNpcID() == 907 then
				Network:Send(NetworkCmdType.req_union_battle_state,{}) --社团战状态请求
			else
				UnionDialogPanel:onShow();
			end
		end
	elseif (MainUI:GetSceneType() == SceneType.WorldBoss) or (MainUI:GetSceneType() == SceneType.UnionBoss) then
		WOUBossPanel:BeginAutoMove();
	end
end

function Hero:MoveTo(pos, isKeepDirection)
	if CityPersonInfoPanel:isShow() then
		CityPersonInfoPanel:Hide()
	end
	Player.MoveTo(self, pos, isKeepDirection);	
end	
