--pveBarrierPanel.lua

--========================================================================
--pve关卡ui

PveBarrierPanel =
	{
	 	latestCommon				= 0;		--可以进入的最前的关卡id
		latestElite					= 0;		--可以进入的最前的精英关卡id
		cityId						= 0;		--当前的大章ID

		fubenstate					= 0;		--0为普通关卡状态， 1为精英关卡状态
		
		taskEnter					= false;	--任务引导进入
		curPageId					= 1;		--当前页
		isFirstTimePassEliteRound 	= false;
	};

--常量
local numTab = {
	["0"] = 0, ["1"] = 1, ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5, ["6"] = 6, ["7"] = 7, ["8"] = 8, ["9"] = 9, ["a"] = 10, ["b"] = 11, ["c"] = 12, ["d"] = 13, ["e"] = 14, ["f"] = 15, ["g"] = 16, ["h"] = 17, ["i"] = 18, ["j"] = 19, ["k"] = 20, ["l"] = 21, ["m"] = 22, ["n"] = 23, ["o"] = 24, ["p"] = 25, ["q"] = 26, ["r"] = 27, ["s"] = 28, ["u"] = 29, ["v"] = 30, ["w"] = 31, ["x"] = 32, ["y"] = 33, ["z"] = 34, }

--变量
local rewardList = {}; 				--关卡奖励状态
local bCList = {};					--普通关卡表
local bEList = {};					--精英关卡表

--控件
local mainDesktop;
local barrierPanel;
local titleLabel;

local infoPanel;
local powerProgress;
local labelYB;

local btnPre;
local btnNext;
local changeFuBen;
local starCount;
local curStarLabel;
local buttonPanelList;
local elitebuttonPanelList;

local iconPanel;
local starPanel;

local rewardPanel;

local chapterName      --  章节数

local rewardCount = 0   --  用于记录当前章节没有领取的奖励数
local getStarsNumber = 0       --  当前章节获得的星星数量
local beforeFightStarNum = 0   --  开始战斗前关卡的星星数
local selectRoundID = 0    --  当前选中的关卡ID
local afterFightStar           --  战斗结束后获得的星星数量
local circleTip                --  提示有关卡奖励的红点

local resetPanel;				--重置panel
local resetNumLabel;			--重置数字
local shandow;

local isshowGuide1 = true;
local isshowGuide2 = true;
local isshowGuide3 = true;
local isshowGuide4 = true;

--方法
local findCityId = function(bid)
	return resTableManager:GetValue(ResTable.barriers, tostring(bid), 'city_id');
end

local getStarFromRes = function(res)
	local stars = 0;
	if res == '0' then
		stars = 0;
	elseif res == 'f' then
		stars = 4;
	elseif res == '1' or res == '2' or res == '4' or res == '8' then
		stars = 1;
	elseif res == 'e' or res == 'd' or res == 'b' or res == '7' then
		stars = 3;
	elseif res == '3' or res == '5' or res == '6' or res == '9' or res == 'a' or res == 'c' then
		stars = 2;
	end
	return stars;
end

