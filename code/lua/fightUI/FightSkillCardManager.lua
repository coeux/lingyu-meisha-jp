--FightSkillCardManager.lua

--========================================================================
--战斗UI管理者类

FightSkillCardManager =
{
	skillIndex = 1;
	skillCardIndex = 0;  --  记录旷世大战产生卡牌的数量
	canFightContinue = false;
	guideCardClick = false;
	isStop = false;
};

local cardCDList = {};
local cdMax = 200;

local sceneCamera = nil;
local uiCamera = nil;

local F_Global_CD;
local E_Global_CD;
local MAX_GCD = 150;
local E_MAX_GCD = 200;

local guideArmature
local isNoviceBattle = false
local isCardCanClick = false   --  旷世大战卡牌只有在展示动画之后才能点击
local lockStart;
local lockStartCD;

--初始化
function FightSkillCardManager:Initialize(desktop)
	self.desktop = desktop;				--获取战斗UI界面
	sceneCamera  = FightManager.scene:GetCamera();
	uiCamera     = desktop.Camera;

	F_Global_CD = 0;
	E_Global_CD = 0;

	lockStart = false;

	self.handSkillList      = {};
	self.handSkillQueue     = {};
	self.enemyHandSkillList = {};
	--全部手牌的容器
	self.handSkillList = {};

	local height = desktop.Height;
	local width  = desktop.Width;

	self.centerX = width / 2

	--有关各角色自己的cd
	cardCDList = {};

	local path = GlobalData.EffectPath .. 'chuka_output/';
	AvatarManager:LoadFile(path);

	if FightManager:isGCDPVP() then
		E_MAX_GCD = 150;
	else
		E_MAX_GCD = 500;
	end

end

--销毁
function FightSkillCardManager:Destroy()
	self.handSkillList = {};
	self.enemyHandSkillList = {};
	cardCDList = {};
	F_Global_CD = 0;
	E_Global_CD = 0;
end

--更新技能CD
function FightSkillCardManager:UpdateCD(elapse)
	if FightManager:IsPause() then
		return;
	end

	for _, cd in pairs(cardCDList) do
		if cd.lock then
			if cd.actor.m_curSkill and cd.actor.m_curSkill:GetSkillType() == SkillType.normalAttack then
				cd.lock = false
			elseif cd.skill.isCasting == false and FightShowSkillManager:IsActorWaitForCastSkill(cd.actor) == nil and cd.skill.m_fightAttackClass == nil then
				cd.lock = false
			end
		end
	end

	if F_Global_CD then
		F_Global_CD = F_Global_CD - 1;
	end
	if E_Global_CD then
		E_Global_CD = E_Global_CD - 1;
	end
	if lockStartCD then
		lockStartCD = lockStartCD - 1;
		if lockStartCD == 0 then
			lockStart = false;
		end
	end
end

function FightSkillCardManager:onCardFlyOut(Args)
	local args = StoryboardKeyFrameArgs(Args);
	local control = args.m_pTarget;
	local tag = control.Tag
	FightCardPanel:RemoveCard(self.handSkillList[tag]);
	table.remove(self.handSkillList, tag);
	self:updateTags();
end

function FightSkillCardManager:RemoveCard(card)
	card.shining = nil;
	--死人了或者点了卡牌
	local sb = card:SetUIStoryBoard("storyboard.CardFlyOut");
	sb:SubscribeScriptedEvent('StoryboardInstance::FinishedEvent', 'FightSkillCardManager:onCardFlyOut');
end

