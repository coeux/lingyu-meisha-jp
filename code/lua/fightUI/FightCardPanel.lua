--FightCardPanel

--========================================================================
--卡牌面板

FightCardPanel = {

}

function FightCardPanel:Initialize(desktop)
   self.desktop = desktop;
   self.actorList = FightManager.needleftActorList;
   self.playerPanel = self.desktop:GetLogicChild('FightCardPanel');
   self.playerStack = self.playerPanel:GetLogicChild('playerStack');
   self.playerStack:RemoveAllChildren();
   --计算屏幕适配值
   self:FixScreen();
   self.items = self:CreateItems();

   -- 初始化血条
   for _, actor in ipairs(self.actorList) do
      self:UpdateHp(actor);
   end
end

function FightCardPanel:FixScreen()
   local screenWidth = self.desktop.Size.width;
   local actorCount = #self.actorList
   local space = (screenWidth - actorCount * 162 - 115) / (actorCount+1);
   self.playerStack.Space = space;
   self.playerPanel.Margin = Rect(space, 0, 0, 0);
end


function FightCardPanel:GetItem(fid)
   local item = self.items[fid];
   return item;
end

function FightCardPanel:CreateItems()
   local items = {}
   local teamRoles = {};
   for i = #self.actorList , 1 , -1 do
      table.insert(teamRoles,self.actorList[i]);
   end
   for _, v in pairs(teamRoles) do
      local id = v.id;
      local item = self:createActorItem(v);
      items[id] = item;
   end
   return items;
end

function FightCardPanel:Update(elapse)
end

function FightCardPanel:Destroy()
end

function FightCardPanel:createActorItem(actor)
   local panel = uiSystem:CreateControl('PlayerTemplate')
   panel.Pick = false;

   local naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(actor.resID));
   local naviImage = naviInfo['role_path_list'];

   local head_img = CreateTextureBrush('navi/' .. naviImage .. '.ccz', 'fight');

   panel.actor = actor;

   panel.left = panel:GetLogicChild(0):GetLogicChild('left');
   panel.right = panel:GetLogicChild(0):GetLogicChild('right');
   panel.hpbar = panel:GetLogicChild(0):GetLogicChild('hpbar');
   panel.bg = panel:GetLogicChild(0):GetLogicChild('bg');
   panel.bg.Background = head_img;
   panel.bg.Pick = false;
   panel.hpbar.ForwardBrush = CreateTextureBrush('fight/player_hp.ccz', 'fight');
   panel.hpbar.Background = CreateTextureBrush('fight/player_hp_bg.ccz', 'fight');
   --mask: 00, 01, 10, 11 代表左右两个卡槽是否放卡
   panel.mask = 0;

   -- 适配
   if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
      local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
      panel:SetScale(factor,factor);
      panel.Translate = Vector2(162*(1-factor)/2,210*(1-factor)/2);
   end
   self.playerStack:AddChild(panel);
   return panel;
end

function FightCardPanel:IsCardFull(fid)
   local item = self.items[fid];
   if item == nil then
      debug.assert(false, "[isCardFull]fighter not found")
   end

   if item.mask == 3 then
      return true;
   else
      return false
   end
end

function FightCardPanel:GetValidFighters()
   local fighters = {};
   for _, v in pairs(self.items) do
      if v.mask ~= 3 then
         table.insert(fighters, v)
      end
   end
   return fighters;
end

function FightCardPanel:RemoveCard(card)
   local item = self:GetItem(card.info.actor.id);
   local sideChild = nil;
   if card.side == CardSide.Left then
      sideChild = item.left;
      item.mask = item.mask - 2;
   else
      sideChild = item.right;
      item.mask = item.mask - 1;
   end
   sideChild:RemoveChild(card);
end

function FightCardPanel:CanGetCard(fid)
   local item = self.items[fid];
   if item == nil then
      return false;
   end

   if item.mask == 3 then
      return false;
   end
end

function FightCardPanel:SetCard(fid, card)
   local item = self.items[fid];
   if item == nil then
      return false;
   end

   if item.mask == 3 then
      return false;
   end

   if item.mask < 2 then --左边没有卡， 00 or 01
      item.left:AddChild(card);
      item.mask = item.mask + 2;  -- 10 or 11
      card.side = CardSide.Left;
   else                  --左边有卡，一定是 10
      item.right:AddChild(card);
      item.mask = item.mask + 1;  -- 11;
      card.side = CardSide.Right;
   end


   local board = card:SetUIStoryBoard('storyboard.CardFlyIn');
   board:SubscribeScriptedEvent('StoryboardInstance::FinishedEvent', "FightCardPanel:GuideEvent");
   -- card.Storyboard = "storyboard.CardFlyIn";
  
   return true;
end