function PveBarrierPanel:InitPanel(desktop)
	--变量初始化
	self.latestCommon				= 0;		--可以进入的最前的关卡id

	self.latestElite				= 0;		--可以进入的最前的精英关卡id

	self.aimBid						= 0;		--任务或者指引的关卡id
	self.playBid					= 0;		--上一次打的关卡

	self.fubenstate					= 0;		--0为普通关卡状态， 1为精英关卡状态
	taskEnter						= false;	--任务引导进入
	curPageId						= 1;		--当前页
	rewardList						= {}; 		--关卡奖励状态
    
	---------------------
	--获取相关控件引用
	--控件UI
	mainDesktop = desktop;
	barrierPanel = Panel(desktop:GetLogicChild('FBCommonPanel'));
	barrierPanel:IncRefCount();
	barrierPanel.ZOrder = PanelZOrder.FB;
	barrierPanel.Visibility = Visibility.Hidden;

	--返回按钮事件
	barrierPanel:GetLogicChild('btnReturn'):SubscribeScriptedEvent('Button::ClickEvent', 'PveBarrierPanel:onClickBack');
	barrierPanel:GetLogicChild('btnReturn').ZOrder = 10;
    --前一页后一页事件
	btnPre = barrierPanel:GetLogicChild('leftButton');
    btnPre:SubscribeScriptedEvent('Button::ClickEvent', 'PveBarrierPanel:onPrePage');            --上一章节
	btnPre.Visibility = Visibility.Hidden;
    btnNext = barrierPanel:GetLogicChild('rightButton');
    btnNext:SubscribeScriptedEvent('Button::ClickEvent', 'PveBarrierPanel:onNextPage');          --下一章节  
	btnNext.Visibility = Visibility.Hidden;

	--体力/钻石panel
	infoPanel = barrierPanel:GetLogicChild('MyInfo');
	--点击增加体力事件
	infoPanel:GetLogicChild('AddButton1'):SubscribeScriptedEvent('Button::ClickEvent', 'PveBarrierPanel:buyAp');
	--点击增加钻石事件
	infoPanel:GetLogicChild('AddButton2'):SubscribeScriptedEvent('Button::ClickEvent', 'PveBarrierPanel:buyYb');
	--体力数值显示条
	powerProgress = EffectProgressBar(infoPanel:GetLogicChild('progress'));
	labelPower	  = infoPanel:GetLogicChild('tili');
	--钻石label
	labelYB = infoPanel:GetLogicChild('gemValue');

	--切换副本
	changeFuBen = barrierPanel:GetLogicChild('JYButton');
    changeFuBen:SubscribeScriptedEvent('Button::ClickEvent', 'PveBarrierPanel:changeFuben');       --切换副本  

	--背景
    imgBg = barrierPanel:GetLogicChild('bg');
	titleLabel = barrierPanel:GetLogicChild('top'):GetLogicChild('leftname');
	chapterName = barrierPanel:GetLogicChild('top'):GetLogicChild('chapterInfo')

	--副本图标所在的层级
	iconPanel = barrierPanel:GetLogicChild('iconPanel');

	--显示当前星级的控件
	starPanel = barrierPanel:GetLogicChild('starPanel');
    starCount = starPanel:GetLogicChild('rasult');
    starCount:GetLogicChild('total').Text = '40';
    curStarLabel = starCount:GetLogicChild('num');
	starCount.setStarNum = function(num)
		for i=1, 4 do
			starPanel:GetLogicChild('result2'):GetLogicChild(tostring(i)).Visibility = (num >= i*10) and Visibility.Visible or Visibility.Hidden;
		end
	end

	--重置精英副本界面
	resetPanel = barrierPanel:GetLogicChild('elite_reset_panel');
	resetPanel.Visibility = Visibility.Hidden;
	resetNumLabel = resetPanel:GetLogicChild('reset_num');
	resetPanel:GetLogicChild('ok'):SubscribeScriptedEvent('Button::ClickEvent', 'PveBarrierPanel:onOkReset');
	resetPanel:GetLogicChild('cancel'):SubscribeScriptedEvent('Button::ClickEvent', 'PveBarrierPanel:onCanelReset');

	shandow = barrierPanel:GetLogicChild('shandow');
	shandow.Visibility = Visibility.Hidden;

	--领取奖励点击事件
    barrierPanel:GetLogicChild('rewardButton'):SubscribeScriptedEvent('Button::ClickEvent', 'PveBarrierPanel:onShowRewardPanel');
    circleTip =  barrierPanel:GetLogicChild('rewardButton'):GetLogicChild('circle')
    circleTip.Visibility = Visibility.Hidden
	--领取奖励界面
    rewardPanel = barrierPanel:GetLogicChild('rewardPanel');
	rewardPanel.ZOrder = barrierPanel.ZOrder + 100;
	rewardPanel:GetLogicChild('closeBtn'):SubscribeScriptedEvent('Button::ClickEvent', 'PveBarrierPanel:onHiddenRewardPanel');
	--领取奖励界面控件绑定
	for i=1, 4 do
		rewardPanel[i] = {};
		--获取item引用
		rewardPanel[i].items = {};
		for j=1, 3 do
			rewardPanel[i].items[j] = customUserControl.new(rewardPanel:GetLogicChild('itemPanel'..i):GetLogicChild('item'..j), 'itemTemplate');
		end

		--设置按钮行为
		rewardPanel[i].button = {};
		local clearButton = function()
			rewardPanel:GetLogicChild('buttonPanel'..i):GetLogicChild('complete').Visibility = Visibility.Hidden;
			rewardPanel:GetLogicChild('buttonPanel'..i):GetLogicChild('getbutton').Visibility = Visibility.Hidden;
			rewardPanel:GetLogicChild('buttonPanel'..i):GetLogicChild('bobutton').Visibility = Visibility.Hidden;
		end
		rewardPanel[i].button.haveGotten = function()
			clearButton();
			rewardPanel:GetLogicChild('buttonPanel'..i):GetLogicChild('complete').Visibility = Visibility.Visible;
		end
		rewardPanel[i].button.toGet = function()
			clearButton();
			rewardPanel:GetLogicChild('buttonPanel'..i):GetLogicChild('getbutton').Visibility = Visibility.Visible;
		end
		rewardPanel[i].button.noReach = function()
			clearButton();
			rewardPanel:GetLogicChild('buttonPanel'..i):GetLogicChild('bobutton').Visibility = Visibility.Visible;
		end
		--设置按钮Tag和点击事件
		rewardPanel:GetLogicChild('buttonPanel'..i):GetLogicChild('getbutton'):SubscribeScriptedEvent('Button::ClickEvent', 'PveBarrierPanel:getReward');
		rewardPanel:GetLogicChild('buttonPanel'..i):GetLogicChild('getbutton').Tag = i;
		clearButton();

	end
	
	--初始化关卡按钮
	--普通关卡  
	buttonPanelList = {};
	for index=1, 10 do
		local fbCommonItem = customUserControl.new(iconPanel, 'FBCommonTemplate');
		buttonPanelList[index] = fbCommonItem;
	end
	--精英关卡
	elitebuttonPanelList = {};
	for index=1, 10 do
		local fbCommonItem = customUserControl.new(iconPanel, 'FBCommonTemplate');
		elitebuttonPanelList[index] = fbCommonItem;
	end

	--绑定
	self:bind();
	uiSystem:UpdateDataBind();


	--初始化副本表
	--普通副本
	bCList = {};
	local bCCount = 1001;
	local BidCData = findCityId(bCCount);
	local i = 1;
	while (BidCData) do
		if bCList[BidCData] then
			bCList[BidCData][i] = bCCount;
			i = i + 1;
		else
			bCList[BidCData] = {};
			i = 1;
			bCList[BidCData][i] = bCCount;
			i = i + 1;
		end
		bCCount = bCCount + 1;
		BidCData = findCityId(bCCount);
	end

	--精英副本
	bEList = {};
	local bECount = 5001;
	local BidEData = findCityId(bECount);
	local i = 1;
	while (BidEData) do
		if bEList[BidEData] then
			bEList[BidEData][i] = bECount;
			i = i + 1;
		else
			bEList[BidEData] = {};
			i = 1;
			bEList[BidEData][i] = bECount;
			i = i + 1;
		end
		bECount = bECount + 1;
		BidEData = findCityId(bECount);
	end