--更新
function FightSkillCardManager:Update(elapse)
	self:CreateCard();
	if FightManager.isOver then
		return;
	end

	--根据是否是自动战斗，隐藏卡牌区域
	--[[
	if FightManager:IsAuto() then
		FightCardPanel:Hide();
	else
		FightCardPanel:Show();
	end
	]]


	self:UpdateCD(elapse);

	--TODO:这里需要独立出来，在有人死亡的时候调用即可
	local get_type_card = function(card)
		if card.info.skill.m_skillClass == SkillClass.startSkill then
			return 1;
		elseif card.info.skill.m_targeterType1 == SkillSelectTargeterType.Point or card.info.skill.m_targeterType2 ~= SkillSelectTargeterType.Point then
			return 2;
		else
			return 3;
		end
	end
	local get_type_card_e = function(card)
		if card.skill.m_skillClass == SkillClass.startSkill then
			return 1;
		elseif card.skill.m_targeterType1 == SkillSelectTargeterType.Point or card.skill.m_targeterType2 ~= SkillSelectTargeterType.Point then
			return 2;
		else
			return 3;
		end
	end
	local get_min = function(friendList)
		local card_to_cast = friendList[#friendList];
		if not card_to_cast then
			return;
		end
		local min = get_type_card(card_to_cast);
		for i = #friendList, 1, -1 do
			local card = friendList[i];
			local cur_type = get_type_card(card);
			if cur_type < min then
				min = cur_type;
				card_to_cast = card;
			end
		end
		card_to_cast.gona_cast = true;
	end
	local get_min_e = function(enemyList)
		if #enemyList <= 0 then
			return;
		end
		local min = 5;
		local card_to_cast = nil;
		for i=1, #enemyList do
			local card = enemyList[i];
			if card.willCastTimes > 0 then
				local cur_type = get_type_card_e(card);
				if cur_type < min then
					min = cur_type;
					card_to_cast = card;
				end
			end
		end
		if card_to_cast then
			card_to_cast.gona_cast = true;
		end
	end
	get_min(self.handSkillList);
	for i = #self.handSkillList, 1, -1 do --从后向前，可以保证删除时下标依然可用
		local card = self.handSkillList[i];
		if card.info.actor:GetFighterState() == FighterState.death and not card.isRemoving then
			--由于RemoveCard先播放storyboard，之后再从handSkillList列表中删除卡，如果每次update都进入这个逻辑，storyboard将永远无法播放完毕
			-- 因此设置这个标志位，播放期间不再进入removecard逻辑
			card.isRemoving = true;
			self:RemoveCard(card);
		elseif FightManager:IsAuto() then
			if card.info.actor:isInScreenCamera() and (not card.info.actor:isSpecialState(FightSpecialStateType.Silence)) then
				--自动战斗
				if true then
					if (not FightComboQueue:CheckComboSideRight()) and (not FightComboQueue:onComboQueue()) and (F_Global_CD <= 0) then
						if card.info.skill.m_skillClass <= 3 and card.info.skill.m_skillType == SkillType.activeSkill and card.gona_cast then
							card.gona_cast = false;
							local id = card.info.actor:GetID();

							if cardCDList[id] then
								if cardCDList[id].lock == false then
									cardCDList[id].skill = card.info.skill;
									cardCDList[id].actor = card.info.actor;
									cardCDList[id].lock = true;
									cardCDList[id].cd = -1;
									self:RunCardSkill(card, elapse);
									break;
								end
							else
								cardCDList[id] = {};
								cardCDList[id].skill = card.info.skill;
								cardCDList[id].actor = card.info.actor;
								cardCDList[id].lock = true;
								cardCDList[id].cd = -1;
								self:RunCardSkill(card, elapse);
								break;
							end

						end
					elseif (FightComboQueue:CheckComboSideLeft() and FightComboQueue:onComboQueue() and FightComboQueue:CanCombo()) then
						if card.info.skill.m_skillClass == SkillClass.comboSkill then
							self:RunCardSkill(card, elapse);
							break;
						end
					elseif (FightComboQueue:CheckComboSideRight() and FightComboQueue:onComboQueue() and FightComboQueue:CanCounter()) then
						if card.info.skill.m_skillClass == SkillClass.counterSkill then
							self:RunCardSkill(card, elapse);
							break;
						end
					end
				end
			end
		end
	end

	--清理 死去的卡
	for i=#self.enemyHandSkillList, 1, -1 do
		if self.enemyHandSkillList[i].actor:GetFighterState() == FighterState.death then
			table.remove(self.enemyHandSkillList, i);
		end
	end

	if (not FightComboQueue:CheckComboSideLeft()) and (not FightComboQueue:onComboQueue()) then
		if E_Global_CD <= 0 then
			get_min_e(self.enemyHandSkillList);
			for i=1, #self.enemyHandSkillList do
				local card = self.enemyHandSkillList[i];
				if card.actor:isInScreenCamera() then
					if card.willCastTimes <= 0 or card.actor:GetFighterState() == 5 or card.actor:isSpecialState(FightSpecialStateType.Silence) then

					elseif card.skill.m_skillClass <= 3 and card.skill.m_skillType == SkillType.activeSkill and card.gona_cast then
						card.gona_cast = false;

						local id = card.actor:GetID();
						if cardCDList[id] then

							if cardCDList[id].lock == false then
								cardCDList[id].skill = card.skill;
								cardCDList[id].actor = card.actor;
								cardCDList[id].lock = true;
								cardCDList[id].cd = -1;
								self:castEnemySkill(i);
								break;
							end
						else

							cardCDList[id] = {};
							cardCDList[id].skill = card.skill;
							cardCDList[id].actor = card.actor;
							cardCDList[id].lock = true;
							cardCDList[id].cd = -1;
							self:castEnemySkill(i);
							break;
						end
					end
				end
			end
		else
			--print('E_Global_CD :' ..E_Global_CD)
		end
	end

	if FightManager.barrierId == 1003 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth3 then
		if FightHandSkillManager.isSecondCard or FightHandSkillManager.isFirstCard then
			return;
		end
	end
	if FightManager.barrierId == 1004 and ActorManager.user_data.userguide.isnew == GuideIndexExt.belove2 then
		if FightHandSkillManager.isSecondCard or FightHandSkillManager.isFirstCard then
			return;
		end
	end
	if (FightManager.barrierId == 1001 and ActorManager.user_data.userguide.isnew == 0) or
		(FightManager.barrierId == 1002 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2) then
		if FightHandSkillManager.isFirstCard or FightHandSkillManager.isSecondCard then
			return;
		end
	end

	self:UpdateCardEnable(elapse);
end

--添加敌方卡牌
function FightSkillCardManager:AddEnemyCard(skillInfo)
	local totalNum = 0;
	for _, skill in pairs(self.enemyHandSkillList) do
		--print(skill.skill.m_scriptName .. ' and ' .. skill.willCastTimes)
		totalNum = totalNum + skill.willCastTimes;
	end
	if totalNum >= 7 then
		--print('===============full====================')
		return;
	end
	--print('=======================================')
	--print('cur num is:' .. totalNum+1)
	local skill_in_list = false;
	for _, skill in pairs(self.enemyHandSkillList) do
		if skill.skill.m_resid == skillInfo.skill.m_resid then
			skill_in_list = true;
			skill.willCastTimes = skill.willCastTimes + 1;
			--print('add skill: ' .. skill.skill.m_scriptName)
			break;
		end
	end

	if not skill_in_list then
		table.insert(self.enemyHandSkillList, skillInfo);
		--print('add skill: ' .. skillInfo.skill.m_scriptName)
		skillInfo.willCastTimes = 1;
	end
end

--添加卡牌
function FightSkillCardManager:AddCard(skillInfo, force)
	table.insert(self.handSkillQueue, 1, skillInfo);
	self:updateTags();
end

function FightSkillCardManager:getEnemyActiveSkillList()
	return self.enemyHandSkillList;
end

function FightSkillCardManager:getHandSkillList()
	return self.handSkillList;
end

function FightSkillCardManager:castEnemySkill(skillId)
	local card = self.enemyHandSkillList[skillId];
	if lockStart and card.skill.m_skillClass == SkillClass.startSkill then
		return;
	end

	if card.skill.m_skillClass == SkillClass.startSkill then
		lockStartCD = MAX_GCD;
		lockStart = true;
	end

	E_Global_CD = E_MAX_GCD;
	self.isSkillCast = true;
	card.willCastTimes = card.willCastTimes - 1;
	--print('cast skill:' .. card.skill.m_scriptName)

	card.skill:SetReleaseFlag(true);
end

function FightSkillCardManager:castEnemyComboSkill(skillId)
	local card = self.enemyHandSkillList[skillId];
	self.isSkillCast = true;
	card.willCastTimes = card.willCastTimes - 1;
end

--释放卡牌技能
function FightSkillCardManager:RunCardSkill(card, elapse)
	if lockStart and card.info.skill.m_skillClass == SkillClass.startSkill then
		return;
	end

	if card.info.skill.m_skillClass == SkillClass.startSkill then
		lockStartCD = MAX_GCD;
		lockStart = true;
	end

	F_Global_CD = MAX_GCD;

	self.isSkillCast = true;
	if card.info.actor.m_fighterstate == FighterState.death then
		self:RemoveCard(card);
		return;
	end


	if card.info.skill ~= nil then
		Debug.print("[" .. card.info.skill.m_scriptName .. "] RunCardSkill");
	end
	--手动战斗
	if FightManager:IsAuto() == false and (not FightManager.isOver) then
		--将技能释放标志位设置为true
		local skill = card.info.skill;
		if skill ~= nil then
			--是否播放立绘
			local is_fla = resTableManager:GetValue(ResTable.skill, tostring(skill.m_resid), 'is_fla');
			--if is_fla == 1 and FightConfigPanel:getAnimStatus() then
			if false then
				FightBigPicPanel:Show(card);
			else
				-- if isNoviceBattle then
				--    FightManager:Continue()
				--    card.info.actor:SetShowSkillFlag(true)
				--    card.info.skill:SetReleaseFlag(true)
				--    isNoviceBattle = false
				-- else
				if card.info.skill.m_skillClass == SkillClass.startSkill then
					Debug.print("[" .. card.info.skill.m_scriptName .. "] startSkill");
					--effectScriptManager:DestroyAllEffectScript();
				end
				if (FightComboQueue:onComboQueue() and (card.info.skill.m_skillClass == SkillClass.counterSkill or card.info.skill.m_skillClass == SkillClass.comboSkill)) then
					card.info.skill:CanReleaseSkill(elapse);
				else
					card.info.actor:SetShowSkillFlag(true);
					card.info.skill:SetReleaseFlag(true);
				end
				-- end
			end
		end
		self:RemoveCard(card);
		PlaySound('combo1');									--播放技能音效
	end

	--自动战斗
	if FightManager:IsAuto() == true and (not FightManager.isOver) then
		card.info.actor:SetRunningState(true);					--强制更新
		self:RemoveCard(card);

		--将技能释放标志位设置为true
		local skill = card.info.skill;
		if skill ~= nil then
			if card.info.skill.m_skillClass == SkillClass.startSkill then
				--effectScriptManager:DestroyAllEffectScript();
				Debug.print("[" .. card.info.skill.m_scriptName .. "] auto startSkill");
			end
			card.info.actor:SetShowSkillFlag(true);
			card.info.skill:SetReleaseFlag(true);
		end
		PlaySound('combo1');
	end
end

function FightSkillCardManager:Hide()
end

function FightSkillCardManager:Show()
end

--=========================================================================================
--卡牌 UI 部分
--创建卡牌
function FightSkillCardManager:CreateCard()
	if not self.handSkillQueue or #self.handSkillQueue == 0 then
		return;
	end

	FightImageGuidePanel.canCreateCard = false;

	local skillInfo = self.handSkillQueue[1];
	table.remove(self.handSkillQueue, 1);

	--在实际添加卡牌的时候要二次判断
	if FightCardPanel:CanGetCard(skillInfo.actor.id) then
		return;
	end

	--创建armature
	local skillCard = uiSystem:CreateControl('handCardTemplate');

	skillCard.Vertical = ControlLayout.V_BOTTOM;
	skillCard.ZOrder = FightZOrderList.skillEffect;
	skillCard.info = skillInfo;



	skillCard:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'FightSkillCardManager:onClickCard');

	if FightManager.mFightType == FightType.noviceBattle then      --  旷世大战卡牌默认不能点
		isCardCanClick = false
		self.skillCardIndex = self.skillCardIndex + 1
	end

	--卡面拼装
	self:InitCardPanel(skillCard, skillInfo);
	if FightCardPanel:SetCard(skillInfo.actor.id, skillCard) then
		table.insert(self.handSkillList, skillCard);
	end
	self:updateTags();
	if FightManager.barrierId == 1003 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth3 then
		if FightHandSkillManager.isFirstCard then
			self:setIndexCardUnabled(1);
			-- FightHandSkillManager.isFirstCard = false;
		end
		local handSkill = self:getHandSkillList();
		for i=1,#handSkill do
			self:setIndexCardUnabled(i);
		end
	end

	if (FightManager.barrierId == 1001 and ActorManager.user_data.userguide.isnew == 0) then
		if FightHandSkillManager.isFirstCard then
			self:setIndexCardUnabled(1);
		end
		local handSkill = self:getHandSkillList();
		for i=1,#handSkill do
			self:setIndexCardUnabled(i);
		end
	end

	if (FightManager.barrierId == 1004 and ActorManager.user_data.userguide.isnew == GuideIndexExt.belove2) then
		if FightHandSkillManager.isSecondCard then
			local handSkill = self:getHandSkillList();
			for i=1,#handSkill do
				self:setIndexCardUnabled(i);
			end
		end
	end

	if FightManager.barrierId == 1002 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2 then
		if FightHandSkillManager.isFirstCard then
			self:setIndexCardUnabled(1);
		end
		if FightHandSkillManager.isSecondCard then
			self:setIndexCardUnabled(2);
		end
		local handSkill = self:getHandSkillList();
		for i=1,#handSkill do
			self:setIndexCardUnabled(i);
		end
	end