--非特殊情况不要轻易添加,容易引起技能释放问题
function FightCardPanel:GuideEvent()
	if FightManager.barrierId == 1001 and ActorManager.user_data.userguide.isnew == 0 and FightHandSkillManager.isFirstCard then
      FightManager:FightPauseGame()
      --FightSkillCardManager:guideCradClick(1, LANG_GUIDE_CONTENT_1);
      --FightSkillCardManager:guideCradClick(1, LANG_GUIDE_CONTENT_10);
      --FightSkillCardManager.guideCardClick = true;
      PlotPanel:showContent();
      PlotPanel:changeContentPos(0,-30);
      PlotPanel:changeContentText( LANG_GUIDE_CONTENT_10 );
      PlotPanel:setContentClickEvent();
	end
--[[
	if FightManager.barrierId == 1001 and ActorManager.user_data.userguide.isnew == 0 and FightHandSkillManager.isSecondCard then
        FightManager:FightPauseGame()
        FightSkillCardManager:guideCradClick(1, LANG_GUIDE_CONTENT_8);
        FightSkillCardManager.guideCardClick = true;
    end
--]]
	if FightManager.barrierId == 1004 and ActorManager.user_data.userguide.isnew == GuideIndexExt.belove2 and FightHandSkillManager.isFirstCard then
        FightManager:FightPauseGame()
        FightSkillCardManager:guideCradClick(1, LANG_GUIDE_CONTENT_1);
        FightSkillCardManager.guideCardClick = true;
    end
	--[[
	if FightManager.barrierId == 1004 and ActorManager.user_data.userguide.isnew == 9 and FightHandSkillManager.isSecondCard then
        FightManager:FightPauseGame()
		FightManager:playSelectArmature(3009, LANG_GUIDE_CONTENT_4);
        FightSkillCardManager.guideCardClick = true;
    end
	]]  
   if FightManager.barrierId == 1002 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2 and FightHandSkillManager.isSecondCard then
   	local handSkill = FightSkillCardManager:getHandSkillList();
				for i=1,#handSkill do
					if handSkill[i].skill_resid == 302 then
						FightManager:Pause();
						FightSkillCardManager:guideCradClick(i, LANG_GUIDE_CONTENT_2);
						break;
					end
				end
				FightSkillCardManager.guideCardClick = true; 
    end  
end

function FightCardPanel:Show()
   self.playerStack.Visibility = Visibility.Visible;
end

function FightCardPanel:Hide()
   self.playerStack.Visibility = Visibility.Hidden;
end

function FightCardPanel:UpdateHp(fighter)
   local item = self:GetItem(fighter.id);
   if item then
      local max = fighter:GetMaxHP();
      local cur = fighter:GetCurrentHP();
      item.hpbar.MaxValue = max;
      item.hpbar.CurValue = cur;

   end
end

function FightCardPanel:SetPlayerDie(fighter)
   local item = self:GetItem(fighter.id);
   if item then
      item.Enable = false;
   end
end

function FightCardPanel:AddShining(card)
   --前三关战斗引导没有完成前，不增加闪光特效，完成第三关战斗引导后isnew = 9
   if ActorManager.user_data.userguide.isnew < GuideIndexExt.belove2 then
      return;
   end
   if card and not FightManager.isAuto then
      card.shining = PlayEffectScale("lianji_output/", Rect(-11, 11, 0, 0), "lianji", 2, 2,  card);
      card.isShining = true;
   end

end

function FightCardPanel:RemoveShining(card)
   if card and card.shining then
      card:RemoveChild(card.shining);
      card.isShining = false;
   end

end

function FightCardPanel:clearArm()
	for _, v in pairs(self.items) do
		local panel_arm;
		if not v:GetLogicChild("arm") then
			panel_arm = uiSystem:CreateControl('Panel');
			panel_arm.Horizontal = ControlLayout.H_CENTER;
			panel_arm.Vertical = ControlLayout.V_CENTER;
			panel_arm.Name = "arm";
			panel_arm.ZOrder = -500;
			v:AddChild(panel_arm);
		else
			panel_arm = v:GetLogicChild("arm");
			panel_arm:RemoveAllChildren();
		end
	end
end

function FightCardPanel:initPhase()
	for _, v in pairs(self.items) do
		if not v.phase then
			v.phase = -1;
		end		
	end
end

function FightCardPanel:clearPhase()
	for _, v in pairs(self.items) do
		v.phase = -1;
	end
end

function FightCardPanel:skillCastCheck(actor, phase)
	local panel = self.items[actor.id];
	if phase == -1 then
		return;
	end
	self:initPhase();
	if phase == panel.phase then
		return;
	end
	self:clearArm();
	self:clearPhase();

	local panel_arm = panel:GetLogicChild("arm");

	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/skill_check_1_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/skill_check_2_output/');
	armatureManager:LoadFile(GlobalData:GetResDir() .. 'resource/animation/skill_check_3_output/');
	local oneArm = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	oneArm.Horizontal = ControlLayout.H_CENTER;
	oneArm.Vertical = ControlLayout.V_CENTER;
	oneArm:LoadArmature('skill_check_' ..tostring(phase));
	oneArm:SetAnimation('play');
	oneArm:SetScale(1.1,1.1);
	oneArm.Visibility = Visibility.Visible;
	oneArm.ZOrder = -500;
	panel_arm:AddChild(oneArm);
	panel.phase = phase;
end
