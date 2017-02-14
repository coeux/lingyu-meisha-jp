--rankPanel.lua
--==============================================================
--排行榜界面

RankPanel = 
{
	maxRankNum = 6;
}

local mainDesktop;
local rankMainPanel;
local panel;
local levelBtn;
local isRankPanelShow;

--缓存排行榜数据
local rankFightAbilityData;
local rankArenaData;
local rankLevelData;
local rankUnionData;
local rankCardData;
local rankCardEventData;
local rankData;

local requestCoolDownTime;

--刷新时刻更新过排行榜数据标志位
local IsArenaRank;
local IsFightPointRank;
local IsLevelRank;
local IsUnionRank;
local IsCardRank;

local tabControl;

--战斗力排行榜
local fightPage;
local fightView;
local fightMyinfo;

--等级
local levelPage;
local levelView;
local levelMyInfo;
local leveltip;

--卡牌
local cardPage;
local cardView;
local cardMyinfo;
local cardtip;

--公会
local unionPage;
local unionView;

--竞技场
local arenaPage;
local arenaView;
local arenaMyinfo;
local arenatip;

--卡牌活动
local cardEventPage
local cardEventView
local cardEventTimeStamp

local popMenuPanel
local popMenuTagExt
local RankList

local leftPanel;
local leftBg;	
local leftRanking;
local leftName;	
local leftlevel;	
local leftFp;		
local leftTitle;	
local leftroleImg;
local ListPanel;
local rightPanel;
local itemList = {};
local brushImg;
local noLabel;
local tipLabel;

local itemImgList = 
{
	{'rank/ranking_item_fp_0.ccz','rank/ranking_item_fp_1.ccz'},
	{'rank/ranking_item_lv_0.ccz','rank/ranking_item_lv_1.ccz'},
	{'rank/ranking_item_card_0.ccz','rank/ranking_item_card_1.ccz'},
	{'rank/ranking_item_union_0.ccz','rank/ranking_item_union_1.ccz'},
	{'rank/ranking_item_arena_0.ccz','rank/ranking_item_arena_1.ccz'},
	{'rank/ranking_item_cardevent_0.ccz','rank/ranking_item_cardevent_1.ccz'},
};
function RankPanel:InitPanel(desktop)
	--UI初始化
	mainDesktop = desktop;
	rankMainPanel 	= mainDesktop:GetLogicChild('RankingPanel')
	panel = rankMainPanel:GetLogicChild('panel');
	rankMainPanel:IncRefCount();
	returnBtn 		= rankMainPanel:GetLogicChild('close');
	returnBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RankPanel:onClose'); 

	popMenuPanel = panel:GetLogicChild('popMenuPanel')
	popMenuPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'RankPanel:onPopMenuPanelLoseFocus');
	popMenuPanel.Visibility = Visibility.Hidden
	--[[
	tabControl = panel:GetLogicChild("tabControl");	
	--全部
	fightPage 	= tabControl:GetLogicChild('fight');
	fightMyinfo	= fightPage:GetLogicChild('MyInfo');
	fighttip	= fightPage:GetLogicChild('tip2');

	levelPage 	= tabControl:GetLogicChild('level');
	levelMyinfo	= levelPage:GetLogicChild('MyInfo');
	leveltip	= levelPage:GetLogicChild('tip2');

	cardPage 	= tabControl:GetLogicChild('card');
	cardMyinfo	= cardPage:GetLogicChild('MyInfo');
	cardtip	= cardPage:GetLogicChild('tip2');

	unionPage 	= tabControl:GetLogicChild('union');
	uniontip 	= unionPage:GetLogicChild('tip2');

	cardEventPage = tabControl:GetLogicChild('cardEvent');
	cardEventMyinfo = cardEventPage:GetLogicChild('MyInfo')
	cardEventView = cardEventPage:GetLogicChild('Infomation');
	cardEventTip2 = cardEventPage:GetLogicChild('tip2');

	arenaPage 	= tabControl:GetLogicChild('arena');
	arenaMyinfo	= arenaPage:GetLogicChild('MyInfo');
	arenatip	= arenaPage:GetLogicChild('tip2');
	]]
	self:initLeftPanel()
	self:initRightPanel();
	leftroleImg	= panel:GetLogicChild('roleBrushImg');
	rankFightAbilityData = {};
	isRankPanelShow = false;
	rankData = {};
	IsArenaRank = 0;
	IsFightPointRank = 0;
	IsLevelRank = 0;
	IsUnionRank = 0;
	IsCardRank  = 0;
	cardEventTimeStamp = 0
	requestCoolDownTime = 108000; -- 21点距零点秒数