end

--更新卡牌tag
function FightSkillCardManager:updateTags()
	for i, card in ipairs(self.handSkillList) do
		card.Tag = i;
	end
end

--卡牌类型（反击起手攻击连击）, 附加一个count是攻击次数
function FightSkillCardManager:GetSkillClassImage(index, count)

	local temp = index; --如果等于0，则要另行区分攻击和辅助
	if temp == 0 then
		if count > 0 then
			--攻击
			temp = 0;
		else
			--辅助
			temp = 5;
		end
	end
	local map = {
		[0] = 'skillup/skilltype2.ccz'; -- 攻击
		[1] = 'skillup/skilltype1.ccz'; -- 起手
		[2] = 'skillup/skilltype5.ccz'; -- 反击
		[3] = 'skillup/skilltype4.ccz'; -- 连击
		[4] = 'skillup/skilltype7.ccz'; -- 追击
		[5] = 'skillup/skilltype3.ccz'; -- 辅助
	};
	return GetPicture(map[temp]);
end

--卡牌类型（反击起手攻击连击）, 附加一个count是攻击次数
function FightSkillCardManager:GetSkillClassType(index, count)

	local temp = index; --如果等于0，则要另行区分攻击和辅助
	if temp == 0 then
		if count > 0 then
			--攻击
			temp = 0;
		else
			--辅助
			temp = 5;
		end
	end
	return temp;
