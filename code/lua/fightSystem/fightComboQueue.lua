--fightComboQueue.lua
--========================================================================
--========================================================================
--Á¬»÷ÏµÍ³¶ÓÁÐ
FightComboQueue =
   {
      p_skill_count = 0;
      curComboNum   = 1;
      isTragger     = true;
      isStop = false;
   };

local QueueStatus = {
   SkillCasting = 1,
   SkillOver    = 2,
   CardCounter  = 3,
   ComboOver	 = 4,
   CardCombo	 = 5,
}

local SkillStatus = {
   PreRelease = 1,
   Counter	   = 2,
   Combo      = 3,
   Releasing  = 4,
   Finish     = 5,
}

local CounterStatus = {
   PreCounter = 1,
   Waiting	   = 2,
   Counted	   = 3,
   Finish	   = 4,
}

local ComboStatus = {
   PreCombo   = 1,
   Waiting	   = 2,
   Comboed	   = 3,
   Finish	   = 4,
}

--TODO
local COMBOFONT1 = 'combo1';
local COMBOFONT2 = 'combo2';
local COMBOFONT3 = 'combo3';
local TIME_MAX = 20;
local comboEffect = {};

local guideindex = 1

local cnState = {
   "daodi","jitui","xuanyun","fukong","zhongshang","wu","wu"
}
local skillCastType = 0;
local can_counter;
local can_combo;

--[[
   ¼¼ÄÜ³Ð½Ó×´Ì¬ÒÔ¼°Òý·¢×´Ì¬¸ñÊ½£º
   {
   caster,
   stateCause,
   stateResult,
   comboNum, --Èç¹ûÊÇÁ¬»÷£¬ÄÇÃ´Á¬»÷µÄ¸öÊýÊÇ¶àÉÙ,
   combo,    --´øÀ´µÄÁ¬»÷Êý,
   }

--]]
local leftPursuitSkillList;
local leftStartSkillList;
local leftCounterSkillList;
local leftComboSkillList;

local rightPursuitSkillList;
local rightStartSkillList;
local rightCounterSkillList;
local rightComboSkillList;

local AILevel = 3;

local virtualStatuslist;				--ÐéÄâ×´Ì¬ÁÐ±í£¬ÓÃÓÚ´æ·Å¿ÉÄÜ³öÏÖµÄfighter/status¹ØÏµ£¬ÍÆµ¼ÓÃ

local ComboSide =
   {
      left  	= 1;
      right	= 2;
      default = 3;
   }

local daojishiMaxX = 220;
local daojishiMinX = 0;
local daojishiY = -8;

local canCastSkill = {}

local skillIterator;					--Á¬»÷¼¼ÄÜµÄÐòºÅÖ¸Ê¾Æ÷ ±êÊ¶µ±Ç°½øÐÐµ½µÚ¼¸¸ö¼¼ÄÜ

local counterState;						--´ò¶Ï×´Ì¬
local comboState;						--Á¬»÷×´Ì¬

local userguidePanel;

--local timer = 0;


--===============
--Á¬»÷Ïà¹ØÃæ°å¿Ø¼þ
local barValue;
local maxBarValue = 200;
local barStep = 1;
local imgRole;

local comboNumPanel;
local comboDisplayPanel;
local daojishiPro;
local skillType

local comboType;

local curSkill;

--=============================================================================================
--×ÔÓÃ·½·¨
local function clearLeftSkillList()
   leftPursuitSkillList = {};
   leftStartSkillList = {};
   leftCounterSkillList = {};
   leftComboSkillList = {};
end

local function clearRightSkillList()
   rightPursuitSkillList = {};
   rightStartSkillList = {};
   rightCounterSkillList = {};
   rightComboSkillList = {};
end

function FightComboQueue:Init(desktop)
   self.status = QueueStatus.ComboOver;
   self.generateQueue = false;
   comboState = ComboStatus.PreCombo;
   counterState = CounterStatus.PreCounter;
   skillIterator = 0;
   self.combo = 0;
   comboType = -1;
   self.cur_combo = 0;
   self.p_skill_count = 0;
   comboEffect.lastCombo = 0;
   comboEffect.layer = 0;
   comboEffect.timer = 0;
   can_counter = false;
   can_combo = false;
   self.side = ComboSide.default;
   self.fighterState = FighterComboState.Default;
   self.fighterStateComing = FighterComboState.Default;

   comboDisplayPanel = Label(desktop:GetLogicChild('Combodi'));
   comboDisplayPanel.Visibility = Visibility.Visible;
   comboDisplayPanel.Opacity = 0;
   comboDisplayPanel.Storyboard = "";
   comboDisplayPanel.ZOrder = PanelZOrder.comboPanel;


   userguidePanel = desktop:GetLogicChild('GuidePanel');

   comboNumPanel = comboDisplayPanel:GetLogicChild('ComboNumber');
   comboNumPanel.Visibility = Visibility.Visible;
   skillType = comboDisplayPanel:GetLogicChild('skillType')
   skillType.Visibility = Visibility.Visible

   comboImg = comboDisplayPanel:GetLogicChild('comboPanel'):GetLogicChild('Combo');

   imgRole = desktop:GetLogicChild('Combodi'):GetLogicChild('Skilltouxiang');
   labelSkill = desktop:GetLogicChild('Combodi'):GetLogicChild('skillName');
   daojishiPro = desktop:GetLogicChild('Combodi'):GetLogicChild('daojishiFrame');
   daojishiPro.Visibility = Visibility.Hidden;
   imgJindu = desktop:GetLogicChild('Combodi'):GetLogicChild('daojishiFrame'):GetLogicChild('daijishiItem');

   leftPursuitSkillList = {};
   self.leftPursuitId = 1;
   leftStartSkillList = {};
   self.leftStartId = 1;
   leftCounterSkillList = {};
   self.leftCounterId = 1;
   leftComboSkillList = {};
   self.leftComboId = 1;

   rightPursuitSkillList = {};
   self.rightPursuitId = 1;
   rightStartSkillList = {};
   self.rightStartId = 1;
   rightCounterSkillList = {};
   self.rightCounterId = 1;
   rightComboSkillList = {};
   self.rightComboId = 1;

   self.activeComboSkill = {};
   self.activeCounterSkill = {};

   self.leftActorList = {};
   self.leftCasterId = 1;
   self.rightActorList = {};
   self.rightCasterId = 1;

   barValue = 0;

   self.maxCombo = 0;

   self:SetIsCombo(false);