end

--销毁
function PveBarrierPanel:Destroy()	
	self:unBind();
	barrierPanel:DecRefCount();
	barrierPanel = nil;	
end

--打开时的新手引导
function PveBarrierPanel:onUserGuid()
	--新手引导关卡选择
	if Task:getMainTaskId() == 100003 and buttonPanelList[1]:getControl() and buttonPanelList[1].getVisibility() and isshowGuide1 and ActorManager.user_data.userguide.isnew == 0 then
		UserGuidePanel:SetInGuiding(true);
		UserGuidePanel:ShowGuideShade(buttonPanelList[1]:getControl(), GuideEffectType.hand, GuideTipPos.bottom, LANG_pveBarrierPanel_1, 0.3, 0);
		UserGuidePanel:SetInGuiding(false);
		isshowGuide1 = false;
	end
	if Task:getMainTaskId() == 100004 and buttonPanelList[2]:getControl() and buttonPanelList[2].getVisibility() and isshowGuide2 and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth2 then
		UserGuidePanel:SetInGuiding(true);
		UserGuidePanel:ShowGuideShade(buttonPanelList[2]:getControl(), GuideEffectType.hand, GuideTipPos.bottom, LANG_pveBarrierPanel_1, 0.3, 0);
		UserGuidePanel:SetInGuiding(false);
		isshowGuide2 = false;
	end

	if Task:getMainTaskId() == 100005 and buttonPanelList[3]:getControl() and isshowGuide3 and buttonPanelList[3].getVisibility() and ActorManager.user_data.userguide.isnew == GuideIndexExt.befigth3 then
		UserGuidePanel:SetInGuiding(true);
		UserGuidePanel:ShowGuideShade(buttonPanelList[3]:getControl(), GuideEffectType.hand, GuideTipPos.bottom, LANG_pveBarrierPanel_1, 0.3, 0);
		UserGuidePanel:SetInGuiding(false);
		isshowGuide3 = false;
	end

	if Task:getMainTaskId() == 100007 and buttonPanelList[4]:getControl() and buttonPanelList[4].getVisibility() and isshowGuide4  and ActorManager.user_data.userguide.isnew == GuideIndexExt.belove2 then
		UserGuidePanel:SetInGuiding(true);
		UserGuidePanel:ShowGuideShade(buttonPanelList[4]:getControl(), GuideEffectType.hand, GuideTipPos.bottom, LANG_pveBarrierPanel_1, 0.3, 0);
		UserGuidePanel:SetInGuiding(false);
		isshowGuide4 = false;
	end

	--任务进入的才显示
	--[[
	if self.taskEnter then
		--两次战斗关卡提示
		local taskID = Task:getMainTaskId();
		if taskID <= SystemTaskId.fightSecond then
			UserGuidePanel:SetInGuiding(true);
			UserGuidePanel:ShowGuideShade(self.buttonPanelList[shineID - lastIdOfPreChapter].button, GuideEffectType.hand, GuideTipPos.bottom, LANG_pveBarrierPanel_1, nil, 0.5);
			UserGuidePanel:SetInGuiding(false);
		end
		--关卡星级领取
		if taskID == SystemTaskId.getRoundReward and (rewardList[1] == PveStarRewardPanel.RewardNoGet) then
			if self:getCurrentPageStar() >= 10 then
				UserGuidePanel:SetInGuiding(true);
				UserGuidePanel:ShowGuideShade(btnCopperOpen, GuideEffectType.hand, GuideTipPos.bottom, LANG_pveBarrierPanel_2, nil, 0.5);
				UserGuidePanel:SetInGuiding(false);
			end
		end
	end
	--]]