end

--初始化卡牌面板
function FightSkillCardManager:InitCardPanel(skillCard, skillInfo)
	local card = skillCard:GetLogicChild(0);
	local skill_name = card:GetLogicChild('name');
	local skill_type  = card:GetLogicChild('type');
	local skill_desc  = card:GetLogicChild('desc');
	local skill_icon  = card:GetLogicChild('item');

	local skill_data = resTableManager:GetValue(ResTable.skill, tostring(skillInfo.skill.m_resid), {'name', 'skill_property', 'skill_class', 'icon', 'next_skill', 'count'});

	local property = GetPicture('login/login_icon_' .. skill_data['skill_property'] .. '.ccz'); -- 没有判空

	local name = skill_data['name'];
	local icon = GetPicture('icon/' .. skill_data['icon'] .. '.ccz');
	local naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(skillInfo.actor.resID));
	local head_img = GetPicture('navi/' .. naviInfo['role_path_icon'] .. '.ccz');

	local skill_type_image = self:GetSkillClassImage(skill_data['skill_class'], skill_data['count']);

	--添加shing
	FightSkillCardManager:specialAddShing(skillCard, skillInfo);  

	local next_skill = skill_data['next_skill'];
	local bg = GetPicture('fight/fight_card1.ccz');
	if next_skill == 0 then -- 没下一层，代表技能已经进阶
		bg = GetPicture('fight/fight_card2.ccz');
	end
	card.Image = bg;

	skill_name.Text = name;
	skill_type.Image = skill_type_image;
	skill_desc.Image = property;
	skill_icon.Image = icon;

	--新手引导
	skillCard.skill_resid = skillInfo.skill.m_resid;

	--skillCard.anim_name = anim_name_map[skill_data['skill_property']];