end
function RankPanel:initRightPanel()
	rightPanel = panel:GetLogicChild('rightPanel');
	local itemTackPanel = rightPanel:GetLogicChild('itemTackPanel');
	tipLabel = rightPanel:GetLogicChild('tip');
	tipLabel.Visibility = Visibility.Hidden;
	itemList = {};
	for i = 1 , self.maxRankNum do
		local item = itemTackPanel:GetLogicChild('item'..i);
		item.UnSelectedBrush = CreateTextureBrush(itemImgList[i][1],'rank');
		item.SelectedBrush = CreateTextureBrush(itemImgList[i][2],'rank');
		item.Tag = i;
		item:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'RankPanel:itemSelectedEvent');
		table.insert(itemList,item);
	end
	ListPanel = rightPanel:GetLogicChild('touchScroll'):GetLogicChild('stackPanel');
end
function RankPanel:initLeftPanel()
	leftPanel = panel:GetLogicChild('leftPanel');
	leftBg		= leftPanel:GetLogicChild('bg');
	leftRanking = leftPanel:GetLogicChild('ranking');
	leftName	= leftPanel:GetLogicChild('name');
	leftlevel	= leftPanel:GetLogicChild('level');
	leftFp		= leftPanel:GetLogicChild('fp');
	leftTitle	= leftPanel:GetLogicChild('title');
	noLabel		= leftPanel:GetLogicChild('noLabel');
end
function RankPanel:setLeftShow(flag)
	leftRanking.Visibility = flag and Visibility.Visible or Visibility.Hidden;
	leftName.Visibility = flag and Visibility.Visible or Visibility.Hidden;	
	leftlevel.Visibility = flag and Visibility.Visible or Visibility.Hidden;	
	leftFp.Visibility = flag and Visibility.Visible or Visibility.Hidden;		
	leftTitle.Visibility = flag and Visibility.Visible or Visibility.Hidden;
	noLabel.Visibility = flag and Visibility.Hidden or Visibility.Visible;	
end
function RankPanel:itemSelectedEvent(Args)
	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;
	popMenuPanel.Visibility = Visibility.Hidden
	SoundManager:onUIClick();
	rightPanel:GetLogicChild('touchScroll'):VScrollBegin();
	tipLabel.Visibility = Visibility.Hidden;
	if tag == RankType.Fight then
		RankPanel:SetFightAbilityPanel();
	elseif tag == RankType.Level then
		RankPanel:SetLevelPanel();
	elseif tag == RankType.Card then
		RankPanel:SetCardRankPanel();
	elseif tag == RankType.Union then
		RankPanel:SetUnionLevelRankPanel();
	elseif tag == RankType.Arena then
		RankPanel:SetArenaPanel();
	elseif tag == RankType.CardEvent then
		RankPanel:SetCardEventRankPanel();
	end
end
function RankPanel:Show()
	--设置模式对话框
	mainDesktop:DoModal(rankMainPanel);

	if appFramework.ScreenWidth <= appFramework.ScreenHeight*4/3 then
		panel:SetScale(0.85, 0.85);
	end
	isRankPanelShow = true;
	--增加UI弹出时候的效果
	--itemList[1].Selected = true;
	rightPanel.Background = CreateTextureBrush('rank/ranking_bg.ccz','rank');
	leftPanel.Background = CreateTextureBrush('rank/ranking_cur_bg.ccz','rank');
	leftBg.Background = CreateTextureBrush('rank/ranking_item_bg_0.ccz','rank');
	brushImg = nil;

	local resid =ActorManager:getKanbanRole();
	brushImg = 'navi/'..resTableManager:GetValue(ResTable.navi_main,tostring(resid%10000),'role_path')..'.ccz';
	leftroleImg.Background = CreateTextureBrush(brushImg,'rank');

	StoryBoard:ShowUIStoryBoard(rankMainPanel, StoryBoardType.ShowUI1);
	GodsSenki:LeaveMainScene();
end