end

--³õÊ¼»¯×ó²à¼¼ÄÜÁÐ±í
function FightComboQueue:InitLeftSkill(leftActorList)
   for _, fighter in pairs(leftActorList) do
      if not fighter.comboId then
         fighter.comboId = self.leftCasterId;
         self.leftActorList[self.leftCasterId] = fighter;
         self.leftCasterId = self.leftCasterId + 1;
         for _, skill in pairs(fighter.m_skillList) do
            ---[[
            if skill.m_comboId == 0 then
               skill.m_caster = fighter.comboId;
               skill.castTimes = 0;
               if skill.m_skillClass == SkillClass.pursuitSkill then
                  --¼ÓÔØ×·»÷¼¼ÄÜ
                  skill.m_comboId = self.leftPursuitId;
                  leftPursuitSkillList[self.leftPursuitId] = skill;
                  self.leftPursuitId = self.leftPursuitId + 1;
                  --Debug.print("ÊÕ¼¯×·»÷¼¼ÄÜ" .. skill.m_scriptName);
               elseif skill.m_skillClass == SkillClass.comboSkill then
                  --¼ÓÔØËùÓÐµÄÁ¬»÷¼¼ÄÜ
                  skill.m_comboId = self.leftComboId;
                  leftComboSkillList[self.leftComboId] = skill;
                  self.leftComboId = self.leftComboId + 1;
                  --Debug.print("ÊÕ¼¯Á¬»÷¼¼ÄÜ" .. skill.m_scriptName);
               elseif skill.m_skillClass == SkillClass.counterSkill then
                  --¼ÓÔØËùÓÐµÄ·´»÷¼¼ÄÜ
                  skill.m_comboId = self.leftCounterId;
                  leftCounterSkillList[self.leftCounterId] = skill;
                  self.leftCounterId = self.leftCounterId + 1;
                  --Debug.print("ÊÕ¼¯·´»÷¼¼ÄÜ" .. skill.m_scriptName);
               elseif skill.m_skillClass == SkillClass.startSkill then
                  --¼ÓÔØËùÓÐµÄÆðÊÖ¼¼ÄÜ
                  skill.m_comboId = self.leftStartId;
                  leftStartSkillList[self.leftStartId] = skill;
                  self.leftStartId = self.leftStartId + 1;
                  --Debug.print("ÊÕ¼¯ÆðÊÖ¼¼ÄÜ" .. skill.m_scriptName);
               end
            end
         end
      end
   end
end

--³õÊ¼»¯ÓÒ²à¼¼ÄÜÁÐ±í
function FightComboQueue:InitRightSkill(rightActorList)
   for _, fighter in pairs(rightActorList) do
      if not fighter.comboId then
         fighter.comboId = self.rightCasterId;
         self.rightActorList[self.rightCasterId] = fighter;
         self.rightCasterId = self.rightCasterId + 1;
         for _, skill in pairs(fighter.m_skillList) do
            ---[[
            if skill.m_comboId == 0 then
               skill.m_caster = fighter.comboId;
               skill.castTimes = 0;
               if skill.m_skillClass == SkillClass.pursuitSkill then
                  --¼ÓÔØ×·»÷¼¼ÄÜ
                  skill.m_comboId = self.rightPursuitId;
                  rightPursuitSkillList[self.rightPursuitId] = skill;
                  self.rightPursuitId = self.rightPursuitId + 1;
               elseif skill.m_skillClass == SkillClass.comboSkill then
                  --¼ÓÔØËùÓÐµÄÁ¬»÷¼¼ÄÜ
                  skill.m_comboId = self.rightComboId;
                  rightComboSkillList[self.rightComboId] = skill;
                  self.rightComboId = self.rightComboId + 1;
               elseif skill.m_skillClass == SkillClass.counterSkill then
                  --¼ÓÔØËùÓÐµÄ·´»÷¼¼ÄÜ
                  skill.m_comboId = self.rightCounterId;
                  rightCounterSkillList[self.rightCounterId] = skill;
                  self.rightCounterId = self.rightCounterId + 1;
               elseif skill.m_skillClass == SkillClass.startSkill then
                  --¼ÓÔØËùÓÐµÄÆðÊÖ¼¼ÄÜ
                  skill.m_comboId = self.rightStartId;
                  rightStartSkillList[self.rightStartId] = skill;
                  self.rightStartId = self.rightStartId + 1;
               end
            end
         end
      end
   end
end

--flag 0 for left 1 for right
function FightComboQueue:DelDiePursuitSkill(flag, dier)
   local remove_list = {};
   local count = 0;
   local p_list;
   local a_list;
   if flag == 0 then
      p_list = leftPursuitSkillList;
      a_list = self.leftActorList;
   elseif flag == 1 then
      p_list = rightPursuitSkillList;
      a_list = self.rightActorList;
   else
      return;
   end

   for index,skill in pairs(p_list) do
      if a_list[skill.m_caster]:GetID() == dier:GetID() then
         count = count + 1;
         remove_list[count] = index;
      end
   end

   for i=1, count do
      table.remove(p_list, remove_list[i]);
   end
end

function FightComboQueue:Destroy()
   self.maxCombo = 0;
end

function FightComboQueue:onFadeout()
   comboDisplayPanel.isFadingout = false;
end



function FightComboQueue:updateFighterState()

   if not comboDisplayPanel then
      return;
   end

   self.combo = self.combo or 0;

   --[[
      if self.combo > comboEffect.lastCombo then
      --×ÖÌåÔö´ó ¸üÐÂÉÏ´Îcombo ÖØÖÃµ¹¼ÆÊ± Ôö¼Ó²ã¼¶
      comboEffect.layer = comboEffect.layer + 1;
      comboNumPanel:SetScale(1+0.05*(1+comboEffect.layer),1+0.05*(1+comboEffect.layer));
      comboImg:SetScale(1.3+0.05*(1+comboEffect.layer),1.3+0.05*(1+comboEffect.layer));
      comboEffect.timer = TIME_MAX;
      else
      --Èç¹ûµ¹¼ÆÊ±²»Îª0
      --Ôò µ¹¼ÆÊ±
      --·ñÔò Èç¹û²ã¼¶²»Îª0ÔòËõÐ¡×ÖÌå
      if comboEffect.timer > 0 then
      comboEffect.timer = comboEffect.timer - 1;
      else
      if comboEffect.layer > 0 then
      comboEffect.layer = comboEffect.layer - 1;
      end
      comboNumPanel:SetScale(1+0.05*(1+comboEffect.layer),1+0.05*(1+comboEffect.layer));
      comboImg:SetScale(1.3+0.05*(1+comboEffect.layer),1.3+0.05*(1+comboEffect.layer));
      end
      end
   --]]
   comboEffect.lastCombo = self.combo;

   if comboNumPanel.Text ~= tostring(self.combo) then
      comboNumPanel.Text = tostring(self.combo);

      if self.combo > 0 then
         local sb = comboDisplayPanel:SetUIStoryBoard('storyboard.FadeOut');
         sb:SubscribeScriptedEvent('StoryboardInstance::FinishedEvent', 'FightComboQueue:onFadeout');
         comboDisplayPanel.Storyboard = "storyboard.FadeOut";
         comboNumPanel.Storyboard = "storyboard.ComboShake";
         comboImg.Storyboard = "storyboard.ComboShake";
      end
   end

   if self.combo > 50 and comboType ~= 50 then
      comboNumPanel:SetFont(COMBOFONT3);
      comboImg.Image = GetPicture('fight/fight_combo3.ccz')
      comboType = 50;
   elseif self.combo > 10 and comboType ~= 10 then
      comboNumPanel:SetFont(COMBOFONT2);
      comboImg.Image = GetPicture('fight/fight_combo2.ccz')
      comboType = 10;
   elseif self.combo <= 10 and comboType ~= 0 then
      comboNumPanel:SetFont(COMBOFONT1);
      comboImg.Image = GetPicture('fight/fight_combo1.ccz')
      comboType = 0;
   end
end

--  旷世大战
function FightComboQueue:setStatus(status)
   self.status = status
end

function FightComboQueue:setIsStop(isStop)
   self.isStop = isStop
end

function FightComboQueue:Update(elapse)
   if FightManager:IsOver() then
      return;
   end
  if FightHandSkillManager.thirdRoundUpdata and FightManager.barrierId == 1003 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth3 then
	return;
  end
   if self.status == QueueStatus.SkillCasting then
      if not self:checkSkillCasting() then
         if self:checkSkillHit() then				--   连击释放技能
            if FightManager.mFightType == FightType.noviceBattle and PlotsArg.isFightWithBoss == true then
               --  触发相应的剧情
               if self.curComboNum == 1 and self.isTragger then
                  EventManager:FireEvent(EventType.FirstCombo, 1 )
                  self.isTragger = false
               elseif self.curComboNum ==2 and self.isTragger then
                  EventManager:FireEvent(EventType.SecondCombo, 2 )
                  self.isTragger = false
               elseif self.curComboNum == 3 and self.isTragger then
                  EventManager:FireEvent(EventType.ThirdCombo, 3 )
                  self.isTragger = false
               end
               if self.curComboNum > 3 then
                  self.status = QueueStatus.SkillOver
               end
            else
               self.status = QueueStatus.SkillOver
            end
            self.fighterState = self.fighterStateComing;

            Debug.print(" [COMBO] SkillHitTrue SkillCasting => SkillOver")
         else
            FightSkillCardManager:unLockStartSkill();
            Debug.print(" [COMBO] SkillMiss SkillCasting => SkillOver")
            self.status = QueueStatus.ComboOver;

            --添加shing
            FightSkillCardManager:specialAddShing();

            self:clearSkillList();
            self:SetIsCombo(false);

            FightManager:Continue();
         end
      end
   elseif self.status == QueueStatus.SkillOver then
      Debug.print(" [COMBO] fighterState: " .. tostring(self.fighterState))

      if self:checkSkillNext() then							--²é¿´µ±Ç°×´Ì¬ÊÇ·ñ¿ÉÒÔ´¥·¢ÏÂ¸öÐèÒªÊÍ·ÅµÄÁ¬»÷
         local isCardCounter, thecard = self:checkCardCounter(elapse);
         if isCardCounter then						--ÓÐ£¬Ôò¼ì²éÊÇ·ñÓÐ´ò¶ÏÅÆ
            self.status = QueueStatus.CardCounter;

            Debug.print(" [COMBO] HasCardCounter SkillOver => CardCounter")

            counterState = CounterStatus.Waiting;
            can_counter = true;
            daojishiPro.Visibility = Visibility.Visible;
            imgJindu.Margin = Rect(daojishiMaxX, daojishiY, 0, 0);

            --在添加反击shing前，先把其余shing移除
            FightSkillCardManager:removeCardShing();

            FightCardPanel:AddShining(thecard);
            self.shiningCard = thecard; --正在闪烁的卡牌

         else
            Debug.print(" [COMBO] NOTHasCardCounter SkillOver => SkillCasting")

            self.status = QueueStatus.SkillCasting;
            self:castNextSkill(elapse);
         end
      else												--·ñ£¬Ôò¼ì²éÊÇ·ñ¿ÉÒÔ¼ÌÐøÁ¬»÷£¬¿ÉÒÔµÄ»°¼ì²éÊÇ·ñÓÐÁ¬»÷ÅÆ
         local isCardCombo, thecard = self:checkCardCombo();
         if isCardCombo then
            self.status = QueueStatus.CardCombo;
            Debug.print(" [COMBO] HasCardCombo SkillOver => CardCombo")
            comboState = ComboStatus.Waiting;
            can_combo = true;

            --在添加连击shing前，先把其余shing移除
            FightSkillCardManager:removeCardShing();

            daojishiPro.Visibility = Visibility.Visible;
            imgJindu.Margin = Rect(daojishiMaxX, daojishiY, 0, 0);
            FightCardPanel:AddShining(thecard);
            self.shiningCard = thecard; --正在闪烁的卡牌
         else
            FightSkillCardManager:unLockStartSkill();
            self.status = QueueStatus.ComboOver;

            --添加shing
            FightSkillCardManager:specialAddShing();

            Debug.print(" [COMBO] NOTHasCardCombo SkillOver => ComboOver")
            self:clearSkillList();
            self:SetIsCombo(false);

            effectScriptManager:ResumeAllEffectScript();
            FightManager:Continue();
         end
      end
   elseif self.status == QueueStatus.CardCounter then
      if counterState == CounterStatus.Waiting then
         --¼ì²â´ò¶Ï¼¼ÄÜÊÇ·ñÒÑ¾­ÊÍ·Å
         if self:isCastCounter(elapse) then
            --ÒÑ±»´ò¶Ï£¬Ö´ÐÐ¶ÔÓ¦¹¤×÷ Çå¿ÕÖ®ºóµÄ¼¼ÄÜÁÐ±í£¬ÈÃ¶Ô·½Á¬»÷¿ªÊ¼

            can_counter = false;
            self:resetBar();
            counterState = CounterStatus.PreCounter;
            self.status = QueueStatus.SkillCasting;

            Debug.print(" [COMBO] CastCounter CastCounter => SkillCasting")
            self:counterClear();
            self:castCounterSkill();
         else
            barValue = barValue + barStep;
            if barValue == maxBarValue then
               counterState = CounterStatus.Finish;

               Debug.print(" [COMBO] NOTCastCounterSkill")

               self:resetBar();
            else
               self:updateCardWaitingBar();
            end
         end
      elseif counterState == CounterStatus.Finish then
         --µÈ´ý¹ý³ÌÖÐÎ´´ò¶Ï£¬Ôò¼ÌÐøÊÍ·Å¼¼ÄÜ
         counterState = CounterStatus.PreCounter;
         self.status = QueueStatus.SkillCasting;
         self.activeCounterSkill = {};

         Debug.print(" [COMBO] CounterFinish CastCounter => SkillCasting")
         can_counter = false;
         self:castNextSkill(elapse);
      end
   elseif self.status == QueueStatus.CardCombo then       --   连击过程
      if comboState == ComboStatus.Waiting then
         --¼ì²âÁ¬»÷¼¼ÄÜÊÇ·ñÒÑ¾­ÊÍ·Å
         if self:isCastCombo() then         --  正在释放技能
            --ÒÑÁ¬»÷£¬Ö´ÐÐ¶ÔÓ¦¹¤×÷ Çå¿ÕÖ®ºóµÄ¼¼ÄÜÁÐ±í£¬»Ö¸´Õý³£ÓÎÏ·

            self:resetBar();
            comboState = ComboStatus.PreCombo;
            self.status = QueueStatus.SkillCasting;
            Debug.print(" [COMBO] CastCombo CardCombo => SkillCasting")
            can_combo = false;
            self:comboClear();
            self:castComboSkill();

         else
           if FightManager.barrierId == 1002 and FightHandSkillManager.isFirstCard and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2 and (CheckDiv(barValue/maxBarValue) >= 0.8) then
            else
               --弹出提示面板
               --[[
               if FightManager.barrierId == 1002 and FightHandSkillManager.isFirstCard and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2 and FightImageGuidePanel.isShowFirstPic then
                  FightImageGuidePanel:onShow('round_2_1', '连击技能释放及效果说明', LANG_fight_guide_round_2_1);
                  FightImageGuidePanel.isShowFirstPic = false;
               end
               --]]
               if FightManager.barrierId == 1002 and FightHandSkillManager.isFirstCard and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2 and FightImageGuidePanel.isShowFirstPic then
                  FightSkillCardManager:guideCradClick(1);
               end

               barValue = barValue + barStep;
               if barValue == maxBarValue then
                  comboState = ComboStatus.Finish;
                  Debug.print(" [COMBO] NOTCastComboSkill")
                  self:resetBar();
               else
                  self:updateCardWaitingBar();
               end
            end
         end
      elseif comboState ==  ComboStatus.Finish then
         FightSkillCardManager:unLockStartSkill();
         --µÈ´ý¹ý³ÌÖÐÎ´Á¬»÷£¬ÔòÇå¿ÕÁ¬»÷ÁÐ±í »Øµ½Õý³£ÓÎÏ·
         comboState = ComboStatus.PreCombo;
         self.status = QueueStatus.ComboOver;

         --添加shing
         FightSkillCardManager:specialAddShing();

         self.activeComboSkill = {};
         Debug.print(" [COMBO] ComboFinish CastCombo => ComboOver")

         can_combo = false;
         self:clearSkillList();
         self:SetIsCombo(false);

         if FightManager.barrierId == 1002 and FightHandSkillManager.isFirstCard and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2 then
         else
            FightManager:Continue();
         end
      end
   elseif self.status == QueueStatus.ComboOver then
      --ÅÐ¶ÏÊÇ·ñÆðÊÖÒÑ¾­ÊÍ·Å
      if self:isStartSkillCast() then
         self.status = QueueStatus.SkillCasting;
         Debug.print(" [COMBO] CastStartSkill ComboOver => SkillCasting")
         self:SetIsCombo(true);

         -- FightManager:Pause(false);

         self:castFirstSkill();
      end
   end

   self:updateFighterState();
end

------------------------------------------------------------------------------------------------------
--¼ì²âÆðÊÖ¼¼ÄÜÊÇ·ñÒÑ¾­ÊÍ·Å
function FightComboQueue:isStartSkillCast()
   for _, skill in pairs(leftStartSkillList) do
      if skill.isCasting then
         self.side = ComboSide.left;
         self.fighterStateComing = skill.m_comboResult;
         self:setSkillCasting(self.side, skill, true);
         self:updateUI(skill);
         return true;
      end
   end
   for _, skill in pairs(rightStartSkillList) do
      if skill.isCasting then
         self.side = ComboSide.right;
         self.fighterStateComing = skill.m_comboResult;
         self:setSkillCasting(self.side, skill);
         self:updateUI(skill);
         return true;
      end
   end

   return false;
end

function FightComboQueue:checkSkillHit()
   return self.skillCasting:isSkillHit();
end

--Çå³ýÁÐ±í
function FightComboQueue:clearSkillList()
   Debug.print(" [COMBO] ClearSkillList ComboEnd")
   lastCombo = 0;
   comboEffect = {};
   comboEffect.lastCombo = 0;
   comboEffect.layer = 0;
   comboEffect.timer = 0;
   self.side = ComboSide.default;
   self.fighterState = FighterComboState.Default;
   self.fighterStateComing = FighterComboState.Default;

   for _, skill in pairs(leftPursuitSkillList) do
      skill.castTimes = 0;
   end
   for _, skill in pairs(rightPursuitSkillList) do
      skill.castTimes = 0;
   end
end

function FightComboQueue:comboClear()
   for _, skill in pairs(leftPursuitSkillList) do
      skill.castTimes = 0;
   end
   for _, skill in pairs(rightPursuitSkillList) do
      skill.castTimes = 0;
   end
end

function FightComboQueue:counterClear()
   self.combo = 0;
   comboType = -1;
   self.cur_combo = 0;
   comboEffect = {};
   comboEffect.lastCombo = 0;
   comboEffect.layer = 0;
   comboEffect.timer = 0;
   for _, skill in pairs(leftPursuitSkillList) do
      skill.castTimes = 0;
   end
   for _, skill in pairs(rightPursuitSkillList) do
      skill.castTimes = 0;
   end
end

--¼ì²é¼¼ÄÜÊÍ·ÅÊÇ·ñ½áÊø
function FightComboQueue:checkSkillCasting()
   local isCasting;
   if self.skillCasting:isSkillCasting() and self.skillCasting.m_fighter:GetFighterState() ~= FighterState.death then
      --Debug.print(" [COMBO]SkillCasting " .. self.skillCasting.m_scriptName);
      isCasting = true;
   else
      Debug.print(" [COMBO]SkillNOTCasting");

      self.skillCasting:EndSkill()

      FightShowSkillManager:DeleteActorWaitForCastSkill(self.skillCasting.m_fighter);
      isCasting = false;
   end
   return isCasting;
   --[[timer = timer + 2;
      local isCsting;
      if timer < 200 then
      isCsting = true;
      else
      timer = 0;
      isCsting = false;
      end
      return isCsting;
      --]]
   --return true;
end

--ÊÍ·ÅÆðÊÖ¼¼ÄÜ
function FightComboQueue:castFirstSkill()
   --清除ComboLink
   skillIterator = 1;
   self.combo = 0;
   comboType = -1;
   self.cur_combo = 0;
   can_combo = false;
   can_counter = false;
   --timer = 0;
end

--ÊÍ·ÅÏÂÒ»¸ö¼¼ÄÜ
function FightComboQueue:castNextSkill(elapse)
   local fighterList;
   if self.side == ComboSide.left then
      fighterList = self.leftActorList;
   elseif self.side == ComboSide.right then
      fighterList = self.rightActorList;
   end
   --timer = 0;
   skillIterator = skillIterator + 1;
   self.cur_combo = 0;
   local castSkill = canCastSkill[math.random(#canCastSkill)];

   local curSkill = fighterList[castSkill.m_caster].m_curSkill;
   if curSkill ~= nil and curSkill ~= castSkill then
      curSkill:DestroyEffectScript();
      curSkill:EndSkill();
   end
   local skillToFuck = FightShowSkillManager:IsActorWaitForCastSkill(fighterList[castSkill.m_caster])
   if skillToFuck ~= nil then
      skillToFuck:DestroyEffectScript();
      skillToFuck:EndSkill();
      FightShowSkillManager:DeleteActorWaitForCastSkill(fighterList[castSkill.m_caster]);
   end

   Debug.print(" [COMBO] " .. tostring(fighterList[castSkill.m_caster]:GetResID()) .. "] CastNextSkill " .. castSkill.m_scriptName);
   castSkill.castTimes = castSkill.castTimes + 1;
   castSkill:CanReleaseSkill(elapse);
   self:setSkillCasting(self.side, castSkill);
   self.fighterStateComing = castSkill.m_comboResult;
   self:updateUI(castSkill);
end

--¼ì²âÁ¬»÷¼¼ÄÜÊÇ·ñÒÑ¾­ÊÍ·Å
function FightComboQueue:isCastCombo(elapse)
   local flag_isCastCombo = false;
   if self.side == ComboSide.left then
      for _,skill in pairs(self.activeComboSkill) do
         if skill:isSkillCasting() then           --  正在释放技能
            self.fighterStateComing = skill.m_comboResult;     --  即将到来的状态就是正在释放技能的comboResult结果
            self:setSkillCasting(self.side, skill);      --  记录正在释放的技能
            flag_isCastCombo = true;
            skill.active = false;
            self:updateUI(skill);
            break;
         end
      end
   elseif self.side == ComboSide.right then
      if AILevel == 3 then
         for id, skill in pairs(self.activeComboSkill) do
            skill:CanReleaseSkill(elapse);
            self.fighterStateComing = skill.m_comboResult;
            self:setSkillCasting(self.side, skill);
            self:updateUI(skill);
            FightSkillCardManager:castEnemyComboSkill(id);
            --FightSkillCardManager:castEnemySkill(id);
            break;
         end
      end
      flag_isCastCombo = true;
   end
   if flag_isCastCombo == true then
      self.activeComboSkill = {};
   end

   return flag_isCastCombo;
end

--ÊÍ·ÅÁ¬»÷¼¼ÄÜ
function FightComboQueue:castComboSkill()
   --timer = 0;
   skillIterator = skillIterator + 1;
end

--¼ì²â·´»÷¼¼ÄÜÊÇ·ñÒÑ¾­ÊÍ·Å
function FightComboQueue:isCastCounter(elapse)
   local flag_isCastCounter = false;

   if self.side == ComboSide.right then
      for _,skill in pairs(self.activeCounterSkill) do
         if skill:isSkillCasting() then
            self.fighterStateComing = skill.m_comboResult;
            self:setSkillCasting(ComboSide.left, skill, true); -- 反方向发起
            skill.active = false;
            flag_isCastCounter = true;
            self:updateUI(skill);
            break;
         end
      end
   elseif self.side == ComboSide.left then
      if AILevel == 3 then
         for id, skill in pairs(self.activeCounterSkill) do
            skill:CanReleaseSkill(elapse);
            self.fighterStateComing = skill.m_comboResult;
            self:setSkillCasting(ComboSide.right, skill, true, true); -- 对方释放反击，清理
            self:updateUI(skill);
            FightSkillCardManager:castEnemyComboSkill(id);
            --				FightSkillCardManager:castEnemySkill(id);
            break;
         end
      end
      flag_isCastCounter = true;
   end
   if flag_isCastCounter == true then
      self.activeCounterSkill = {};
   end

   return flag_isCastCounter;
end

--ÊÍ·Å·´»÷¼¼ÄÜ
function FightComboQueue:castCounterSkill()
   --timer = 0;
   skillIterator = 1;
   if self.side == ComboSide.right then
      self.side = ComboSide.left;
   elseif self.side == ComboSide.left then
      self.side = ComboSide.right;
   end

end

--¼ì²éÊÇ·ñÓÐÏÂÒ»¸ö¼¼ÄÜ
function FightComboQueue:checkSkillNext()
   canCastSkill = {}; --½«ÒªÊÍ·ÅµÄ¼¼ÄÜÁÐ±í
   local fighterList;
   local skillList;
   local num = 1;
   if self.side == ComboSide.left then
      fighterList = self.leftActorList;
      skillList = leftPursuitSkillList;
   elseif self.side == ComboSide.right then
      fighterList = self.rightActorList;
      skillList = rightPursuitSkillList;
   end

   --¼ì²â¶Ô·½×´Ì¬£¬»ñÈ¡½«Òª¹¥»÷µÄÄ¿±êÁÐ±í
   --[[
      targetList = {};
      --1.±éÀúfightlist,Ñ°ÕÒÌØÊâ×´Ì¬
      --2.·µ»Ø´øÓÐÌØÊâ×´Ì¬µÄfighter
   --]]
   for _, skill in pairs(skillList) do
      if self:haveType(skill.m_comboCause,self.fighterState) and self.fighterState ~= FighterComboState.Default then --ÈôÕâ¸ö¼¼ÄÜµÄÆðÒòÊÇµ±Ç°buff
         if skill.castTimes < skill.m_MaxNum and fighterList[skill.m_caster] and fighterList[skill.m_caster]:isAlive() then  --²¢ÇÒÕâ¸ö¼¼ÄÜÊÍ·Å´ÎÊýÂú×ãÌõ¼þ ÇÒ¼¼ÄÜÊÍ·ÅÕß»¹»î×Å
            canCastSkill[num] = skill;
            num = num + 1;
            Debug.print(" [COMBO] NowCanCast " .. skill.m_scriptName);
         end
      end
   end
   if( num == 1 ) then
      for _, skill in pairs(skillList) do
         if self:haveType(skill.m_comboCause,FighterComboState.Combo) then
            if skill.m_NumNeed <= self.combo and skill.castTimes < skill.m_MaxNum and fighterList[skill.m_caster] and fighterList[skill.m_caster]:isAlive() then
               canCastSkill[num] = skill;
               Debug.print(" [COMBO] NowCanCastCombo " .. skill.m_scriptName);
               num = num + 1;
            end
         end
      end
   end

   return #canCastSkill ~= 0;
end

--¼ì²éÊÇ·ñÓÐÁ¬»÷¿¨ÅÆ
function FightComboQueue:checkCardCombo()
   local num = 1;
   self.activeComboSkill = {};
   local isCombo = false;
   local thecard = nil;
   if self.side == ComboSide.left then
      for _,card in pairs(FightSkillCardManager:getHandSkillList()) do
         if card.info.skill.m_skillClass == SkillClass.comboSkill and self:haveType(card.info.skill.m_comboCause,self.fighterState) then
            self.activeComboSkill[num] = card.info.skill;
            num = num + 1;
            card.info.skill.active = true;
            thecard = card;
            isCombo = true;
         end
      end
   elseif self.side == ComboSide.right then
      for id,skillinfo in pairs(FightSkillCardManager:getEnemyActiveSkillList()) do
         if skillinfo.skill.m_skillClass == SkillClass.comboSkill and self:haveType(skillinfo.skill.m_comboCause,self.fighterState) and skillinfo.willCastTimes > 0 then
            self.activeComboSkill[id] = skillinfo.skill;
            skillinfo.skill.active = true;
            isCombo = true;
         end
      end
   end

   return isCombo, thecard;
end

--¼ì²éÊÇ·ñÓÐ·´»÷¿¨ÅÆ
function FightComboQueue:checkCardCounter(elapse)
   local skillList;
   self.activeCounterSkill = {}
   local num = 1;
   local isCounter = false;
   local thecard = nil;
   if self.side == ComboSide.left then
      for id,skillinfo in pairs(FightSkillCardManager:getEnemyActiveSkillList()) do
         if skillinfo.skill.m_skillClass == SkillClass.counterSkill and self:haveType(skillinfo.skill.m_comboCause,self.fighterState) and skillinfo.willCastTimes > 0 then
            self.activeCounterSkill[id] = skillinfo.skill;
            skillinfo.skill.active = true;
            isCounter = true;
         end
      end
   elseif self.side == ComboSide.right then
      for _,card in pairs(FightSkillCardManager:getHandSkillList()) do
         if card.info.skill.m_skillClass == SkillClass.counterSkill and self:haveType(card.info.skill.m_comboCause,self.fighterState)  then
            self.activeCounterSkill[num] = card.info.skill;
            num = num + 1;
            card.info.skill.active = true;
            isCounter = true;
            thecard = card;
         end
      end
   end

   return isCounter, thecard;
end

function FightComboQueue:onComboQueue()
   return self.isComboQueue;
end

--´ò¶Ï¼¼ÄÜ
function FightComboQueue:counterSkill()
end

--Á¬»÷¼¼ÄÜ
function FightComboQueue:comboSkill()
end

function FightComboQueue:getMaxCombo()
   return self.maxCombo;
end

function FightComboQueue:skillCastOver()
   if self.skillCasting then
      Debug.print(" [COMBO] CastOver" ..  self.skillCasting.m_scriptName);
      self.skillCasting.isCasting = false;
   end
end

function FightComboQueue:skillCastName()
   if self.skillCasting then
      return self.skillCasting.m_scriptName;
   end
   return '';
end


function FightComboQueue:skillCastAttackerId()
   if self.skillCasting then
      local fightlist;
      if self.side == ComboSide.left then
         fighterList = self.leftActorList;
      elseif self.side == ComboSide.right then
         fighterList = self.rightActorList;
      end

      if Debug.assert_value(self.skillCasting, "skillCasting is empty") then
         if Debug.assert_value(self.skillCasting.m_caster, "m_caster is empty") then
            if Debug.assert_value(fighterList[self.skillCasting.m_caster], "fighterList[i] is empty") then
            end
         end
      end

      return fighterList[self.skillCasting.m_caster]:GetID();
   end
   return 0;
end
--======================================================================
--UIÏà¹Ø
function FightComboQueue:updateCardWaitingBar()
   imgJindu.Margin = Rect(daojishiMaxX - CheckDiv(barValue/maxBarValue)*220, daojishiY, 0, 0);
end

function FightComboQueue:resetBar()
   barValue = 0;
   imgJindu.Margin = Rect(daojishiMaxX, daojishiY, 0, 0);
   daojishiPro.Visibility = Visibility.Hidden;
   if self.shiningCard then
      FightCardPanel:RemoveShining(self.shiningCard);
      self.shiningCard = nil;
   end
end

function FightComboQueue:CheckComboSideLeft()
   return (self.side == ComboSide.left);
end

function FightComboQueue:CheckComboSideRight()
   return (self.side == ComboSide.right);
end

function FightComboQueue:GetSkillResultType(id)
   local kind = resTableManager:GetValue(ResTable.skill, tostring(id), 'combo_result')
   --  更新combo显示
   if kind ~= 1 and kind ~= 2 and kind ~= 3 and kind ~= 5 and kind ~= 6 then
      kind = 100
   end

   return tostring(SkillTypeEnum[kind]);
end
--¸üÐÂ¼¼ÄÜÊÍ·ÅµÄui
function FightComboQueue:updateUI(skill)

   labelSkill.Text = tostring(resTableManager:GetValue(ResTable.skill, tostring(skill.m_resid), 'name'));

   local skillResultText = self:GetSkillResultType(skill.m_resid);
   skillType.Text = skillResultText;

   local skill_class = tonumber(resTableManager:GetValue(ResTable.skill, tostring(skill.m_resid), 'skill_class'));

   local fighter;
   if self.side == ComboSide.right then
      fighter = self.rightActorList[skill.m_caster];
   elseif self.side == ComboSide.left then
      fighter = self.leftActorList[skill.m_caster];
   end

   --反击技能则改变side
   if skill_class == 2 then
      local side = (ComboSide.right == self.side) and ComboSide.left or ComboSide.right;
      if side == ComboSide.right then
         fighter = self.rightActorList[skill.m_caster];
      elseif side == ComboSide.left then
         fighter = self.leftActorList[skill.m_caster];
      end
   end

   if not fighter then
      return;
   end

   local headImage;
   if tonumber(fighter.resID) >= 3001 and tonumber(fighter.resID) < 10000 or tonumber(fighter.resID)==99999 or tonumber(fighter.resID)== 99998 then
      headImage = resTableManager:GetValue(ResTable.monster, tostring(fighter.resID), 'icon');
   else
      headImage = resTableManager:GetValue(ResTable.navi_main, tostring(fighter.resID), 'role_path_icon');
   end
   imgRole.Image = GetPicture('navi/' .. headImage .. ".ccz");
end

--Ôö¼ÓcomboÊýÁ¿
function FightComboQueue:AddComboNum(num, add_anger_fun_)
   if self.isComboQueue then
      if self.cur_combo == Configuration.combo4EachSkill then
         return;
      elseif self.cur_combo + num > Configuration.combo4EachSkill then
         self.cur_combo = Configuration.combo4EachSkill;
         num = self.cur_combo + num - Configuration.combo4EachSkill;
      else
         self.cur_combo = self.cur_combo + num;
      end
		

	  if add_anger_fun_ then
		  local anger = add_anger_fun_(self.combo, num);
		  if self.side == ComboSide.left then
			FightManager:AddTotalAnger(anger);
		  elseif self.side == ComboSide.right then
			FightManager:AddTotalEnemyAnger(anger);
		  end
	  end		  

      self.combo = self.combo + num;
      if self.combo > self.maxCombo then
         self.maxCombo = self.combo;
      end
   end
end

function FightComboQueue:CanCounter()
   return can_counter;
end

function FightComboQueue:CanCombo()
   return can_combo;
end

function FightComboQueue:getComboState()
   return self.fighterState;
end

function FightComboQueue:SetIsCombo(value)
   self.isComboQueue = value;
   if value then
      FightManager.scene:GoDark();
   else
      FightManager.scene:GoBright();
   end
end

function FightComboQueue:setSkillCasting(side, skill, clear, stop)
   self.skillCasting = skill;
   if side == ComboSide.left then
      if clear then
         FightComboLinkManager:Clear();
      end
      --只有对方释放反击时，才可能stop=true
      if not stop then
		  curSkill = skill;
		  FightComboLinkManager:AppendItem(skill);
      end

   end
end

--新手引导combom特效显示
function FightComboQueue:UserguidePause()
	local guide = {4,1,2,3,2}
	--暂停游戏
	SceneRenderStep:Pause();
	FightManager:PauseEffectScript();
	FightUIManager:pauseTime();
	--播放特效
	armatureFront = uiSystem:CreateControl('ArmatureUI')
	print('guide' .. guide[guideindex])
	armatureFront:LoadArmature('lianji_' .. tonumber(guide[guideindex]));
	guideindex = guideindex + 1;
--	if guideindex > 3 then
--		guideindex = 2
--	end
	--armatureFront:SetScale(0.9,0.9)
	armatureFront:SetAnimation('play')
	armatureFront:SetScriptAnimationCallback('FightComboQueue:UserguideContinue',0)
	armatureFront.Horizontal = ControlLayout.H_CENTER;
	armatureFront.Vertical = ControlLayout.V_CENTER;
	armatureFront.ZOrder = 1000000
	userguidePanel:AddChild(armatureFront);
end

--新手引导combom特效结束回调
function FightComboQueue:UserguideContinue()
	--继续游戏
	SceneRenderStep:Continue();
	FightManager:ResumeEffectScript();
	FightUIManager:resumeTime();

	--继续combom特效并删除已播放特效
	FightComboQueue:ContinueSkillCasting()
	userguidePanel:RemoveAllChildren();
end

function FightComboQueue:ContinueSkillCasting()
	FightComboLinkManager:AppendItem(curSkill);
end

function FightComboQueue:haveType(table_, type_)
   local find = false;
   for _, m_type in pairs(table_) do
      if m_type == type_ then
         find = true;
         break;
      end
   end
   return find;
end