end

--显示
function PveBarrierPanel:Show()
	if HomePanel:returnVisble() then
		HomePanel:setRolePanelZOrder(false)
	end
	--向服务器发送统计数据
	local taskID = Task:getMainTaskId();
	if (Task.mainTask ~= nil) and (taskID <= MenuOpenLevel.statistics) then
		NetworkMsg_GodsSenki:SendStatisticsData(taskID, 3);
	end		
	--显示关卡
	barrierPanel.Visibility = Visibility.Visible;

	--更新翻页按钮
	self:refreshPage();

	--更新背景和标题
	self:refreshBgTitle();

	--更新当前关卡总获得星级
	self:refreshStarNumPanel(self:getCurrentPageStarNum());

	--根据关卡id初始化关卡按钮
	self:refreshIcon();
	
	--更新当前关卡的选中动画
	self:refreshSelect();	
	
	--根据当前状态决定显示普通还是精英
	self:refreshBarrierType();

	--更新当前关卡奖励情况
	self:refreshRewardPanel();

	--星级面板
	barrierPanel:GetLogicChild('rewardButton').Visibility = self.fubenstate == 0 and Visibility.Visible or Visibility.Hidden;
	starPanel.Visibility = self.fubenstate == 0 and Visibility.Visible or Visibility.Hidden;	
	
	GodsSenki:LeaveMainScene();                   --离开主城	
	-- 适配
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		iconPanel:SetScale(factor,factor);
		barrierPanel:GetLogicChild('top'):SetScale(factor,factor);
		barrierPanel:GetLogicChild('top').Translate = Vector2(317*(factor-1)/2,55*(factor-1)/2);
		infoPanel:SetScale(factor,factor);
		infoPanel.Translate = Vector2(340*(1-factor)/2,48*(factor-1)/2);
	end
	StoryBoard:ShowUIStoryBoard(barrierPanel, StoryBoardType.ShowUI1, nil, 'PveBarrierPanel:onUserGuid'); --增加UI弹出时候的效果
end

--隐藏
function PveBarrierPanel:Hide()
	--隐藏关卡地图
	barrierPanel.Visibility = Visibility.Hidden;
	--返回主城
	GodsSenki:BackToMainScene(SceneType.PveBarrierUI);
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(barrierPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--绑定数据
function PveBarrierPanel:bind()
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'powerProgress', powerProgress, 'CurValue');
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'power', labelPower, 'Text');
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'rmb', labelYB, 'Text');
end

--解除绑定
function PveBarrierPanel:unBind()
	uiSystem:UnBind(ActorManager.user_data, 'powerProgress', powerProgress, 'CurValue');
	uiSystem:UnBind(ActorManager.user_data, 'power', labelYB, 'Text');
	uiSystem:UnBind(ActorManager.user_data, 'power', labelPower, 'Text');
end

--=================================================================================================
--功能函数
--获得当前可打的最前面的关卡id
function PveBarrierPanel:getlatestIdOfAllChapter()
	if 1001 > ActorManager.user_data.round.openRoundId then
		return 1001;
	end
	return ActorManager.user_data.round.openRoundId;
end

--获得当前可打的最前面的精英关卡id
function PveBarrierPanel:getlatestEliteIdofAllChapter()
	if 0 == ActorManager.user_data.round.elite_roundid then
		return 5001;
	end
	if findCityId(ActorManager.user_data.round.elite_roundid + 1) > findCityId(ActorManager.user_data.round.openRoundId) then
		return ActorManager.user_data.round.elite_roundid;
	end
	return ActorManager.user_data.round.elite_roundid + 1;
end

--战斗结束时 刷新某一关的关卡星级
function PveBarrierPanel:SetBarrierStars(barrierID, stars)
	local str = ActorManager.user_data.round.stars;
	local index = barrierID - RoundIDSection.NormalBegin;
	ActorManager.user_data.round.stars = string.sub(str, 1, index - 1) .. stars .. string.sub(str, index + 1, -1);
end

--刷新某一关卡的星级
function PveBarrierPanel:RefreshBarrierStar()
	if self.playBid > 5000 then return; end
	--找到当前章节第一关
	local startBid = bCList[self.cityId][1];
	-- local index = (self.playBid - startBid)+1;
	-- local fb_id = self.playBid - 1001 +1;
	local index = (selectRoundID - startBid)+1;
	local fb_id = selectRoundID - 1001 +1;
	if index < 1 then return; end
	local str = ActorManager.user_data.round.stars;
	local res = string.sub(str, fb_id, fb_id);
	local stars=getStarFromRes(res);
	self:showStars(buttonPanelList[index], stars);
	afterFightStar = stars