function RankPanel:Hide()
	mainDesktop:UndoModal();

	isRankPanelShow = false;
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(rankMainPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
	DestroyBrushAndImage('rank/ranking_bg.ccz','rank');
	DestroyBrushAndImage('rank/ranking_cur_bg.ccz','rank');
	DestroyBrushAndImage('rank/ranking_item_bg_0.ccz','rank');
	if brushImg then
		DestroyBrushAndImage(brushImg,'rank');
	end
end


function RankPanel:Destroy()
	rankMainPanel:DecRefCount();
	rankMainPanel = nil;
end

--关闭界面
function RankPanel:onClose()
	MainUI:Pop();
	if self.enter and self.enter == 'event' then
		self.enter = '';
		CardEventPanel:changeRank();
	else
		GodsSenki:BackToMainScene(SceneType.HomeUI);
	end
end

function RankPanel:ShowRankPanel()
	--tabControl.ActiveTabPageIndex = 0;
	itemList[1].Selected = true;
	MainUI:Push(self);
end

--进入竞技场排行榜
function RankPanel:ShowArenaRank()
	--tabControl.ActiveTabPageIndex = 5;
	itemList[5].Selected = true;
	MainUI:Push(self);
end

--进入活动排行榜
function RankPanel:ShowEventRank()
	itemList[6].Selected = true;
	MainUI:Push(self);
	self.enter = 'event';
end

--tabcontrol页改变事件
function RankPanel:onTabControlPageChange(Args)
	popMenuPanel.Visibility = Visibility.Hidden
	SoundManager:onUIClick();
	local args = UITabControlPageChangeEventArgs(Args);
	if args.m_pNewPage == nil then
		return;
	end
	if args.m_pNewPage.Tag == RankType.Fight then
		RankPanel:SetFightAbilityPanel();
	elseif args.m_pNewPage.Tag == RankType.Level then
		RankPanel:SetLevelPanel();
	elseif args.m_pNewPage.Tag == RankType.Card then
		RankPanel:SetCardRankPanel();
	elseif args.m_pNewPage.Tag == RankType.Union then
		RankPanel:SetUnionLevelRankPanel();
	elseif args.m_pNewPage.Tag == RankType.Arena then
		RankPanel:SetArenaPanel();
	elseif args.m_pNewPage.Tag == RankType.CardEvent then
		RankPanel:SetCardEventRankPanel();
	end
end

function RankPanel:SetArenaPanel()
	if (ActorManager.user_data.reward.sec_2_tom <= requestCoolDownTime and IsArenaRank <= 1) or IsArenaRank == 0  then
		IsArenaRank = IsArenaRank + 1;
		RankPanel:SendGetArenaRankMsg();
	else	
		--local ListPanel = arenaPage:GetLogicChild('progress'):GetLogicChild('unionInformation')
		--ListPanel:RemoveAllChildren();
		ListPanel:RemoveAllChildren();	
		local dataNum = #rankArenaData;
		--显示自己的排名
		local myRank = 1000;	
		local myUid = ActorManager.user_data.uid;
		for index,data in ipairs(rankArenaData) do
			if data.uid == myUid then
				myRank = index;	
			end
		end			
		for i = 1, dataNum do
			if i <= dataNum then
				local rankinfo = customUserControl.new(ListPanel, 'RankingTemplate');
				local myself = false;
				if i==myRank then
					myself = true;
				end
				rankinfo.initRankinfo(rankArenaData[i], i, RankType.Arena, myself);
			end
		end	

		--如果上榜
		if myRank <= 100 then
			--[[
			local myrankLable = arenaMyinfo:GetLogicChild('MyRanking');
			local nameLable = arenaMyinfo:GetLogicChild('name');
			local levelLable = arenaMyinfo:GetLogicChild('level');
			local chenghaoLable = arenaMyinfo:GetLogicChild('chenghao');
			local zhandouliLable = arenaMyinfo:GetLogicChild('zhandouli');
			myrankLable.Text = tostring(myRank);
			nameLable.Text = tostring(rankArenaData[myRank].nickname);
			levelLable.Text = tostring(rankArenaData[myRank].lv);
			zhandouliLable.Text = tostring(rankArenaData[myRank].fp);
			chenghaoLable.Visibility = Visibility.Visible;
			]]
			leftRanking.Text = tostring(myRank);
			leftName.Text = tostring(rankArenaData[myRank].nickname);	
			leftlevel.Text = tostring('Lv:'..rankArenaData[myRank].lv);	
			leftFp.Text = tostring('戦闘力:'..rankArenaData[myRank].fp);		

			if myRank == 1 then
				--chenghaoLable.Text = LANG_rankPanel_18;
				leftTitle.Image = GetPicture('rank_arena1');
			elseif myRank <= 5 then
				--chenghaoLable.Text = LANG_rankPanel_19;
				leftTitle.Image = GetPicture('rank_arena2');
			else
				--chenghaoLable.Visibility = Visibility.Hidden; 
				leftTitle.Visibility = Visibility.Hidden;
			end
			self:setLeftShow(true);
		else
			--arenaMyinfo.Visibility = Visibility.Hidden; 
			--arenatip.Visibility = Visibility.Visible;
			noLabel.Text = LANG_rankPanel_22;
			self:setLeftShow(false);
		end			
	end

end

function RankPanel:SetFightAbilityPanel()
	if (ActorManager.user_data.reward.sec_2_tom <= requestCoolDownTime and IsFightPointRank <= 1) or IsFightPointRank == 0 then
		IsFightPointRank = IsFightPointRank + 1;
		self:SendGetFpRankMsg();
	else
		-- just use the old data
		--local ListPanel = fightPage:GetLogicChild('progress'):GetLogicChild('unionInformation')
		ListPanel:RemoveAllChildren();	
		local dataNum = #rankFightAbilityData;
		--显示自己的排名
		local myRank = 1000;	
		local myUid = ActorManager.user_data.uid;
		for index,data in ipairs(rankFightAbilityData) do
			if data.uid == myUid then
				myRank = index;	
			end
		end			
		for i = 1, dataNum do
			if i <= dataNum then
				local myself = false;
				if i == myRank then
					myself = true;
				end
				local rankinfo = customUserControl.new(ListPanel, 'RankingTemplate');
				rankinfo.initRankinfo(rankFightAbilityData[i], i, RankType.Fight, myself);
			end
		end
		--如果上榜
		if myRank <= 100 then
			--[[
			local myrankLable = fightMyinfo:GetLogicChild('MyRanking');
			local nameLable = fightMyinfo:GetLogicChild('name');
			local levelLable = fightMyinfo:GetLogicChild('level');
			local chenghaoLable = fightMyinfo:GetLogicChild('chenghao');
			local zhandouliLable = fightMyinfo:GetLogicChild('zhandouli');
			myrankLable.Text = tostring(myRank);
			nameLable.Text = tostring(rankFightAbilityData[myRank].nickname);
			levelLable.Text = tostring(rankFightAbilityData[myRank].lv);
			zhandouliLable.Text = tostring(rankFightAbilityData[myRank].fp);
			fighttip.Visibility = Visibility.Hidden;
			chenghaoLable.Visibility = Visibility.Visible; 
			if myRank == 1 then
				chenghaoLable.Text = LANG_rankPanel_11;
			elseif myRank <= 5 then
				chenghaoLable.Text = LANG_rankPanel_12;
			else
				chenghaoLable.Visibility = Visibility.Hidden; 
			end
			]]
			leftRanking.Text = tostring(myRank);
			leftName.Text = tostring(rankFightAbilityData[myRank].nickname);	
			leftlevel.Text = tostring('Lv:'..rankFightAbilityData[myRank].lv);	
			leftFp.Text = tostring('戦闘力:'..rankFightAbilityData[myRank].fp);		

			if myRank == 1 then
				--chenghaoLable.Text = LANG_rankPanel_18;
				leftTitle.Image = GetPicture('rank_fight1');
			elseif myRank <= 5 then
				--chenghaoLable.Text = LANG_rankPanel_19;
				leftTitle.Image = GetPicture('rank_fight2');
			else
				--chenghaoLable.Visibility = Visibility.Hidden; 
				leftTitle.Visibility = Visibility.Hidden;
			end
			self:setLeftShow(true);
		else
			noLabel.Text = LANG_rankPanel_22;
			self:setLeftShow(false);
			--fightMyinfo.Visibility = Visibility.Hidden; 
			--fighttip.Visibility = Visibility.Visible;
		end			
	end	
end

function RankPanel:SetLevelPanel()
	if (ActorManager.user_data.reward.sec_2_tom <= requestCoolDownTime and IsLevelRank <= 1) or IsLevelRank == 0 then
		IsLevelRank = IsLevelRank + 1;
		self:SendGetLvRankMsg();
	else
		-- just use the old data
		--local ListPanel = levelPage:GetLogicChild('progress'):GetLogicChild('unionInformation')
		ListPanel:RemoveAllChildren();	
		local dataNum = #rankLevelData;
		--显示自己的排名
		local myRank = 1000;	
		local myUid = ActorManager.user_data.uid;
		for index,data in ipairs(rankLevelData) do
			if data.uid == myUid then
				myRank = index;	
			end
		end			
		for i = 1, dataNum do
			if i <= dataNum then
				local myself = false;
				if i == myRank then
					myself = true;
				end
				local rankinfo = customUserControl.new(ListPanel, 'RankingTemplate');
				rankinfo.initRankinfo(rankLevelData[i], i, RankType.Level, myself);
			end
		end
		--如果上榜
		if myRank <= 100 then
			--[[
			local myrankLable = levelMyinfo:GetLogicChild('MyRanking');
			local nameLable = levelMyinfo:GetLogicChild('name');
			local levelLable = levelMyinfo:GetLogicChild('level');
			local chenghaoLable = levelMyinfo:GetLogicChild('chenghao');
			local expLable = levelMyinfo:GetLogicChild('exp');
			myrankLable.Text = tostring(myRank);
			nameLable.Text = rankLevelData[myRank].nickname;
			levelLable.Text = tostring(rankLevelData[myRank].lv);
			expLable.Text = tostring(rankLevelData[myRank].exp);
			leveltip.Visibility = Visibility.Hidden;
			chenghaoLable.Visibility = Visibility.Visible; 
			if myRank == 1 then
				chenghaoLable.Text = LANG_rankPanel_13;
			elseif myRank <= 5 then
				chenghaoLable.Text = LANG_rankPanel_14;
			else
				chenghaoLable.Visibility = Visibility.Hidden; 
			end
			]]
			leftRanking.Text = tostring(myRank);
			leftName.Text = tostring(rankLevelData[myRank].nickname);	
			leftlevel.Text = tostring('Lv:'..rankLevelData[myRank].lv);	
			leftFp.Text = tostring('経験値:'..rankLevelData[myRank].exp);		

			if myRank == 1 then
				--chenghaoLable.Text = LANG_rankPanel_18;
				leftTitle.Image = GetPicture('rank_lv1');
			elseif myRank <= 5 then
				--chenghaoLable.Text = LANG_rankPanel_19;
				leftTitle.Image = GetPicture('rank_lv2');
			else
				--chenghaoLable.Visibility = Visibility.Hidden; 
				leftTitle.Visibility = Visibility.Hidden;
			end
			self:setLeftShow(true);
		else
			self:setLeftShow(false);
			noLabel.Text = LANG_rankPanel_22;
			--levelMyinfo.Visibility = Visibility.Hidden; 
			--leveltip.Visibility = Visibility.Visible;
		end			
	end	
end
function RankPanel:SetCardRankPanel()
	if (ActorManager.user_data.reward.sec_2_tom <= requestCoolDownTime and IsCardRank <= 1) or IsCardRank == 0 then
		IsCardRank = IsCardRank + 1;
		self:SendGetCardRankMsg();
	else
		-- just use the old data
		--local ListPanel = cardPage:GetLogicChild('progress'):GetLogicChild('unionInformation')
		ListPanel:RemoveAllChildren();	
		local dataNum = #rankCardData;
		--显示自己的排名
		local myRank = 1000;	
		local myUid = ActorManager.user_data.uid;
		for index,data in ipairs(rankCardData) do
			if data.uid == myUid then
				myRank = index;	
			end
		end			
		for i = 1, dataNum do
			if i <= dataNum then
				local myself = false;
				if i == myRank then
					myself = true;
				end
				local rankinfo = customUserControl.new(ListPanel, 'RankingTemplate');
				rankinfo.initRankinfo(rankCardData[i], i, RankType.Card, myself);
			end
		end
		--如果上榜
		if myRank <= 100 then
			--[[
			local myrankLable = cardMyinfo:GetLogicChild('MyRanking');
			local nameLable = cardMyinfo:GetLogicChild('name');
			local levelLable = cardMyinfo:GetLogicChild('level');
			local chenghaoLable = cardMyinfo:GetLogicChild('chenghao');
			local expLable = cardMyinfo:GetLogicChild('zhandouli');
			myrankLable.Text = tostring(myRank);
			nameLable.Text = rankCardData[myRank].nickname;
			levelLable.Text = tostring(rankCardData[myRank].level);
			expLable.Text = tostring(rankCardData[myRank].starnum);
			cardtip.Visibility = Visibility.Hidden;
			chenghaoLable.Visibility = Visibility.Visible; 
			if myRank == 1 then
				chenghaoLable.Text = LANG_rankPanel_15;
			elseif myRank <= 5 then
				chenghaoLable.Text = LANG_rankPanel_16;
			else
				chenghaoLable.Visibility = Visibility.Hidden; 
			end
			]]
			leftRanking.Text = tostring(myRank);
			leftName.Text = tostring(rankCardData[myRank].nickname);	
			leftlevel.Text = tostring('Lv:'..rankCardData[myRank].level);	
			leftFp.Text = tostring('昇格数:'..rankCardData[myRank].starnum);		

			if myRank == 1 then
				--chenghaoLable.Text = LANG_rankPanel_18;
				leftTitle.Image = GetPicture('rank_love1');
			elseif myRank <= 5 then
				--chenghaoLable.Text = LANG_rankPanel_19;
				leftTitle.Image = GetPicture('rank_love2');
			else
				--chenghaoLable.Visibility = Visibility.Hidden; 
				leftTitle.Visibility = Visibility.Hidden;
			end
			self:setLeftShow(true);
		else
			noLabel.Text = LANG_rankPanel_22;
			self:setLeftShow(false);
			--cardMyinfo.Visibility = Visibility.Hidden; 
			--cardtip.Visibility = Visibility.Visible;
		end			
	end	
end

function RankPanel:SetCardEventRankPanel()
	--[[ 每超过一小时更新一次，服务器每一小时更新一次 ]]
	tipLabel.Visibility = Visibility.Visible;
	if cardEventTimeStamp == 0 or (LuaTimerManager:GetCurrentTimeStamp() - cardEventTimeStamp > 120) then
		cardEventTimeStamp = LuaTimerManager:GetCurrentTimeStamp()
		self:SendGetCardEventRankMsg();
		return
	end
	-- just use the old data
	ListPanel:RemoveAllChildren()
	local dataNum = #rankCardEventData
	local myRank = ActorManager.user_data.functions.card_event.rank
	-- 显示自己的排名
	for i = 1, dataNum do
		if i <= dataNum then
			local myself = (i == myRank) and true or false
			local rankinfo = customUserControl.new(ListPanel, 'RankingTemplate')
			rankinfo.initRankinfo(rankCardEventData[i], i, RankType.CardEvent, myself)
		end
	end
	-- 如果上榜
	if myRank <= 100 then
		leftRanking.Text = tostring(myRank);
		leftName.Text = tostring(rankCardEventData[myRank].nickname);	
		leftlevel.Text = tostring('Lv:'..rankCardEventData[myRank].level);	
		leftFp.Text = tostring('勇気pt:'..rankCardEventData[myRank].score);		
		self:setLeftShow(true);
		leftTitle.Visibility = Visibility.Hidden;
	else
		noLabel.Text = LANG_rankPanel_22;
		self:setLeftShow(false);
	end
end

function RankPanel:SetUnionLevelRankPanel()
	--print("RankPanel:SetUnionLevelRankPanel");
	if (ActorManager.user_data.reward.sec_2_tom <= requestCoolDownTime and IsUnionRank <= 1) or IsUnionRank == 0 then
		IsUnionRank = IsUnionRank + 1;
		self:SendGetUnionRankMsg();		
	else
		local curUnionRank = 0;
		local curUnionDate = nil;
		-- just use the old data
		--local ListPanel = unionPage:GetLogicChild('progress'):GetLogicChild('unionInformation')
		ListPanel:RemoveAllChildren();	
		--uniontip.Visibility = Visibility.Visible;
		local dataNum = #rankUnionData;
		for i = 1, dataNum do
			if i <= dataNum then
				local rankinfo = customUserControl.new(ListPanel, 'RankingTemplate');
				rankinfo.initRankinfo(rankUnionData[i], i, RankType.Union, false);
				if rankUnionData[i].ggid == ActorManager.user_data.ggid then
					--uniontip.Visibility = Visibility.Hidden;
					curUnionDate = rankUnionData[i];
					curUnionRank = i;

				end
			end
		end	
		self:setLeftShow(false);
		if ActorManager.user_data.ggid == 0 then
			noLabel.Text = LANG_rankPanel_23;
		elseif curUnionDate ~= nil then
			leftRanking.Text = tostring(curUnionRank);
			leftName.Text = tostring(curUnionDate.name);	
			leftlevel.Text = tostring('Lv:'..curUnionDate.grade);	
			leftFp.Text = tostring('総貢献値:'..curUnionDate.allgm);
			self:setLeftShow(true);
		else
			noLabel.Text = LANG_rankPanel_22;
		end
		if curUnionRank == 1 then
			leftTitle.Image = GetPicture('rank_role1');
		else
			leftTitle.Visibility = Visibility.Hidden;
		end
	end
end

function RankPanel:RankingTemplateClick(Args)
	local args = UIControlEventArgs(Args);
	popMenuTagExt = args.m_pControl.TagExt
	popMenuPanel.Translate = Vector2(mouseCursor.Translate.x-50, mouseCursor.Translate.y-60);
	popMenuPanel.Visibility = Visibility.Visible
	mainDesktop.FocusControl = popMenuPanel;
end

function RankPanel:OnPopMenuClick()
	PersonInfoPanel:ReqOtherInfosClick(popMenuTagExt);
	popMenuPanel.Visibility = Visibility.Hidden
end

function RankPanel:onPopMenuPanelLoseFocus()
	popMenuPanel.Visibility = Visibility.Hidden
end
function RankPanel:GotFpRankMsg(msg)
	local rankUsers = msg.users;
	rankFightAbilityData = rankUsers;
	RankPanel:SetFightAbilityPanel();
end

function RankPanel:SendGetFpRankMsg()
	local msg = {}
	Network:Send(NetworkCmdType.req_fp_rank_t, msg);
end

function RankPanel:GotLvRankMsg(msg)
	local lvRankUsers = msg.users;
	rankLevelData = lvRankUsers;
	RankPanel:SetLevelPanel();	
end

function RankPanel:SendGetLvRankMsg()
	local msg = {}
	Network:Send(NetworkCmdType.req_lv_rank_t, msg);
end

function RankPanel:GotArenaRankMsg(msg)
	rankArenaData = {}
	pagesData = msg.pages

	for curIndex = 1, 100 do
		rankArenaData[curIndex] = {}
		rankArenaData[curIndex].nickname = ''
		rankArenaData[curIndex].lv = '';
		rankArenaData[curIndex].uid = '';
		rankArenaData[curIndex].fp = '';
		rankArenaData[curIndex].vip = 0;
	end

	for pageIndex,pageData in ipairs(pagesData) do
		detailData = cjson.decode(pageData)
		--print("the detaildata:"..pageData);
		local rankDetail = detailData.rows;
		for rowIndex,uData in ipairs(rankDetail) do			
			rankArenaData[uData.rank] = {}
			rankArenaData[uData.rank].nickname = uData.name
			rankArenaData[uData.rank].lv = uData.level
			rankArenaData[uData.rank].uid = uData.uid
			rankArenaData[uData.rank].fp = uData.fp
			rankArenaData[uData.rank].vip = tonumber(uData.vip);
		end
	end	
	RankPanel:SetArenaPanel();
end

function RankPanel:SendGetArenaRankMsg()
	local msg = {};
	Network:Send(NetworkCmdType.req_arena_rank_page, msg);
end



function RankPanel:GotUnionRankMsg(msg)
	local unionInfo = msg.users;

	rankUnionData = unionInfo;
	RankPanel:SetUnionLevelRankPanel();
end

function RankPanel:SendGetUnionRankMsg()
	--print ("RankPanel sendGetUnionRankMsg");
	local msg = {};
	Network:Send(NetworkCmdType.req_union_rank, msg);	
end


function RankPanel:IsRankUIShow()
	return isRankPanelShow;
end

function RankPanel:GotCardRankMsg(msg)
	local unionInfo = msg.users;	
	rankCardData = unionInfo;
	RankPanel:SetCardRankPanel();
end

function RankPanel:SendGetCardRankMsg()
	local msg = {};
	Network:Send(NetworkCmdType.req_card_rank, msg);	
end

--[[ 卡牌活动排行榜 ]]
function RankPanel:SendGetCardEventRankMsg()
	Network:Send(NetworkCmdType.req_card_event_rank_t, {})
end

function RankPanel:GotCardEventRankMsg(msg)
	local cardEventInfo = msg.users
	ActorManager.user_data.functions.card_event.rank = msg.rank
	rankCardEventData = cardEventInfo
	self:SetCardEventRankPanel()
end
