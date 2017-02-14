
--========================================================================
--pve战斗胜利界面

PveWinPanel =
{
	levelUpData = {};
};

--控件
local panel;
local levelUpPanel;
local noLevelUpPanel;

local mainDesktop
local pveWinPanel
local bg
local sureBtn
local titleImg
local lightImg
local blackBG
local rewardList = {};
local goodsPanel;
local partnerList = {}
local partnerItemList = {};
local oneHeroPanel;
local oneHeroHead;
local ExpLabel
local loveLabel
local goBackCityBtn
local tryAgainBtn
local backAnimation
local frontAnimation

local expTimer = 0
local updateRate = 0.01
local progressBarList = {}
local progressBarExp
local resultInfo
local displayGoodsTimer
local displayedGoodsNum = 1
local isShowCoin = true
local heroNum = 0  --  统计上阵英雄的人数

local getCurMaxExp = function(exp)
	local curExp = 0;
	local maxExp = 0;
	local nextExp = 0;
	local lastExp = 0;
	for i=PveWinPanel.levelUpData[1].level, 1, -1 do
		nextExp = resTableManager:GetValue(ResTable.levelup, tostring(i), 'exp');
		lastExp = (i==1) and 0 or resTableManager:GetValue(ResTable.levelup, tostring(i-1), 'exp');
		if exp >= lastExp and exp < nextExp then
			break;
		end
	end
	curExp = exp - lastExp;
	maxExp = nextExp - lastExp;
	return curExp, maxExp;
end

--初始化
function PveWinPanel:Initialize(desktop)
	--变量
	expTimer = 0;
	self.updateMaxTimes = Configuration.TimeForExpEffect/updateRate;

	--控件
	mainDesktop = desktop;
	levelUpPanel = mainDesktop:GetLogicChild('win');
	levelUpPanel:IncRefCount();
	noLevelUpPanel = mainDesktop:GetLogicChild('win_nolv');
	noLevelUpPanel:IncRefCount();

	pveWinPanel = desktop:GetLogicChild('pveWinPanel')
	pveWinPanel:IncRefCount()
	pveWinPanel.ZOrder = PanelZOrder.win_pve;
	bg = pveWinPanel:GetLogicChild('bg')
	tryAgainBtn = pveWinPanel:GetLogicChild('tryAgainBtn')
	goBackCityBtn = pveWinPanel:GetLogicChild('goBackCityBtn')
	titleImg = pveWinPanel:GetLogicChild('titileImg')
	titleImg.Visibility = Visibility.Hidden
	lightImg = pveWinPanel:GetLogicChild('lightImg')
	lightImg.Visibility = Visibility.Hidden

	tryAgainBtn:SubscribeScriptedEvent('Button::ClickEvent', 'FightOverUIManager:OnTryAgain')
	goBackCityBtn:SubscribeScriptedEvent('Button::ClickEvent','FightOverUIManager:OnBackToCity')
	blackBG = pveWinPanel:GetLogicChild('blackBG')
	ExpLabel = blackBG:GetLogicChild('EXPLabel')
	loveLabel = blackBG:GetLogicChild('loveLabel')
	oneHeroPanel = blackBG:GetLogicChild('oneHero')       --  只有一个人参战时显示的界面
	oneHeroHead = customUserControl.new(oneHeroPanel:GetLogicChild('hero'), 'cardHeadTemplate');

	--  物品奖励
	goodsPanel = blackBG:GetLogicChild('goodsPanel');
	for i=1,6 do
		rewardList[i] = customUserControl.new(goodsPanel:GetLogicChild('goods' .. i), 'itemTemplate');
	end
	--  多个英雄参战时显示
	for i=1,5 do
		partnerList[i] = blackBG:GetLogicChild('hero' .. i)
		partnerItemList[i] = customUserControl.new(partnerList[i]:GetLogicChild('hero'), 'cardHeadTemplate')
	end
	local path = GlobalData.EffectPath .. 'pveNormalSuccess_output/'
	AvatarManager:LoadFile(path)

	--初始化时隐藏panel
	levelUpPanel.Visibility = Visibility.Hidden;
	noLevelUpPanel.Visibility = Visibility.Hidden;
	pveWinPanel.Visibility = Visibility.Hidden
end