end

--根据副本显示类型显示对应icon
function PveBarrierPanel:refreshBarrierType()
	if self.fubenstate == 0 then
		changeFuBen.Text = LANG_pveBarrierPanel_4;
		for i=1, 10 do
			if buttonPanelList[i].getVisibility() then
				buttonPanelList[i]:Show();
			else
				buttonPanelList[i]:Hide();
			end
		end
		for i=1, 10 do
			elitebuttonPanelList[i]:Hide();
		end
	else
		changeFuBen.Text = LANG_pveBarrierPanel_3;
		for i=1, 10 do
			buttonPanelList[i]:Hide();
		end
		for i=1, 10 do
			if elitebuttonPanelList[i].getVisibility() then
				elitebuttonPanelList[i]:Show();
			else
				elitebuttonPanelList[i]:Hide();
			end
		end
	end
end

--普通/精英副本按钮点击事件
function PveBarrierPanel:changeFuben()
	if self.fubenstate == 1 then
		self.fubenstate = 0;
		changeFuBen.Text = LANG_pveBarrierPanel_4;

		barrierPanel:GetLogicChild('rewardButton').Visibility = Visibility.Visible;
		starPanel.Visibility = Visibility.Visible;
	else
		--检测最大精英关，切换大关关卡
		if findCityId(self.latestElite) < self.cityId then
			self.cityId = findCityId(self.latestElite);
			self.curPageId = self.cityId - 1000;
			
			--更新当前大关的普通和精英关icon
			self:refreshIcon();
		end

		barrierPanel:GetLogicChild('rewardButton').Visibility = Visibility.Hidden;
		starPanel.Visibility = Visibility.Hidden;

		self.fubenstate = 1;
	    changeFuBen.Text = LANG_pveBarrierPanel_3;
	end

	self:refreshBgTitle();
	self:refreshPage();
	self:refreshBarrierType();
	self:refreshSelect();

	if UserGuidePanel:IsInGuidence(UserGuideIndex.task16, 1) then
		UserGuidePanel:ShowGuideShade(elitebuttonPanelList[1]:getControl(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	end
end

--前一页
function PveBarrierPanel:onPrePage()
	if self.curPageId <= 1 then
		return;
	end
	self.curPageId = self.curPageId - 1;
	self.cityId = self.cityId - 1;
	self:refreshPage();
	self:refreshIcon();
	self:refreshBarrierType();
	self:refreshBgTitle();
	self:refreshStarNumPanel(self:getCurrentPageStarNum());
	self:refreshRewardPanel();
end

--后一页
function PveBarrierPanel:onNextPage()
	if self.fubenstate == 0 then
		if self.curPageId >= (findCityId(self.latestCommon) - 1000) then
			return;
		end
	else
		if self.curPageId >= (findCityId(self.latestElite) - 1000) then
			return;
		end
	end
	self.curPageId = self.curPageId + 1;
	self.cityId = self.cityId + 1;
	self:refreshPage();
	self:refreshIcon();
	self:refreshBarrierType();
	self:refreshBgTitle();
	self:refreshStarNumPanel(self:getCurrentPageStarNum());
	self:refreshRewardPanel();
end

--显示关卡的成就星级
function PveBarrierPanel:showStars(buttonPanel, count)
	buttonPanel.setStar(count);
end


function PveBarrierPanel:getRewardCallBack(msg)

end

--========================================================================
--关卡返回按钮
function PveBarrierPanel:onBackToMainCity()
	barrierPanel.Visibility = Visibility.Visible;
	MainUI:Pop();
	FightOverUIManager:setFightOverPopupUI(FightOverPopup.none);
end

--点击关卡返回
function PveBarrierPanel:onClickBack()
	if CardRankupPanel:isVisible() then
		CardRankupPanel:refreshHaveCount()
	end
	if HomePanel:returnVisble() then
		HomePanel:setRolePanelZOrder(true)
	end
	--刷新装备界面材料
	if EquipStrengthPanel:IsVisible()then
		EquipStrengthPanel:UpdateAdvInfo();
	end
	self:Hide();
end

--关卡pve战斗点击事件
function PveBarrierPanel:onEnterPveBattle(Args)	
    local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;
	if (tag > 5000) then
		local tmp = ActorManager.user_data.round.elite_round_times or '';
		local round_times;
		if string.len(tmp) < tag-5000 then
			round_times = 0;
		else
			round_times = tonumber(string.sub(tmp, tag-5000, tag-5000));
		end
		if round_times >= 3 then
			resetPanel.Tag = tag;
			self:onShowResetPanel();
			return;
		end
	end
	FbIntroductionPanel:onEnterFBInfo(tag);

	--   获得当前选中关卡的星星数量

	local startBid = bCList[self.cityId][1]
	local index = (tag - startBid) + 1
	local fb_id = tag - 1001 + 1
	self.playBid = tag;
	if index < 1 then return end
	local str = ActorManager.user_data.round.stars
	local res = string.sub(str, fb_id, fb_id)
	beforeFightStarNum =  getStarFromRes(res)
	selectRoundID = tag
	self:refreshSelect();
end

--普通战斗结束的回调函数
function PveBarrierPanel:OnNormalFightCallBack(resultData)
	local msg = {};
	msg.resid = resultData.id;
	msg.killed = FightManager:GetKillMonsterList();
	if resultData.result == Victory.left then
		msg.stars = resultData.stars or '0';
		msg.win = true;	
	else
		msg.stars = '0';
		msg.win = false;
	end
	msg.salt = 	_G['salt#normal'];
	Network:Send(NetworkCmdType.req_round_exit, msg);			--通知服务器普通战斗结束
end

--普通战斗结束收到服务器消息的回调函数
function PveBarrierPanel:OnNormalFightAfterSerMsgCallBack(iswin,  newStars, roundid, new_round_times)
	if not iswin then
		return;
	end	

	if roundid < 5000 and roundid > 600 then
		self:SetBarrierStars(roundid, newStars);	        --更改该关卡的星级
		self:RefreshBarrierStar(roundid);

		--  更新星星数量
		getStarsNumber = getStarsNumber + afterFightStar - beforeFightStarNum
		self:refreshStarNumPanel(getStarsNumber)
		self:refreshRewardPanel()

		if roundid > ActorManager.user_data.round.roundid then 	--更新关卡id
			ActorManager.user_data.round.roundid = roundid;
			self.latestCommon = self:getlatestIdOfAllChapter();
			self:refreshIcon();
			self:refreshBarrierType();
		end
	elseif roundid > 5000 then
		ActorManager.user_data.round.elite_round_times = new_round_times;
		if roundid > ActorManager.user_data.round.elite_roundid then
			ActorManager.user_data.round.elite_roundid = roundid;
			self.isFirstTimePassEliteRound = true;
			self.latestElite = self:getlatestEliteIdofAllChapter();
		end
		self:refreshIcon();
		self:refreshBarrierType();
		self:refreshPage();
	end
    --if roundid == 1010 then
		MenuPanel:isShowFeedbackPanel();
		FbIntroductionPanel:refreshFpExpInfo()
		--print('roundid->'..tostring(ActorManager.user_data.round.roundid));
	--end
end

--================================================
--刷新按钮
function PveBarrierPanel:refreshIcon()
	if not bCList[self.cityId] then
		return
	end
	--刷新普通副本icon
	for id, bid in pairs(bCList[self.cityId]) do
		if bid <= self.latestCommon then
			buttonPanelList[id].initWithBarrier(bid);
			buttonPanelList[id].setVisibility(true);
			local index = bid - 1000;
			local res = string.sub(ActorManager.user_data.round.stars, index, index);
			buttonPanelList[id].setStar(getStarFromRes(res));
			buttonPanelList[id]:Show();
		else
			buttonPanelList[id].setVisibility(false);
			buttonPanelList[id]:Hide();
		end
	end

	--刷新精英副本icon
	if bEList[self.cityId] then
		for id, bid in pairs(bEList[self.cityId]) do
			if bid <= self.latestElite then
				elitebuttonPanelList[id].initWithBarrier(bid);
				elitebuttonPanelList[id].setVisibility(true);
				elitebuttonPanelList[id]:Show();
			else
				elitebuttonPanelList[id].setVisibility(false);
				elitebuttonPanelList[id]:Hide();
			end
		end
	end
end

function PveBarrierPanel:refreshSelect()
	if self.fubenstate == 0 then
		for i=1, 10 do
			buttonPanelList[i].updateSelect(self.aimBid);
		end
	else
		for i=1, 10 do
			elitebuttonPanelList[i].updateSelect(self.aimBid);
		end
	end
end

--================================================
--刷新背景和标题
function PveBarrierPanel:refreshBgTitle()
	local path;
	if self.fubenstate == 0 then
		path = resTableManager:GetValue(ResTable.chapter, tostring(self.cityId), 'source1'); 
	else
		path = resTableManager:GetValue(ResTable.chapter, tostring(self.cityId), 'source2');
	end
	imgBg.Background = CreateTextureBrush('background/' .. path .. '.jpg', 'background');
	titleLabel.Text = resTableManager:GetValue(ResTable.chapter, tostring(self.cityId), 'name');
	local chapterID = self.cityId - 1000
	chapterName.Text = '第' .. ChapterName[chapterID] .. '章'
end

--================================================
--刷新前一页后一页的显示
function PveBarrierPanel:refreshPage()
	-- 后一页
	if self.fubenstate == 0 then
		if self.curPageId < (findCityId(self.latestCommon) - 1000) then
			btnNext.Visibility = Visibility.Visible;
		else
			btnNext.Visibility = Visibility.Hidden;
		end
	else
		if self.curPageId < (findCityId(self.latestElite) - 1000) then
			btnNext.Visibility = Visibility.Visible;
		else
			btnNext.Visibility = Visibility.Hidden;
		end
	end

	-- 前一页
	if self.curPageId > 1 then
		btnPre.Visibility = Visibility.Visible;
	else
		btnPre.Visibility = Visibility.Hidden;
	end
end
--================================================
--右上角的体力/钻石信息
--因为数值绑定，所以需要的只是一些点击事件
function PveBarrierPanel:buyAp()
	BuyCountPanel:ApplyData(VipBuyType.vop_buy_power);
end

function PveBarrierPanel:buyYb()
    if(RechargePanel) then
	  RechargePanel:onShowRechargePanel();
    end
end

--刷新体力颜色 暂时用不到
--[[
function PveBarrierPanel:RefreshPowerColor()
	if labelPower == nil then
		return;
	end	
	if ActorManager.user_data.power > Configuration.MaxPower then
		labelPower.TextColor = QuadColor( Color(0,246,255, 255) );
	else
		labelPower.TextColor = Configuration.WhiteColor;
	end
end
--]]

--================================================
--有关星级领取奖励/奖励按钮事件/显示星级等等的逻辑

--UI
--更新页面上的星星数量
function PveBarrierPanel:refreshStarNumPanel(num)
	--设置页面上的星星数量
	starCount.setStarNum(num);
	curStarLabel.Text = tostring(num);
end

--显示星级奖励页面
function PveBarrierPanel:onShowRewardPanel()
	rewardPanel.Visibility = Visibility.Visible;
end

--隐藏星级奖励页面
function PveBarrierPanel:onHiddenRewardPanel()
	rewardPanel.Visibility = Visibility.Hidden;
end

--刷新关卡星级奖励
function PveBarrierPanel:refreshIconStar(starNum)
	local i = FbIntroductionPanel.curBarrierId - bCList[findCityId(FbIntroductionPanel.curBarrierId)][1] + 1;
	buttonPanelList[i].setStar(starNum);
end

--刷新领取奖励内容
function PveBarrierPanel:refreshRewardPanel()    --直接点击领取 ret 回调函数
	--判断是否已经从服务器获取到信息
	if not rewardList[self.curPageId] then
		self:refreshCurPageStarreward();
		return;
	end

	 rewardCount = 0
	--获取当前关卡总星数
	local starNum = self:getCurrentPageStarNum();  -- getStarsNumber --
	--根据星数和领取状态决定按钮状态
	for i=1, 4 do
		if tostring(rewardList[self.curPageId][i]) == '1' then
			--已领取
			rewardPanel[i].button.haveGotten();
		elseif starNum < 10*i then
			--未达到
			rewardPanel[i].button.noReach();
		else
			--普通状态
			rewardPanel[i].button.toGet();

			rewardCount = rewardCount + 1
		end
	end
	if rewardCount > 0 then  --  说明有未领取的奖励
		circleTip.Visibility = Visibility.Visible
	else
		circleTip.Visibility = Visibility.Hidden
	end

	--刷新物品
	for row=1, 4 do
		local itemList = resTableManager:GetValue(ResTable.starreward, tostring(self.curPageId), 'count' .. row);
		for index=1, 3 do
			local item = rewardPanel[row].items[index];
			local itemCell = rewardPanel[row].items[index];
			if itemList[index] then
				local itemID = itemList[index][1];
				local itemNum = itemList[index][2];
				item.initWithInfo(itemID, itemNum, 70, true);
				item:Show();
			else
				item:Hide();
			end
		end
	end
end

--逻辑
--获取当前关卡总星数
function PveBarrierPanel:getCurrentPageStarNum()
	if self.curPageId < 1 then
		return 0;
	end
	
	local starNum = 0;
	local str = ActorManager.user_data.stars;
	for i=bCList[self.curPageId+1000][1], bCList[self.curPageId+1000][#bCList[self.curPageId+1000]] do
		starNum = starNum + FightAchievementClass:getStarNum(i);		
	end
	getStarsNumber = starNum
	return starNum;
end

--请求刷新当前大关的奖励领取情况
function PveBarrierPanel:refreshCurPageStarreward()
	local msg = {};
	msg.id = self.curPageId;
	Network:Send(NetworkCmdType.req_starreward_info, msg);
end

--请求刷新当前大关奖励领取情况回调
function PveBarrierPanel:starRewardInfoCallback(msg)
	rewardList[self.curPageId] = {};
	rewardList[self.curPageId] = msg.given;

	self:refreshRewardPanel();
end

--点击领取奖励
function PveBarrierPanel:getReward(Arg)
	local arg = UIControlEventArgs(Arg);	
	local tag = arg.m_pControl.Tag;
	
	self.rewerdTag = tag;

	if(self:getCurrentPageStarNum() >= tag*10) then
		local msg = {};
		msg.id = self.curPageId;
		msg.starnum = tag * 10;
		Network:Send(NetworkCmdType.req_starreward, msg);
		
	else
		Toast:MakeToast(Toast.TimeLength_Long, '您的星级没有达到要求');
	end
end

--领取奖励回调
function PveBarrierPanel:getRewardCallback(msg)
	if msg.code == 0 then
		rewardPanel[self.rewerdTag].button.haveGotten();
		--  未获取奖励数量减一
		rewardCount = rewardCount - 1
		if rewardCount > 0 then  --  说明有未领取的奖励
			circleTip.Visibility = Visibility.Visible
		else
			circleTip.Visibility = Visibility.Hidden
		end
		--  点击领取奖励后，领取状态表要更新
		rewardList[self.curPageId][self.rewerdTag] = 1
		for _, item in pairs(rewardPanel[self.rewerdTag].items) do
			--if item.Visibility == Visibility.Visible then
			if item and tonumber(item.getResid()) ~= 0 and tonumber(item.getNum()) ~= 0 then
				ToastMove:AddGoodsGetTip(tonumber(item.getResid()), tonumber(item.getNum()));
			end
			--end
		end
	else
		print("fail! error code is:" .. msg.code);
	end
end

--============================================================
--各类进入方式
--正常进入
function PveBarrierPanel:onEnterPveBarrier()
	--更新打到的最新的关卡id 最新精英关卡id
	self.latestCommon = self:getlatestIdOfAllChapter();
	self.latestElite = self:getlatestEliteIdofAllChapter();
	
	if self.fubenstate == 0 then
		self.cityId = findCityId(self.latestCommon);
	else
		self.cityId = findCityId(self.latestElite);
	end
	self.curPageId = self.cityId - 1000;

	--非任务引导进入
	self.taskEnter = false;	
	self:Show();

	if UserGuidePanel:IsInGuidence(UserGuideIndex.task16, 1) then
		UserGuidePanel:ShowGuideShade(changeFuBen,GuideEffectType.hand,GuideTipPos.right,'', 0.6);
	end
end

--从任务进入指定关卡
function PveBarrierPanel:OpenToPage(bid, isShowTanhao)
	--更新打到的最新的关卡id 最新精英关卡id
	self.latestCommon = self:getlatestIdOfAllChapter();
	self.latestElite = self:getlatestEliteIdofAllChapter();

	self.cityId = findCityId(bid);
	self.curPageId = self.cityId - 1000;
	self.aimBid = bid;

	--判断进来的关卡是普通关，精英关还是无效关
	if bid <= self.latestCommon and bid >= 1001 then
		self.fubenstate = 0;
	elseif bid <= self.latestElite and bid >= 5001 then
		self.fubenstate = 1;
	else
		return false;
	end
	
	--任务引导进入
	self.taskEnter = isShowTanhao;

	if isShowTanhao then
		shineID = bid;
	else
		shineID = 0;
	end	
	--显示
	self:Show();
	--MainUI:Push(self);
end

function PveBarrierPanel:IsShow()
 return barrierPanel.Visibility == Visibility.Visible;
end

function PveBarrierPanel:onShowResetPanel()
	resetPanel.Visibility = Visibility.Visible;
	shandow.Visibility = Visibility.Visible;
	local tag = resetPanel.Tag;

	--显示已重置次数
	local max_num = resTableManager:GetValue(ResTable.vip, tostring(ActorManager.user_data.viplevel), 'reset_elite');
	local tmp = ActorManager.user_data.round.elite_reset_times or '';
	local cur_num;
	if string.len(tmp) < tag-5000 then
		cur_num = "0";
	else
		cur_num = string.sub(tmp,tag-5000,tag-5000);
	end
	if numTab[cur_num] < tonumber(max_num) then
		resetPanel:GetLogicChild('ok').Enable = true;
	else
		resetPanel:GetLogicChild('ok').Enable = false;
	end

	resetNumLabel.Text = tostring(numTab[cur_num]) .. ' / ' .. max_num;
end

function PveBarrierPanel:onOkReset()
	local msg = {};
	msg.resid = resetPanel.Tag;
	Network:Send(NetworkCmdType.req_elite_reset, msg);

	resetPanel.Visibility = Visibility.Hidden;
	shandow.Visibility = Visibility.Hidden;
end

function PveBarrierPanel:onCanelReset()
	resetPanel.Visibility = Visibility.Hidden;
	shandow.Visibility = Visibility.Hidden;
end	