end

function FightSkillCardManager:specialAddShing()
	-- 前10级此方法才有效
	if shiningoff or ActorManager.user_data.role.lvl.level > 10 then 
		return;
	end
	--已经有卡牌在shing则不添加 
	local isHaveShingCard = false;
	for _,card in pairs(FightSkillCardManager:getHandSkillList()) do
		if card.isShining then
			isHaveShingCard = true;
			break;
		end
	end
	if isHaveShingCard then
		return;
	end

	--判断卡牌类型是否是起手或者攻击
	local skillList = FightSkillCardManager:getHandSkillList();
	if skillList and #skillList > 0 then
		for  _,card in pairs(skillList) do
			local skill_data = resTableManager:GetValue(ResTable.skill, tostring(card.info.skill.m_resid), {'skill_class', 'count'});
			local skill_class_type = FightSkillCardManager:GetSkillClassType(skill_data['skill_class'], skill_data['count']);
			if skill_class_type == 1 or skill_class_type == 0 then
				--AddShing
				FightCardPanel:AddShining(card);
				break;
			end
		end
	end
end

function FightSkillCardManager:removeCardShing()
	if shiningoff or ActorManager.user_data.role.lvl.level > 10 then
		return;
	end
	for _,card in pairs(FightSkillCardManager:getHandSkillList()) do
		if card.isShining then
			FightCardPanel:RemoveShining(card);
		end
	end