--重新获得控件引用
function PveWinPanel:ResetControlRefence(isLevelUp)
	if isLevelUp then
		panel = pveWinPanel;
		--labelLevelUp = Label(panel:GetLogicChild('levelUp'));
		--labelLevelUp.Text = ' ';			--设置升级label显示文字
		panel.Size = Size(530, 450);
	else
		--panel = noLevelUpPanel;
		--panel.Size = Size(530, 428);

		panel = pveWinPanel;
	end
end

--销毁
function PveWinPanel:Destroy()
	levelUpPanel:DecRefCount();
	levelUpPanel = nil;

	noLevelUpPanel:DecRefCount();
	noLevelUpPanel = nil;

end

--显示
function PveWinPanel:Show(isLevelUp, isShowTryAgain)
	--进阶开启前，新手引导要求不让重播和再次战斗
	if false then
	--if Task:getMainTaskId() < SystemTaskId.advance then    --by Dongenlai
		btnTryAgain.Visibility = Visibility.Hidden;
	else
		if isShowTryAgain then
			btnTryAgain.Visibility = Visibility.Visible;
		else
			btnTryAgain.Visibility = Visibility.Hidden;
		end
	end

end

--隐藏
function PveWinPanel:Hide()
	-- for _,v in ipairs(brushStarList) do
	-- 	v.Visibility = Visibility.Hidden;
	-- end
	--lightArmature:Destroy();
	--goodsPanel:RemoveAllChildren();
	pveWinPanel.Visibility = Visibility.Hidden
	lightImg.Visibility = Visibility.Hidden
	titleImg.Visibility = Visibility.Hidden
	--mainDesktop:UndoModal();
end