end

--Clear
function FightSkillCardManager:Clear()
end

--获取卡牌是否能点
function FightSkillCardManager:GetEnableCard(cardControl)
	return cardControl.Enable;
end

--设置卡牌是否能点
function FightSkillCardManager:EnableCard(cardControl, isEnable)
	cardControl.Enable = isEnable;
end

--更新是否可点击的状态
function FightSkillCardManager:UpdateCardEnable(elapse)
	local can_counter = FightComboQueue:CanCounter();
	local can_combo = FightComboQueue:CanCombo();
	local status = FightComboQueue:getComboState();

	for i, card in ipairs(self.handSkillList) do
		local fighter = card.info.actor;
		if fighter:isInScreenCamera() then
			local is_enable = false;
			--连击状态判定
			if FightComboQueue:onComboQueue() then
				if can_counter then
					if (card.info.skill.m_skillClass == SkillClass.counterSkill) and FightComboQueue:haveType(card.info.skill.m_comboCause,status)then
						is_enable = true;
					end
				elseif can_combo then
					if (card.info.skill.m_skillClass == SkillClass.comboSkill) and FightComboQueue:haveType(card.info.skill.m_comboCause,status)then
						is_enable = true;
					end
				end
			else
				--非连击状态
				if fighter:isSpecialState(FightSpecialStateType.Silence) then
				else
					--if (card.info.skill.m_skillClass == SkillClass.ordinarySkill) or (card.info.skill.m_skillClass == SkillClass.startSkill) then
					local id = card.info.actor:GetID();
					if cardCDList[id] and (cardCDList[id].lock == false) then
						is_enable = true;
					end
					if not cardCDList[id] then
						is_enable = true;
					end
					--end
				end
			end
			self:EnableCard(card, is_enable);
		end
	end
end

--======================================================================================

function FightSkillCardManager:displayGuideEffect( x, y, isSelectPerson)
	-- if guideArmature then
	-- 	guideArmature:Destroy()
	-- end
	isNoviceBattle = true
	self.skillIndex = self.skillIndex + 1
	MainUI:HideMainUI()
	self:creatGuideArmature(x, y, isSelectPerson)

	FightUIManager:Active()
	MainUI:ShowMainUI()
end

function FightSkillCardManager:setCardEnabled()
	if FightManager.mFightType == FightType.noviceBattle then   --  卡牌可点击
		for i,card in ipairs(self.handSkillList) do
			self:EnableCard(card, true)
		end
		isCardCanClick = true
	end
end

function FightSkillCardManager:setIndexCardEnabled(index)
	for i,card in ipairs(self.handSkillList) do
		if i == index then
			self:EnableCard(card, true);
			break;
		end
	end
end

function FightSkillCardManager:setIndexCardUnabled(index)
	for i,card in ipairs(self.handSkillList) do
		if i == index then
			self:EnableCard(card, false);
			break;
		end
	end
end

function FightSkillCardManager:creatGuideArmature( x,y, isSelectPerson)
	-- if guideArmature then
	-- 	guideArmature:Destroy()
	-- end
	self:destroyGuideArmature()
	local path = GlobalData.EffectPath .. 'xinshouyindao_output/'
	AvatarManager:LoadFile(path)
	guideArmature = ArmatureUI( uiSystem:CreateControl('ArmatureUI') )
	guideArmature.Pick = false
	guideArmature.Margin = Rect(0, 0, 0, 0)
	guideArmature.Horizontal = ControlLayout.H_LEFT
	guideArmature.Vertical = ControlLayout.V_TOP
	guideArmature:LoadArmature('xinshouyindao')
	guideArmature:SetAnimation('play')
	guideArmature.ZOrder = 1000000000
	if isSelectPerson then
		guideArmature:SetScale(1.6,1.8)
		guideArmature.Translate = Vector2(x - 30, y + 10)
	else
		guideArmature:SetScale(1.2,1.2)
		guideArmature.Translate = Vector2(x, y)
	end

	topDesktop:AddChild(guideArmature)
	isCardCanClick = true
end

function FightSkillCardManager:destroyGuideArmature()
	if guideArmature then
		guideArmature:Destroy()
	end
end

function FightSkillCardManager:guideCradClick(index, content)
	-- FightManager:Pause();
	--引导释放卡牌
	FightManager.isTriggerSelect = true;
	FightSkillCardManager:setIndexCardEnabled(index);
	if content then
		PlotPanel:showContent();
		PlotPanel:changeContentPos(0,-30);
		PlotPanel:changeContentText( content );
	end
	--  播放引导特效
	local handSkill = self:getHandSkillList()
	FightSkillCardManager:displayGuideEffect( handSkill[index]:GetAbsTranslate().x + 40, handSkill[index]:GetAbsTranslate().y + 40, false)
end