function PveWinPanel:ShowWinPanel( resultData )

	--前三关引导完成
	if ActorManager.user_data.userguide.isnew == 0 and FightManager.barrierId == 1001 then
		FightSkillCardManager:destroyGuideArmature();
		PlotPanel:hideContent();
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.fight1, 1);
		RolePortraitPanel:setLoginRewardButtonVisible();
	end
	if ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2 and FightManager.barrierId == 1002 then
		FightSkillCardManager:destroyGuideArmature();
		PlotPanel:hideContent();
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.fight2, 1);
	end
	if ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth3 and FightManager.barrierId == 1003 then
		FightSkillCardManager:destroyGuideArmature();
		PlotPanel:hideContent();
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.fight3, 1);
	end

	FightSkillCardManager:Hide()
	for i=1,5 do
		partnerList[i].Translate = Vector2(0,0)
	end
	ExpLabel.Translate = Vector2(0,0)
	loveLabel.Translate = Vector2(0,0)

	oneHeroPanel.Visibility = Visibility.Hidden
	blackBG.Visibility = Visibility.Hidden
	tryAgainBtn.Visibility = Visibility.Hidden
	goBackCityBtn.Visibility = Visibility.Hidden
	resultInfo = resultData
	for i=1,5 do
		partnerList[i].Visibility = Visibility.Visible
	end
	for i=1,6 do
		rewardList[i]:Hide();
	end
	if backAnimation then          --  销毁动画
		backAnimation:Destroy()
	end
	if frontAnimation then
		frontAnimation:Destroy()
	end

	--显示队员
	local team = MutipleTeam:getCurrentTeam()   --   参加战斗的队伍，0代表是主角，-1代表没有英雄，大于0表示有英雄
	--  属性试炼   ?  限时副本
	if resultInfo.fightType and resultInfo.fightType == FightType.limitround then         --  如果是属性试炼
		team = MutipleTeam.teamList[SpecialTeam.PropertyTeam]
	end
	if resultInfo.fightType and resultInfo.fightType == FightType.invasion then
		local teamId = MutipleTeam:getDefault()
		team = MutipleTeam:getTeam(teamId)
	end

	heroNum = 0
	for i=5,1,-1 do
		if team[i] >= 0 then
			heroNum = heroNum + 1
		end
	end
	pveWinPanel.Visibility = Visibility.Visible
	--  把英雄居中显示
	if heroNum == 2 then
		partnerList[1].Translate = Vector2(150,0)
		partnerList[2].Translate = Vector2(150,0)
		ExpLabel.Translate = Vector2(150,0)
		loveLabel.Translate = Vector2(150,0)
	elseif heroNum == 3 then
		partnerList[1].Translate = Vector2(100,0)
		partnerList[2].Translate = Vector2(100,0)
		partnerList[3].Translate = Vector2(100,0)
		ExpLabel.Translate = Vector2(100,0)
		loveLabel.Translate = Vector2(100,0)
	elseif heroNum == 4 then
		partnerList[1].Translate = Vector2(50,0)
		partnerList[2].Translate = Vector2(50,0)
		partnerList[3].Translate = Vector2(50,0)
		partnerList[4].Translate = Vector2(50,0)
		ExpLabel.Translate = Vector2(50,0)
		loveLabel.Translate = Vector2(50,0)
	elseif heroNum == 5 then
		--  什么也不做
	end


	--  物品居中显示
	local goodsNum = 0;
	resultInfo.goodsList = resultInfo.goodsList and resultInfo.goodsList or {};
	local isGoodsListHaveCoin = false;
	local coinIndex = 0;
	for i=1,#resultInfo.goodsList do
		if resultInfo.goodsList[i] and resultInfo.goodsList[i].resid == 10001 then
			coinIndex = i;
			isGoodsListHaveCoin = true;
			break;
		end
	end
	if resultInfo.coin and resultInfo.coin > 0 then
		if isGoodsListHaveCoin then
			resultInfo.goodsList[coinIndex].num = resultInfo.goodsList[coinIndex].num + resultInfo.coin;
		else
			goodsNum = goodsNum + 1
			resultInfo.goodsList[#resultInfo.goodsList+1] = {resid = 10001, num = resultInfo.coin};
		end
	end
	goodsNum = #resultInfo.goodsList;

	goodsPanel.Size = Size(60*goodsNum + 30*(goodsNum-1), 60);
	if FightManager.currentAchievement then
		local totalNum = 0
		for i=1, 4 do
			local isComplete = FightManager.currentAchievement:getAchievementList()[i].isComplete
			if isComplete then totalNum = totalNum + 1 end
		end
		--  播放光特效
		--[[
		backAnimation = PlayEffect('zhandoushengli_output/', Rect(0, 170, 0, 0), 'guang', pveWinPanel)
		backAnimation.ZOrder = 5
		--]]
		backAnimation = ArmatureUI( uiSystem:CreateControl('ArmatureUI') )
		backAnimation.Pick = false
		backAnimation.Horizontal = ControlLayout.H_CENTER
		backAnimation.Vertical = ControlLayout.V_CENTER
		backAnimation.Margin = Rect(0, 170, 0, 0);
		backAnimation:LoadArmature('back')
		pveWinPanel:AddChild(backAnimation)
		backAnimation:SetAnimation('play')
		backAnimation:SetScale(2.0,2.0)
		backAnimation.ZOrder = 5
		if totalNum > 0 then
			frontAnimation = ArmatureUI( uiSystem:CreateControl('ArmatureUI') )
			frontAnimation.Pick = false
			frontAnimation.Horizontal = ControlLayout.H_CENTER
			frontAnimation.Vertical = ControlLayout.V_CENTER
			frontAnimation:LoadArmature('front_' .. totalNum)
			pveWinPanel:AddChild(frontAnimation)
			frontAnimation:SetAnimation('play')
			frontAnimation:SetScriptAnimationCallback('PveWinPanel:playSecondEffect', 1)
			frontAnimation.ZOrder = 100
			frontAnimation.Translate = Vector2(0, -145)
			frontAnimation:SetScale(1.5,1.5)
		else
			-- lightImg.Visibility = Visibility.Visible
			titleImg.Visibility = Visibility.Visible
			if heroNum == 1 then
				self:showOneHero()
			else
				self:showHeroAndGoods()
			end
		end
	else
		-- lightImg.Visibility = Visibility.Visible
		titleImg.Visibility = Visibility.Visible
		if heroNum == 1 then
			self:showOneHero()
		else
			self:showHeroAndGoods()
		end
	end
	if resultInfo.lovevalue then
		self:isMaxLove()
	end
	PropertyRoundPanel:refresh();


	if ActorManager.user_data.role.lvl.level < 10 or (FightManager.barrierId >= RoundIDSection.SoulBegin and FightManager.barrierId <= RoundIDSection.SoulEnd) then
		tryAgainBtn.Enable = false;
	else
		tryAgainBtn.Enable = true;
	end
end

function PveWinPanel:playSecondEffect( armature, id )
	if armature:GetAnimation() == 'play' then
		armature:SetAnimation('keep')
	end
	if heroNum == 1 then
		self:showOneHero()
	else
		self:showHeroAndGoods()
	end
end
function PveWinPanel:isMaxLove()
	if heroNum == 1 then
		local member = ActorManager:GetRole(0)      --  一个人可能是主角,属性试炼时一个人也不一定是主角
		local team = MutipleTeam:getCurrentTeam()
		if resultInfo.fightType and resultInfo.fightType == FightType.limitround then         --  如果是属性试炼
			team = MutipleTeam.teamList[SpecialTeam.PropertyTeam]
		end
		if resultInfo.fightType and resultInfo.fightType == FightType.invasion then
			local teamId = MutipleTeam:getDefault()
			team = MutipleTeam:getTeam(teamId)
		end

		for i=5,1,-1 do
			if team[i] >= 0 then
				member = ActorManager:GetRole(team[i])
			end
		end
		local rand = 0;
		if member.lvl.lovelevel == 4 then
			rand = 16;
		else
			local totalLovevalue = resTableManager:GetValue(ResTable.love_task, tostring(member.resid * 100 + member.lvl.lovelevel + 1), 'love_max');
			local beforeLoveValue = member.lovevalue;
			local curLovevalue = (resultInfo.lovevalue + member.lovevalue) >= totalLovevalue and totalLovevalue or (resultInfo.lovevalue + member.lovevalue);
			rand = math.floor(curLovevalue / totalLovevalue * 16);

			if beforeLoveValue < totalLovevalue and curLovevalue == totalLovevalue and member.lvl.lovelevel < 4 then
				--爱恋满
				FightOverUIManager.loveMax = true
			end
		end
	else
		local team = MutipleTeam:getCurrentTeam()
		if resultInfo.fightType and resultInfo.fightType == FightType.limitround then         --  如果是属性试炼
			team = MutipleTeam.teamList[SpecialTeam.PropertyTeam]
		end
		if resultInfo.fightType and resultInfo.fightType == FightType.invasion then
			local teamId = MutipleTeam:getDefault()
			team = MutipleTeam:getTeam(teamId)
		end

		for i=5, 1,-1 do
			if team[i] >= 0 then
				local partner = ActorManager:GetRole(team[i])
				if partner.lvl.lovelevel == 4 then
				else
					local totalLovevalue = resTableManager:GetValue(ResTable.love_task, tostring(partner.resid * 100 + partner.lvl.lovelevel + 1), 'love_max');
					local beforeLoveValue = partner.lovevalue;
					local curLovevalue = (resultInfo.lovevalue + partner.lovevalue) >= totalLovevalue and totalLovevalue or (resultInfo.lovevalue + partner.lovevalue);
					if beforeLoveValue < totalLovevalue and curLovevalue == totalLovevalue and partner.lvl.lovelevel < 4 then
					--爱恋满
						FightOverUIManager.loveMax = true
						break
					end
				end
			end
		end
	end
end

function PveWinPanel:showHeroAndGoods(  )
	if (ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2 and FightManager.barrierId == 1002) or
		(ActorManager.user_data.userguide.isnew == GuideIndexExt.bfcardrolelvup and FightManager.barrierId == 1003) then
		UserGuidePanel:ShowGuideShade(goBackCityBtn,GuideEffectType.hand,GuideTipPos.right, '', 0.3);
	end

	blackBG.Visibility = Visibility.Visible
	tryAgainBtn.Visibility = Visibility.Visible
	goBackCityBtn.Visibility = Visibility.Visible

	--  显示队员
	local team = MutipleTeam:getCurrentTeam()
	if resultInfo.fightType and resultInfo.fightType == FightType.limitround then         --  如果是属性试炼
		team = MutipleTeam.teamList[SpecialTeam.PropertyTeam]
	end
	if resultInfo.fightType and resultInfo.fightType == FightType.invasion then
		local teamId = MutipleTeam:getDefault()
		team = MutipleTeam:getTeam(teamId)
	end
	-- partnerList[1].Visibility = Visibility.Hidden
	local index = 1
	for i=5, 1,-1 do
		if team[i] >= 0 then
			local member = ActorManager:GetRole(team[i])
			self:initWithPartner(member,index,resultInfo)
			index = index + 1
		end
	end
	--  把没有英雄的给隐藏
	for i= index ,5 do
		partnerList[i].Visibility = Visibility.Hidden
	end

		--  经验增长动画
	self.totalAddExp = resultInfo.exp or 0
	self.updateTimes = self.updateMaxTimes
	--  先初始化经验值
	local temp = 1
	for i=1, 5 do
		if team[i] >= 0 then
			local member = ActorManager:GetRole(team[i])
			local exp = member.lvl.exp
			local curExp, maxExp = getCurMaxExp(exp)
			progressBarList[temp].CurValue = curExp
			progressBarList[temp].MaxValue = maxExp
			temp = temp + 1
		end
	end
	--  显示物品
	-- self:showGoods(resultInfo)
	displayedGoodsNum = 1;
	displayGoodsTimer = timerManager:CreateTimer(0.5, 'PveWinPanel:showGoodsOneByOne', 0,true);
	self:refreshExp()
	tryAgainBtn.Visibility = Visibility.Hidden
	goBackCityBtn.Visibility = Visibility.Hidden
end

function PveWinPanel:showOneHero(  )
	oneHeroPanel.Visibility = Visibility.Visible
	blackBG.Visibility = Visibility.Visible
	tryAgainBtn.Visibility = Visibility.Hidden
	goBackCityBtn.Visibility = Visibility.Hidden
	for i=1,5 do
		partnerList[i].Visibility = Visibility.Hidden     --  隐藏多人胜利界面
	end
	ExpLabel.Visibility = Visibility.Hidden
	loveLabel.Visibility = Visibility.Hidden

	local member = ActorManager:GetRole(0)      --  一个人可能是主角,属性试炼时一个人也不一定是主角
	local team = MutipleTeam:getCurrentTeam()
	if resultInfo.fightType and resultInfo.fightType == FightType.limitround then         --  如果是属性试炼
		team = MutipleTeam.teamList[SpecialTeam.PropertyTeam]
	end
	if resultInfo.fightType and resultInfo.fightType == FightType.invasion then
		local teamId = MutipleTeam:getDefault()
		team = MutipleTeam:getTeam(teamId)
	end

	for i=5,1,-1 do
		if team[i] >= 0 then
			member = ActorManager:GetRole(team[i])
		end
	end

	local exp = oneHeroPanel:GetLogicChild('exp1')

	oneHeroHead.initWithPid(member.pid, 75);
	if not resultInfo.lovevalue then
		loveLabel.Visibility = Visibility.Hidden

		progressBarList[1] = exp
		self.totalAddExp = resultInfo.exp or 0
		self.updateTimes = self.updateMaxTimes
		--  先初始化经验值
		local exp = member.lvl.exp
		local curExp, maxExp = getCurMaxExp(exp)
		progressBarList[1].CurValue = curExp
		progressBarList[1].MaxValue = maxExp

		-- self:showGoods(resultData)
		displayedGoodsNum = 1;
		displayGoodsTimer = timerManager:CreateTimer(0.3, 'PveWinPanel:showGoodsOneByOne', 0,true);
		self:refreshExp()
		return
	end

	--  设置爱恋
	local rand = 0;
	if member.lvl.lovelevel == 4 then
		rand = 16;
	else
		local totalLovevalue = resTableManager:GetValue(ResTable.love_task, tostring(member.resid * 100 + member.lvl.lovelevel + 1), 'love_max');
		local beforeLoveValue = member.lovevalue;
		local curLovevalue = (resultInfo.lovevalue + member.lovevalue) >= totalLovevalue and totalLovevalue or (resultInfo.lovevalue + member.lovevalue);
		member.lovevalue = curLovevalue;
		rand = math.floor(curLovevalue / totalLovevalue * 16);

		if beforeLoveValue < totalLovevalue and curLovevalue == totalLovevalue and member.lvl.lovelevel < 4 then
			--爱恋满
			table.insert(LoveMaxPanel.roleList, member);
		end
	end
	local heartFullNum = math.floor(rand/4)         --  完全红色的花瓣数
	local leftHeartNum = math.mod(rand,4)           --  剩余未满的数量
	if rand == 16 then    --  爱恋满16时，播放音效
		local voicePath = resTableManager:GetValue(ResTable.actor, tostring(member.resid), 'voice');
    	--SoundManager:PlayVoice(tostring(voicePath));
	end
	for i=1,heartFullNum do
		for j=1,4 do       --  换图片Brush
			local heart = oneHeroPanel:GetLogicChild('heart' .. i ):GetLogicChild(0):GetLogicChild('heart' .. j)
			-- heart.Image = GetPicture('dynamicPic/heart_red.png')
			heart.Background = Converter.String2Brush("godsSenki.heart_red")
		end
	end
	if leftHeartNum and leftHeartNum > 0 and leftHeartNum < 4 then
		for i=1,leftHeartNum do
			local heart = oneHeroPanel:GetLogicChild('heart' .. ( heartFullNum + 1) ):GetLogicChild(0):GetLogicChild('heart' .. i )
			-- heart.Image = GetPicture('dynamicPic/heart_red.png')
			heart.Background = Converter.String2Brush("godsSenki.heart_red")
		end
		--  给没恋爱度的图片
		for i= leftHeartNum + 1, 4 do
			local heart = oneHeroPanel:GetLogicChild('heart' .. ( heartFullNum + 1) ):GetLogicChild(0):GetLogicChild('heart' .. i )
			-- heart.Image = GetPicture('dynamicPic/heart_red.png')
			heart.Background = Converter.String2Brush("godsSenki.heart_black")
		end
	end

	if heartFullNum and heartFullNum < 4 then
		local temp = 0
		if leftHeartNum == 0 then
			temp = heartFullNum + 1
		else
			temp = heartFullNum + 2
		end
		for i=temp, 4 do
			for j=1,4 do       --  换图片
				local heart = oneHeroPanel:GetLogicChild('heart' .. i ):GetLogicChild(0):GetLogicChild('heart' .. j)
				-- heart.Image = GetPicture('dynamicPic/heart_red.png')
				heart.Background = Converter.String2Brush("godsSenki.heart_black")
			end
		end
	end

	progressBarList[1] = exp
	self.totalAddExp = resultInfo.exp or 0
	self.updateTimes = self.updateMaxTimes
	--  先初始化经验值
	local exp = member.lvl.exp
	local curExp, maxExp = getCurMaxExp(exp)
	progressBarList[1].CurValue = curExp
	progressBarList[1].MaxValue = maxExp

	-- self:showGoods(resultData)
	displayedGoodsNum = 1;
	displayGoodsTimer = timerManager:CreateTimer(0.3, 'PveWinPanel:showGoodsOneByOne', 0,true);
	self:refreshExp()
end

function PveWinPanel:initWithPartner( partner, index, resultData )
	if index > 5 then
		index = 1;
	end
	partnerList[index].Visibility = Visibility.Visible;
	local exp = partnerList[index]:GetLogicChild('exp1');

	partnerItemList[index].initWithPid(partner.pid, 75);

	progressBarList[index] = exp

	if not resultData.lovevalue then
		loveLabel.Visibility = Visibility.Hidden;
		for i=1, 4 do
			for j=1,4 do       --  换图片
				partnerList[index]:GetLogicChild('heart' .. i ):GetLogicChild(0):GetLogicChild('heart' .. j).Visibility = Visibility.Hidden;
			end
		end
		return
	end

	local rand = 0;
	if partner.lvl.lovelevel == 4 then
		rand = 16;
	else
		local totalLovevalue = resTableManager:GetValue(ResTable.love_task, tostring(partner.resid * 100 + partner.lvl.lovelevel + 1), 'love_max');
		local beforeLoveValue = partner.lovevalue;
		local curLovevalue = (resultData.lovevalue + partner.lovevalue) >= totalLovevalue and totalLovevalue or (resultData.lovevalue + partner.lovevalue);
		partner.lovevalue = curLovevalue;
		rand = math.floor(curLovevalue / totalLovevalue * 16);

		if beforeLoveValue < totalLovevalue and curLovevalue == totalLovevalue and partner.lvl.lovelevel < 4 then
			--爱恋满
			table.insert(LoveMaxPanel.roleList, partner);
		end
	end

	--  设置爱恋
	local heartFullNum = math.floor(rand/4)         --  完全红色的花瓣数
	local leftHeartNum = math.mod(rand,4)           --  剩余未满的数量
	if rand == 16 then    --  爱恋满16时，播放音效
		local voicePath = resTableManager:GetValue(ResTable.actor, tostring(partner.resid), 'voice');
    	--SoundManager:PlayVoice(tostring(voicePath));
	end
	for i=1,heartFullNum do
		for j=1,4 do       --  换图片
			local heart = partnerList[index]:GetLogicChild('heart' .. i ):GetLogicChild(0):GetLogicChild('heart' .. j)
			-- heart.Image = GetPicture('dynamicPic/heart_red.png')
			heart.Background = Converter.String2Brush("godsSenki.heart_red")
		end
	end
	if leftHeartNum and leftHeartNum > 0 and leftHeartNum < 4 then
		for i=1,leftHeartNum do
			local heart = partnerList[index]:GetLogicChild('heart' .. ( heartFullNum + 1) ):GetLogicChild(0):GetLogicChild('heart' .. i )
			-- heart.Image = GetPicture('dynamicPic/heart_red.png')
			heart.Background = Converter.String2Brush("godsSenki.heart_red")
		end
		--  给没恋爱度的图片
		for i= leftHeartNum + 1, 4 do
			local heart = partnerList[index]:GetLogicChild('heart' .. ( heartFullNum + 1) ):GetLogicChild(0):GetLogicChild('heart' .. i )
			-- heart.Image = GetPicture('dynamicPic/heart_red.png')
			heart.Background = Converter.String2Brush("godsSenki.heart_black")
		end
	end

	if heartFullNum and heartFullNum < 4 then
		if leftHeartNum == 0 then
			heartFullNum = heartFullNum + 1
		else
			heartFullNum = heartFullNum + 2
		end
		for i=heartFullNum, 4 do
			for j=1,4 do       --  换图片
				local heart = partnerList[index]:GetLogicChild('heart' .. i ):GetLogicChild(0):GetLogicChild('heart' .. j)
				-- heart.Image = GetPicture('dynamicPic/heart_red.png')
				heart.Background = Converter.String2Brush("godsSenki.heart_black")
			end
		end
	end
end

function PveWinPanel:showGoodsOneByOne()
	if displayedGoodsNum > #resultInfo.goodsList then
		for i=displayedGoodsNum, 6 do
			rewardList[i]:Hide();
		end
		tryAgainBtn.Visibility = Visibility.Visible;
		goBackCityBtn.Visibility = Visibility.Visible;

		--如果有英雄的爱恋满则弹出loveMaxPanel
		LoveMaxPanel.isGotoLovePanel = false;
		if LoveMaxPanel.roleList and #LoveMaxPanel.roleList > 0 then
			LoveMaxPanel:Show();
		end

		if displayGoodsTimer then
			timerManager:DestroyTimer(displayGoodsTimer);
			displayGoodsTimer = 0;
		end
		timerManager:CreateTimer(0.1, 'PveWinPanel:onEnterUserGuilde', 0, true)
		return;
	end
	local item = rewardList[displayedGoodsNum];
	item:Show();
	local good = resultInfo.goodsList[displayedGoodsNum];
	item.initWithInfo(good.resid, good.num, 60, true);
	displayedGoodsNum = displayedGoodsNum + 1;

	displayGoodsTimer = timerManager:CreateTimer(0.3, 'PveWinPanel:showGoodsOneByOne', 0, true);
end

function PveWinPanel:onEnterUserGuilde(  )
	if FightType.limitround == FightManager:GetFightType() and UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and UserGuidePanel.isPropertyBegin then
		UserGuidePanel:ShowGuideShade( goBackCityBtn,GuideEffectType.hand,GuideTipPos.right,'', 0.3)
	end
end

function PveWinPanel:showGoods(resultInfo)
	return;
end


--显示某个星星
function PveWinPanel:starAppearAnimationEnd(armature, index)
	if armature:IsCurAnimationLoop() then
		--循环动作
		armature:Replay();
		return;
	end

	--panel.Storyboard = '';
	--panel.Storyboard = 'storyboard.fightWinCameraShake';

	brushStarList[index].Visibility = Visibility.Visible;
	uiSystem:AddAutoReleaseControl(armature);
end

function PveWinPanel:refreshExp()
	if expTimer == 0 then
		--播放经验增长音效
		PlaySound('expAdd');

		expTimer = timerManager:CreateTimer(updateRate, 'PveWinPanel:refreshExp', 0)
	end

	--如果更新次数为0 则销毁timer
	if 0 >= self.updateTimes then
		timerManager:DestroyTimer(expTimer);
		expTimer = 0;
	end

	local team = MutipleTeam:getCurrentTeam();
	if resultInfo.fightType and resultInfo.fightType == FightType.limitround then         --  如果是属性试炼
		team = MutipleTeam.teamList[SpecialTeam.PropertyTeam]
	end
	local teamNum = 0
	for i=5,1,-1 do
		if team[i] >=0 then
			teamNum = teamNum + 1
		end
	end
	local index = 1
	for i=5,1,-1 do
		if team[i] >= 0 then
			local member = ActorManager:GetRole(team[i])
			local exp = member.lvl.exp - math.floor(self.updateTimes * CheckDiv(self.totalAddExp/self.updateMaxTimes));
			local curExp, maxExp = getCurMaxExp(exp);
			if (self.updateTimes ~= self.updateMaxTimes) and (maxExp > progressBarList[index].MaxValue) then
				--播放升级音效
				PlaySound('levelup');
			end
			progressBarList[index].MaxValue = maxExp
			progressBarList[index].CurValue = curExp
			index = index + 1
		end
	end
	-- if teamNum == 1 then
	-- 	local member = ActorManager:GetRole(team[5])
	-- 	for i=1,5 do
	-- 		if team[i] >= 0 then
	-- 			member = ActorManager:GetRole(team[i])
	-- 		end
	-- 	end
	-- 	local exp = member.lvl.exp - math.floor(self.updateTimes * (self.totalAddExp/self.updateMaxTimes))
	-- 	local curExp, maxExp = getCurMaxExp(exp)
	-- 	if (self.updateTimes ~= self.updateMaxTimes) and (maxExp > progressBarExp.MaxValue) then
	-- 				--播放升级音效
	-- 			PlaySound('levelup');
	-- 	end
	-- 	progressBarExp.CurValue = curExp
	-- 	progressBarExp.MaxValue = maxExp
	-- else
	-- 	local index = 1
	-- 	for i=1,5 do
	-- 		if team[i] == 0 then
	-- 			local member = ActorManager:GetRole(team[i])
	-- 			local exp = member.lvl.exp - math.floor(self.updateTimes * (self.totalAddExp/self.updateMaxTimes));
	-- 			local curExp, maxExp = getCurMaxExp(exp);
	-- 			if (self.updateTimes ~= self.updateMaxTimes) and (maxExp > progressBarExp.MaxValue) then
	-- 				--播放升级音效
	-- 				PlaySound('levelup');
	-- 			end
	-- 			maxExp = 100
	-- 			curExp = -10
	-- 			progressBarExp.CurValue = curExp
	-- 			progressBarExp.MaxValue = maxExp
	-- 		elseif team[i] > 0 then
	-- 			local member = ActorManager:GetRole(team[i])
	-- 			local exp = member.lvl.exp - math.floor(self.updateTimes * (self.totalAddExp/self.updateMaxTimes));
	-- 			local curExp, maxExp = getCurMaxExp(exp);
	-- 			if (self.updateTimes ~= self.updateMaxTimes) and (maxExp > progressBarList[index].MaxValue) then
	-- 				--播放升级音效
	-- 				PlaySound('levelup');
	-- 			end
	-- 			progressBarList[index].CurValue = curExp
	-- 			progressBarList[index].MaxValue = maxExp
	-- 			index = index + 1
	-- 		end
	-- 	end
	-- end

	self.updateTimes = self.updateTimes - 1;
end

--杀星战斗胜利结束界面
function PveWinPanel:ShowInvasionWin(count, goodsList)
	self:ResetControlRefence(false);
	-- line2.Visibility = Visibility.Hidden;
	panel.Size = Size(530, 348);

	self:ShowWinPanel(goodsList)
	--显示星星
	-- self:showStars(count);
	-- --显示掉落物品
	-- self:showGoods(goodsList, false);
	-- --显示
	-- self:Show(false, false);
end