--点击技能卡
function FightSkillCardManager:onClickCard( Args )
	if FightManager.barrierId == 1001 and ActorManager.user_data.userguide.isnew == 0 and FightHandSkillManager.isFirstCard then
		FightManager.isTriggerSelect = false;
		PlotPanel:unSetContentClickEvent();
	end
	if FightManager.mFightType == FightType.noviceBattle then
		if not isCardCanClick then
			return
		end
		if not FightManager.canClickCard then
			return
		end
		self:destroyGuideArmature()
		--  隐藏提示框
		PlotPanel:hideContent(  )
		-- PlotManager:Continue()
		FightShowSkillManager:RemoveShader()
	end

	if (FightManager.barrierId == 1002 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2) then
		if not self.guideCardClick then
			return;
		end
		if not FightHandSkillManager.isSecondCard then
			FightHandSkillManager.isFirstCard = false;
		end
		FightManager:Continue();
		FightHandSkillManager.isSecondCard = false;
		self:destroyGuideArmature()
		--  隐藏提示框
		PlotPanel:hideContent()
		-- PlotManager:Continue()
		FightShowSkillManager:RemoveShader()
	end
	--[[
	if FightManager.barrierId == 1003 and ActorManager.user_data.userguide.isnew == 8 then
		if not FightHandSkillManager.thirdRoundCardCanClick then
			return
		end
	end
	]]
	if (FightManager.barrierId == 1001 and ActorManager.user_data.userguide.isnew == 0) or
		(FightManager.barrierId == 1003 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth3) then
		if not self.guideCardClick then
			return;
		end
		self.isStop = true;
		if FightManager.barrierId == 1001 then
			FightManager:FightContinueGame()
		else
			FightManager:Continue()
		end

		FightHandSkillManager.isFirstCard = false;
		FightHandSkillManager.isFirstCardClicked = true;
		self:destroyGuideArmature()
		--  隐藏提示框
		PlotPanel:hideContent()
		-- PlotManager:Continue()
		FightShowSkillManager:RemoveShader()
	end
	--[[
	if (FightManager.barrierId == 1001 and ActorManager.user_data.userguide.isnew == 0) or
		(FightManager.barrierId == 1003 and ActorManager.user_data.userguide.isnew == 8) or
		(FightManager.barrierId == 1004 and ActorManager.user_data.userguide.isnew == 9) then
		if not self.guideCardClick then
			return;
		end
		self.isStop = true;
		if FightManager.barrierId == 1001 or 
			(FightManager.barrierId == 1004 and FightHandSkillManager.isSecondCard == false) then
			FightManager:FightContinueGame()
		else
			FightManager:Continue()
		end
		if FightHandSkillManager.isFirstCard == true and 
			FightManager.barrierId == 1004 and ActorManager.user_data.userguide.isnew == 9 then
			FightManager.isTriggerSelect = false;
		end
		if not FightHandSkillManager.isSecondCard then
			FightHandSkillManager.isFirstCard = false;
		end
		FightHandSkillManager.isSecondCard = false;
		FightHandSkillManager.isFirstCardClicked = true;
		self:destroyGuideArmature()
		--  隐藏提示框
		PlotPanel:hideContent()
		-- PlotManager:Continue()
		FightShowSkillManager:RemoveShader()
	end
	--]]
	---[[
	if FightManager.barrierId == 1004 and ActorManager.user_data.userguide.isnew == GuideIndexExt.belove2 then
		if not self.guideCardClick then
			return;
		end
		if FightHandSkillManager.isFirstCard then
			FightManager.isTriggerSelect = false;
			FightHandSkillManager.isFirstCard = false;
			FightManager:FightContinueGame()
		else
			FightHandSkillManager.isSecondCard = false;
			FightManager:Continue()
		end
		self:destroyGuideArmature()
		--  隐藏提示框
		PlotPanel:hideContent()
		-- PlotManager:Continue()
		FightShowSkillManager:RemoveShader()
	end
	--]]
	--移除shing
	FightSkillCardManager:removeCardShing();

	--技能CD处理
	local runSkill = function(card)
		local id = card.info.actor:GetID();
		if card.info.skill.m_skillClass == SkillClass.counterSkill or card.info.skill.m_skillClass == SkillClass.comboSkill then
		else
			if cardCDList[id] then
				if cardCDList[id].lock == true then
					return;
				end
			end
		end
		cardCDList[id] = cardCDList[id] and cardCDList[id] or {};
		cardCDList[id].skill = card.info.skill;
		cardCDList[id].actor = card.info.actor;
		cardCDList[id].lock = true;
		cardCDList[id].cd = -1;
		self:EnableCard(card,false);

		self:RunCardSkill(card);
	end

	--检测场上是否有可以打的怪
	if FightManager:isEnemyListEmpty() then
		return;
	else
	end

	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;
	local skillCard = self.handSkillList[tag];
	if skillCard ~= nil then
		runSkill(skillCard);
		self.guideCardClick = true;
		FightManager.canClickCard = false    --  技能卡不能点击
		isCardCanClick = false
	end
end

function FightSkillCardManager:unLockStartSkill()
	lockStart = false;
end
