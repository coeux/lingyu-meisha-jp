--arenaPanel.lua
--================================================================================
ArenaPanel =
{
  records = {},
  playerList = {},
  remainTimes = 0;
  flag = 0; --0本服 1跨服
};

local mainDesktop;
local arenaPanel;
local imgBg;

-- left
local leftPanel;
local lblRank;
local lblFp;
local btnChangeTeam;
local rewardPanel;
local rankRewardLabel; 	
local prestigeImg;
local rewardTip;		
local shopbtn;
local unshopbtn;
-- right
local rightPanel;
local lblInfo;
local lblTimes;
local lblTitle;
local lblMeritorious;

local canChallenge
local countDown
local timeLeft
local ruleExplainBtn
local ruleExplainPanel
local explainBG
local ruleExplainContent

local rankExplainBtn
local rankExplainPanel
local tip 
local stackPanel
local GXicon
local GXNum
-- foot
local rankList = {};
--
local ranking = 0;
local meritorious = 0;
local countDownTime = 300
local roundTimer

local teamInfoPanel;
local heroList = {};

local topPanel;
local returnBtn;
local listBtn;
local grandBtn;
local opponentPanel;
local clickPanel;
local flagBtn;
--======================================================================================
function ArenaPanel:InitPanel(desktop)
  self.playerList = {};
  self.records = {}
  self.remainTimes = 0;
  ranking = 0;
  meritorious = 0;
 roundTimer = 0

  mainDesktop = desktop;
  arenaPanel = desktop:GetLogicChild('arenaPanel');
  arenaPanel:IncRefCount();

  topPanel = arenaPanel:GetLogicChild('topPanel');
  returnBtn = arenaPanel:GetLogicChild('returnBtn');
  listBtn = arenaPanel:GetLogicChild('listBtn');
  grandBtn = arenaPanel:GetLogicChild('grandBtn');
  ruleExplainBtn = arenaPanel:GetLogicChild('explainBtn')
  ruleExplainBtn:SubscribeScriptedEvent('Button::ClickEvent','ArenaPanel:showExplainPanel')
  ruleExplainPanel = arenaPanel:GetLogicChild('ruleExplain')
  ruleExplainContent = ruleExplainPanel:GetLogicChild('explainLabel')
  explainBG = arenaPanel:GetLogicChild('explainBG')
  explainBG:SubscribeScriptedEvent('UIControl::MouseClickEvent','ArenaPanel:onCloseExplain')
  ruleExplainContent.Text = LANG_ARENA_EXPLAIN

  teamInfoPanel = arenaPanel:GetLogicChild('roleAttPanel');
  teamInfoPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent','ArenaPanel:closeTeamInfoPanel');
  teamInfoPanel:IncRefCount();
  clickPanel = arenaPanel:GetLogicChild('clickPanel');
  clickPanel.Visibility = Visibility.Hidden;
  clickPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ArenaPanel:closeTeamInfoPanel');
  for i=1,5 do
    heroList[i] = teamInfoPanel:GetLogicChild('stackPanel'):GetLogicChild('hero' .. i);
  end

  imgBg = arenaPanel:GetLogicChild('bg');
  imgBg.Visibility = Visibility.Visible;
  self:InitLeftPanel();
  self:InitRightPanel();
  self:InitRankList();
  flagBtn = arenaPanel:GetLogicChild('flagBtn');
  flagBtn.Visibility = Visibility.Hidden;
  flagBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ArenaPanel:onChangeFlag');
end

function ArenaPanel:onChangeFlag()
	if self.flag == 0 then
		self:ReqArenaInfo(1);
	elseif self.flag == 1 then
		self:ReqArenaInfo(0);
	end
end

function ArenaPanel:InitLeftPanel()
  leftPanel = arenaPanel:GetLogicChild('leftInfo');
  lblRank = leftPanel:GetLogicChild('rank');
  lblFp = leftPanel:GetLogicChild('fp');
  btnChangeTeam = leftPanel:GetLogicChild('changeTeam');
  rewardPanel = leftPanel:GetLogicChild('reward');
  --leftPanel:GetLogicChild('tip').Text = LANG_arenaPanel_26;
  btnChangeTeam:SubscribeScriptedEvent('Button::ClickEvent', 'ArenaPanel:onChangeTeam');
  rankRewardLabel 	= leftPanel:GetLogicChild('rankRewardLabel');
  prestigeImg 		= leftPanel:GetLogicChild('coin');
  rewardTip  		= leftPanel:GetLogicChild('rewardTip');
  shopbtn			= leftPanel:GetLogicChild('shop');
	unshopbtn			= leftPanel:GetLogicChild('unshop');
	shopbtn:SubscribeScriptedEvent('Button::ClickEvent', 'ArenaPanel:onShopNormal')
	unshopbtn:SubscribeScriptedEvent('Button::ClickEvent', 'ArenaPanel:onShopUnion')
end

function ArenaPanel:InitRightPanel()
  rightPanel = arenaPanel:GetLogicChild('rightInfo');
  lblInfo = rightPanel:GetLogicChild('reward');
  lblTimes = rightPanel:GetLogicChild('count');
  lblTitle = rightPanel:GetLogicChild('name');
  lblMeritorious = rightPanel:GetLogicChild('times');

  canChallenge = rightPanel:GetLogicChild('canChallenge')
  countDown = rightPanel:GetLogicChild('countDown')
  timeLeft = rightPanel:GetLogicChild('time')
  rankExplainBtn = rightPanel:GetLogicChild('explainBtn')
  rankExplainBtn:SubscribeScriptedEvent('Button::ClickEvent', 'ArenaPanel:onExplainClick')
  rankExplainPanel = arenaPanel:GetLogicChild('rankExplain')
  stackPanel = rankExplainPanel:GetLogicChild('touchscrollPanel'):GetLogicChild('stackPanel')
  GXNum = rankExplainPanel:GetLogicChild('num');
  GXicon = rankExplainPanel:GetLogicChild('img')
  GXicon.Image = GetPicture('jingji/jingji_gongxun.ccz')
  tip = rankExplainPanel:GetLogicChild('tip')

  tip.Text = LANG_arena_meritrious
  rankExplainPanel.Visibility = Visibility.Hidden;
end

function ArenaPanel:onExplainClick()
  rankExplainPanel.Visibility = Visibility.Visible
  explainBG.Visibility = Visibility.Visible
  stackPanel:RemoveAllChildren()
  GXNum.Text = tostring(ActorManager.user_data.arena.meritorious);
  --  显示奖励
  local rowNum = #ArenaDialogPanel.titleupdata
  for i=rowNum,1,-1 do
    local control = uiSystem:CreateControl('arenaMeritoriousTemplate'):GetLogicChild(0)
    local meritoriousLabel = control:GetLogicChild('titlePanel'):GetLogicChild('meritorious')
    meritoriousLabel.Text = tostring(ArenaDialogPanel.titleupdata[i].name) .. ' ('
    local img = control:GetLogicChild('titlePanel'):GetLogicChild('img')
    img.Image = GetPicture('jingji/jingji_gongxun.ccz')
    local meritoriousNum= control:GetLogicChild('titlePanel'):GetLogicChild('meritriousNum')
    meritoriousNum.Text = tostring(ArenaDialogPanel.titleupdata[i].meritorious) .. ' )'
    
    --  显示多个奖励物品
    -- local rewardNum = #ArenaDialogPanel.titleupdata[i].reward
    -- for k=1,rewardNum do
    --   local goodsImg = control:GetLogicChild('goodsBG'):GetLogicChild('stackPanel'):GetLogicChild('goods' .. k):GetLogicChild('goodsImg')
    --   local goodsNum = control:GetLogicChild('goodsBG'):GetLogicChild('stackPanel'):GetLogicChild('goods'.. k):GetLogicChild('goodsNum')
    --   local path = resTableManager:GetValue(ResTable.item, tostring(ArenaDialogPanel.titleupdata[i].reward[k][1] or 10003),'icon')
    --   goodsImg.Image = GetPicture('icon/'.. path ..'.ccz')
    --   goodsNum.Text = tostring(ArenaDialogPanel.titleupdata[i].reward[k][2] or 0)
    -- end
    -- control:GetLogicChild('goodsBG'):GetLogicChild('stackPanel').Size = Size(50* rewardNum + (rewardNum - 1)*20, 70)
    -- for j=rewardNum + 1,5 do
    --   control:GetLogicChild('goodsBG'):GetLogicChild('stackPanel'):GetLogicChild('goods' .. j).Visibility = Visibility.Hidden
    -- end
    --  显示奖励 目前只有一个奖励物品
    local goodsImg = control:GetLogicChild('goodsBG'):GetLogicChild('stackPanel'):GetLogicChild('goods1'):GetLogicChild('goodsImg')
    local goodsNum = control:GetLogicChild('goodsBG'):GetLogicChild('stackPanel'):GetLogicChild('goods1'):GetLogicChild('goodsNum')
    local path = resTableManager:GetValue(ResTable.item, tostring(ArenaDialogPanel.titleupdata[i].reward[1] or 10003),'icon')
    goodsImg.Image = GetPicture('icon/'.. path ..'.ccz')
    goodsNum.Text = tostring(ArenaDialogPanel.titleupdata[i].reward[2] or 0)
    for j=2,5 do   
      control:GetLogicChild('goodsBG'):GetLogicChild('stackPanel'):GetLogicChild('goods' .. j).Visibility = Visibility.Hidden
    end
    control:GetLogicChild('goodsBG'):GetLogicChild('stackPanel').Size = Size(50, 70)

    stackPanel:AddChild(control)
  end 

end

function ArenaPanel:showExplainPanel()
  ruleExplainPanel.Visibility = Visibility.Visible
  explainBG.Visibility = Visibility.Visible
end

function ArenaPanel:onCloseExplain()
  ruleExplainPanel.Visibility = Visibility.Hidden
  explainBG.Visibility = Visibility.Hidden
  rankExplainPanel.Visibility = Visibility.Hidden
end

function ArenaPanel:InitRankList()
  opponentPanel = arenaPanel:GetLogicChild('ig');
  for i = 1, 5 do
    local list = {};
    local userPanel = arenaPanel:GetLogicChild('ig'):GetLogicChild(tostring(i));
    list.panel = userPanel;
    list.armature = userPanel:GetLogicChild('armature');
    list.armature.Scale = Vector2(1.4, 1.4);
    list.btn = userPanel:GetLogicChild('btn');
    list.btn:SubscribeScriptedEvent('Button::ClickEvent', 'ArenaPanel:showTeamInfoPanel');
    list.btn.Tag = i ;
    list.challenge = userPanel:GetLogicChild('challenge');
    list.rank = userPanel:GetLogicChild('rank');
    list.name = userPanel:GetLogicChild('panel'):GetLogicChild('name');
    list.fp = userPanel:GetLogicChild('panel'):GetLogicChild('zhandouli');
    list.challenge.Tag = i;
    list.challenge.TagExt = i;
    list.challenge:SubscribeScriptedEvent('Button::ClickEvent', 'ArenaPanel:onChallenge');
    table.insert(rankList, list);
  end
end

function ArenaPanel:showTeamInfoPanel(Args)
  local args = UIControlEventArgs(Args);
  local index = args.m_pControl.Tag;
  local teamInfo = self.playerList[index].team_info;
  local heroNum = 0;
  if teamInfo and #teamInfo > 0 then
    for i=1,#teamInfo do
      if teamInfo[i] then
        heroNum = heroNum + 1;
        heroList[heroNum].Visibility = Visibility.Visible;
        self:showTeamInfo(heroList[heroNum], teamInfo[i])
      end
    end
  
    teamInfoPanel:GetLogicChild('stackPanel').Size = Size(80 * heroNum + (heroNum -1)*10 + 20, 100);
    local len = (460 - (80 * 5 + (5 -1)*10))/2;     --总长度减去当前长度
    if index == 1 then
      teamInfoPanel.Translate = Vector2(130 + len, 0);
    elseif index == 2 then
      teamInfoPanel.Translate = Vector2(-60 + len, 0);
    elseif index == 3 then
      teamInfoPanel.Translate = Vector2(240 - len, 0);
    elseif index == 4 then
      teamInfoPanel.Translate = Vector2(90 - len, 0);
    elseif index == 5 then
      teamInfoPanel.Translate = Vector2(-110 - len, 0);
    end
    for i=#teamInfo + 1,5 do
      heroList[i].Visibility = Visibility.Hidden;
    end
    teamInfoPanel.Visibility = Visibility.Visible;
    clickPanel.Visibility = Visibility.Visible;
    -- mainDesktop:DoModal(teamInfoPanel);
    -- --增加UI弹出时候的效果
    -- StoryBoard:ShowUIStoryBoard(teamInfoPanel, StoryBoardType.ShowUI1);
  end
  if self.playerList[index].combo_pro then
	local comboPro = self.playerList[index].combo_pro;
	teamInfoPanel:GetLogicChild('att1').Text = string.format('%s%%',tostring(comboPro.combo_d_down or 0));
	teamInfoPanel:GetLogicChild('att2').Text = string.format('%s%%',tostring(comboPro.combo_r_down or 0));
	teamInfoPanel:GetLogicChild('att3').Text = string.format('%s%%',tostring(comboPro.combo_d_up or 0));
	teamInfoPanel:GetLogicChild('att4').Text = string.format('%s%%',tostring(comboPro.combo_r_up or 0));
	--print(string.format('combo_d_down->%s',tostring(comboPro.combo_d_down)));
	--print(string.format('combo_r_down->%s',tostring(comboPro.combo_r_down)));
	--print(string.format('combo_d_up->%s',tostring(comboPro.combo_d_up)));
	--print(string.format('combo_r_up->%s',tostring(comboPro.combo_r_up)));
	local combo10 = 0;
	local combo20 = 0;
	local combo30 = 0;
	local combo35 = 0;
	local combo40 = 0;
	if comboPro.combo_anger then
		for k,v in pairs(comboPro.combo_anger)do 
			print('k->'..tostring(k)..' v->'..tostring(v));
			local kk = tonumber(k);
			if kk == 10 then
				combo10 = v;
			elseif kk == 20 then
				combo20 = v;
			elseif kk == 30 then
				combo30 = v;
			elseif kk == 35 then
				combo35 = v;
			elseif kk == 40 then
				combo40 = v;
			end
		end
	end
	local att5 = teamInfoPanel:GetLogicChild('att5');
	att5.Text = string.format('%s/%s/%s/%s/%s（怒气）',tostring(combo10),tostring(combo20),tostring(combo30),tostring(combo35),tostring(combo40));
  end
end

function ArenaPanel:showTeamInfo(template, info) 
  local partnerItemList = uiSystem:CreateControl('cardHeadTemplate')
  partnerItemList:SetScale(0.8,0.8);
  local imgRole = partnerItemList:GetLogicChild(0):GetLogicChild('img');
  local lvlMark = partnerItemList:GetLogicChild(0):GetLogicChild('lvl');
  local attributeMark = partnerItemList:GetLogicChild(0):GetLogicChild('attribute');
  local qualityMark = partnerItemList:GetLogicChild(0):GetLogicChild('quality');
  local loveMark = partnerItemList:GetLogicChild(0):GetLogicChild('love');
  local fg = partnerItemList:GetLogicChild(0):GetLogicChild('fg');

  local selectMark = partnerItemList:GetLogicChild(0):GetLogicChild('select');
  selectMark.Visibility = Visibility.Hidden

  local role = resTableManager:GetRowValue(ResTable.actor, tostring(info.resid));
  --头像
  imgRole.Image = GetPicture('navi/' .. role.img .. '_icon_01.ccz')
  if info.lovelevel == 4 then
    imgRole.Image = GetPicture('navi/' .. role.img .. '_icon_02.ccz')
  end
  --等级
  lvlMark.Text = tostring(info.level)
  --左上角属性角标
  attributeMark.Image = GetPicture('login/login_icon_' .. role.attribute .. '.ccz')
  --右上角的阶数图标
  qualityMark.Image = GetPicture('personInfo/nature_' .. (info.starnum - 1) .. '.ccz')
  --根据装备等级来决定边框颜色
  fg.Image = GetPicture('home/head_frame_' .. info.equiplv .. '.ccz')
  --是否觉醒标识
  loveMark.Visibility = (info.lovelevel == 4) and Visibility.Visible or Visibility.Hidden 

  template:AddChild(partnerItemList);
  partnerItemList.Margin = Rect(0, -10, 0, 0)
end

function ArenaPanel:closeTeamInfoPanel()
  for i=1,5 do
    heroList[i]:RemoveAllChildren();
  end
  -- StoryBoard:HideUIStoryBoard(teamInfoPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
  teamInfoPanel.Visibility = Visibility.Hidden;
  clickPanel.Visibility = Visibility.Hidden;
end

--======================================================================================
function ArenaPanel:onShowArena(msg)
	self.flag = msg.flag;
	WorldMapPanel.matchingTip.Visibility = Visibility.Hidden
	WorldMapPanel.matchingTip.Storyboard = ''
  --适配
  if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
    local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
    topPanel:SetScale(factor,factor);
    returnBtn:SetScale(factor,factor);
    topPanel.Translate = Vector2(470*(factor-1)/2,50*(factor-1)/2);
    returnBtn.Translate = Vector2(86*(factor-1)/2,52*(factor-1)/2);
    grandBtn:SetScale(factor,factor);
    listBtn:SetScale(factor,factor);
    ruleExplainBtn:SetScale(factor,factor);
    grandBtn.Translate = Vector2(91*(1-factor)/2,55*(factor-1)/2);
    listBtn.Translate = Vector2(91*(1-factor)/2*3,55*(factor-1)/2);--x偏移= grandBtn x方向偏移 + grandBtn长(width)变化量/2 + listBtn长(width)变化量/2
    ruleExplainBtn.Translate = Vector2(91*(1-factor)/2*5,55*(factor-1)/2);--x偏移= listBtn x方向偏移 + listBtn长(width)变化量/2 + ruleExplainBtn长(width)变化量/2
    leftPanel:SetScale(factor,factor);
    rightPanel:SetScale(factor,factor);
    leftPanel.Translate = Vector2(415*(factor-1)/2,155*(factor-1)/2);
    rightPanel.Translate = Vector2(235*(1-factor)/2,155*(factor-1)/2);
    opponentPanel:SetScale(factor,factor);
    opponentPanel.Translate = Vector2(0,350*(1-factor)/2);
    ruleExplainPanel:SetScale(factor,factor);
    rankExplainPanel:SetScale(factor,factor);
    stackPanel:SetScale(factor,factor);
  end

  if self.flag == 0 then
	  topPanel:GetLogicChild('fontImage').Text = LANG_arenaPanel_28;
	  flagBtn:GetLogicChild('btnName').Text = LANG_arenaPanel_31;
	  shopbtn.Visibility = Visibility.Visible;
		unshopbtn.Visibility = Visibility.Hidden;
		prestigeImg.Image = GetPicture('jingji/11_06.ccz');
  elseif self.flag == 1 then
	  topPanel:GetLogicChild('fontImage').Text = LANG_arenaPanel_29;
	  flagBtn:GetLogicChild('btnName').Text = LANG_arenaPanel_30;
		unshopbtn.Visibility = Visibility.Visible;
		shopbtn.Visibility = Visibility.Hidden;
		prestigeImg.Image = GetPicture('jingji/11_07.ccz');
  end
  leftPanel:GetLogicChild('type').Visibility = Visibility.Hidden;
  self.playerList = msg.targets;
  table.sort(self.playerList, function(r1, r2) return r1.rank < r2.rank end);
  self.records = msg.records;
  table.sort(self.records, function(t1, t2) return t1.during < t2.during end);
  self.remainTimes = msg.fight_count;
  ranking = msg.rank;
  meritorious = msg.meritorious;
  countDownTime = msg.time
  --  更新冷却时间
  LuaTimerManager.fightArenaCDTime = msg.time
  self:StartTimer()

  if arenaPanel.Visibility == Visibility.Visible then
    self:Refresh();
  else
    MainUI:Push(self);
  end
end

function ArenaPanel:isShow()
  return arenaPanel.Visibility == Visibility.Visible
end

function ArenaPanel:Show()
  arenaPanel:GetLogicChild('bg').Background = CreateTextureBrush('background/jingji_bg.jpg', 'background')
  self:Refresh();
  mainDesktop:DoModal(arenaPanel);
  StoryBoard:ShowUIStoryBoard(arenaPanel, StoryBoardType.ShowUI1, nil, '');  
end

function ArenaPanel:ReqArenaInfo(arenaFlag)
	if ActorManager.hero:GetLevel() >= FunctionOpenLevel.arena then
		WorldMapPanel.matchingTip.Visibility = Visibility.Visible
		WorldMapPanel.matchingTip.Storyboard = 'storyboard.Delay2'
		local msg = {
			flag = arenaFlag;
		}
		Network:Send(NetworkCmdType.req_arena_info, msg);
	else
		Toast:MakeToast(Toast.TimeLength_Long, LANG_arenaPanel_27);
	end
end

function ArenaPanel:Hide()
  StoryBoard:HideUIStoryBoard(arenaPanel, StoryBoardType.HideUI1, 'ArenaPanel:onDestroy');
end

function ArenaPanel:onDestroy()
  arenaPanel:GetLogicChild('bg').Background = nil;
  DestroyBrushAndImage('background/jingji_bg.jpg', 'background')
  StoryBoard:OnPopUI();
end

function ArenaPanel:Destroy()
  arenaPanel:DecRefCount();
  arenaPanel = nil;

  teamInfoPanel:DecRefCount();
  teamInfoPanel = nil;
end
--======================================================================================
function ArenaPanel:Refresh()
  -- foot
  for i = 1, 5 do
    if nil ~= self.playerList[i] then
      rankList[i].panel.Visibility = Visibility.Visible;
      rankList[i].challenge.TagExt = self.playerList[i].rank;
      rankList[i].rank.Text = self.playerList[i].rank .. LANG_arenaPanel_12;
	  rankList[i].armature:DetachAllEffect();
	  if self.flag == 1 then
		  if tonumber(self.playerList[i].hostnum) < 100 then
			  rankList[i].name.Text = tostring(self.playerList[i].hostnum) .. '服-' .. self.playerList[i].name;
		  else
			  local hostnum = tonumber(self.playerList[i].hostnum);
			  hostnum = hostnum -100;
			  local t1,t2 = math.modf(hostnum / 10);
			  hostnum = t1*5 + t2*10;
			  rankList[i].name.Text = tostring(hostnum) .. '服-' .. self.playerList[i].name;
		  end
	  elseif self.flag == 0 then
		  rankList[i].name.Text = self.playerList[i].name;
	  end

      rankList[i].fp.Text = tostring(self.playerList[i].fp);

      local roleData = resTableManager:GetRowValue(ResTable.actor, tostring(self.playerList[i].model));
      if nil ~= roleData then
        local path = GlobalData.AnimationPath .. roleData['path'] .. '/';
        AvatarManager:LoadFile(path);
        rankList[i].armature:LoadArmature(roleData['img']);
        rankList[i].armature:SetAnimation(AnimationType.idle);

		--if self.playerList[i].uid == ActorManager.user_data.uid then
		if true then
		 local wingid = self.playerList[i].wingid;
			if wingid ~= nil and wingid > -1 then
				rankList[i].armature:SetAnimation(AnimationType.fly_idle);
				AddWingsToUIActor(rankList[i].armature, wingid);
			end
		end
      end

    else
      rankList[i].panel.Visibility = Visibility.Hidden;
    end
  end
  -- left
  lblRank.Text = tostring(ranking);
  lblFp.Text = tostring(ActorManager.user_data.fp);
  local id = ranking;
  if ranking >= 2000 then     id = 2001;
  elseif ranking > 1000 then id = 2000;
  elseif ranking > 700 then  id = 1000;
  elseif ranking > 500 then  id = 700;
  elseif ranking > 400 then  id = 500;
  elseif ranking > 300 then  id = 400;
  elseif ranking > 200 then  id = 300;
  elseif ranking > 100 then  id = 200;
  else id = ranking; end
  rewardPanel.Visibility = Visibility.Visible;
  rankRewardLabel.Visibility = Visibility.Visible; 
  prestigeImg.Visibility = Visibility.Visible;
  rewardTip.Visibility = Visibility.Hidden  
  if ranking > 3000 then
		rewardPanel.Visibility = Visibility.Hidden;
		rankRewardLabel.Visibility = Visibility.Hidden; 	
		prestigeImg.Visibility = Visibility.Hidden;
		rewardTip.Visibility = Visibility.Visible	
  else
	  local reward;
	  if self.flag == 0 then
		  reward = resTableManager:GetRowValue(ResTable.arena_reward, tostring(id));
	  elseif self.flag == 1 then
		  reward = resTableManager:GetRowValue(ResTable.unarena_reward, tostring(id));
	  end
  for i = 1, 3 do
    local itemPanel = rewardPanel:GetLogicChild(tostring(i));
    local icon = itemPanel:GetLogicChild('icon');
    local count = itemPanel:GetLogicChild('count');

    if i == 1 and self.flag == 0 then self:setReward(icon, count, 10010, reward['honor_win']); end
    if i == 1 and self.flag == 1 then self:setReward(icon, count, 16013, reward['honor_win']); end
    if i == 2 or i == 3 then
	  if not reward['item'] then
        itemPanel.Visibility = Visibility.Hidden;
	  elseif next(reward['item']) and next(reward['item'][i - 1]) then
        itemPanel.Visibility = Visibility.Visible;
        self:setReward(icon, count, reward['item'][i - 1][1], reward['item'][i - 1][2]);
      else
        itemPanel.Visibility = Visibility.Hidden;
      end
    end
  end
  end
  -- right
  lblTimes.Text = tostring(self.remainTimes);
  if countDownTime == 0  then
    --  挑战次数是否已经用完
    canChallenge.Visibility = Visibility.Visible
    timeLeft.Visibility = Visibility.Hidden
    countDown.Visibility = Visibility.Hidden
    if self.remainTimes > 0 then
      --  判断是否在冷却时间内
      canChallenge.Text = LANG_ARENA_CAN_CHALLENGE
    else
      canChallenge.Text = LANG_ARENA_NO_CHALLENGE
    end
  else
    canChallenge.Visibility = Visibility.Hidden
    timeLeft.Visibility = Visibility.Visible
    countDown.Visibility = Visibility.Visible
    if not countDownTime then
      countDownTime = 0
    end
    timeLeft.Text = tostring(Time2MinSecStr(countDownTime))
  end
  
  local data1 = resTableManager:GetRowValue(ResTable.title_up, tostring(ActorManager.user_data.arena.title_lv));
  local data2 = resTableManager:GetRowValue(ResTable.title_up, tostring(ActorManager.user_data.arena.title_lv + 1));
  if data1 then
    lblTitle.Text = data1['name'];
  end
  if ActorManager.user_data.arena.title_lv == 0 or not data1 then
    lblTitle.Text = '無';
  end

  if data2 then
    -- lblMeritorious.Text = ActorManager.user_data.arena.meritorious .. '/' .. (data2['meritorious'] - data1['meritorious']);
  else
    local data0 = resTableManager:GetRowValue(ResTable.title_up, tostring(ActorManager.user_data.arena.title_lv - 1));
    -- lblMeritorious.Text = ActorManager.user_data.arena.meritorious .. '/' .. (data1['meritorious'] - data0['meritorious']);
  end
  if data1 then
    local item = resTableManager:GetRowValue(ResTable.item, tostring(data1['reward'][1]));
    -- lblInfo.Text = LANG_arenaPanel_25 .. item['name'] .. " x" .. data1['reward'][2];
  end
  --  新手引导
  timerManager:CreateTimer(0.1, 'ArenaPanel:onEnterUserGuilde', 0, true)
end

function ArenaPanel:setReward(icon, count, itemid, cnt)
  local itm = resTableManager:GetRowValue(ResTable.item, tostring(itemid));
  icon.Image = GetPicture('icon/'..itm['icon']..'.ccz');
  count.Text = tostring(cnt);
end
--======================================================================================
-- SubscribeScriptedEvent
function ArenaPanel:onReturn()
  MainUI:Pop();
end

function ArenaPanel:onRank()
  RankPanel:ShowArenaRank();
end

function ArenaPanel:onRecord()
  ArenaDialogPanel:onShow(1);
end

function ArenaPanel:onChangeTeam()
  self:Hide();
  TeamPanel:Show(0, function() ArenaPanel:Show(); end);
end

function ArenaPanel:onShopNormal()
  ShopSetPanel:show(ShopSetType.pvpShop)
  -- PrestigeShopPanel:onShow(Prestige_shoptype.normal);
end

function ArenaPanel:onShopUnion()
  ShopSetPanel:show(ShopSetType.pvpBigShop)
  -- PrestigeShopPanel:onShow(Prestige_shoptype.union);
end

function ArenaPanel:onBuy()
  BuyCountPanel:ApplyData(VipBuyType.vop_buy_fight_count);
end

function ArenaPanel:onClearTime()
  BuyCountPanel:ApplyData(VipBuyType.vop_arena_clear_time)
end

function ArenaPanel:onChallenge(Args)
  local args = UIControlEventArgs(Args);
  local index = args.m_pControl.Tag;
  if self.playerList[args.m_pControl.Tag].uid == ActorManager.user_data.uid then
    ToastMove:CreateToast(LANG_arenaPanel_22);
  elseif countDownTime ~= 0 then -- 时间
    self:onClearTime();
  elseif self.remainTimes <= 0 then -- 次数
    self:onBuyChallengeCount();
    BuyCountPanel:SetTitle(LANG_arenaPanel_23);
  else
	self:playRoleSound();
    local msg = {};
    msg.pos = args.m_pControl.Tag;
    Network:Send(NetworkCmdType.req_begin_arena_fight, msg);
    Loading.waitMsgNum = 1;
    Game:SwitchState(GameState.loadingState);
    --  进入冷却时间
    countDown.Visibility = Visibility.Visible
    timeLeft.Visibility = Visibility.Visible
    canChallenge.Visibility = Visibility.Hidden
    if not countDownTime then
      countDownTime = 0
    end
    timeLeft.Text = tostring(Time2MinSecStr(countDownTime))
    self:ReStartTimer()
  end
  --  发送信息告诉服务器完成竞技场新手引导
  if UserGuidePanel:IsInGuidence(UserGuideIndex.arenaTask, 1) and UserGuidePanel.isArenaBegin then
    UserGuidePanel:ReqWriteGuidence(UserGuideIndex.arenaTask,1)
  end
end
function ArenaPanel:playRoleSound()
	--  获取当前参加战斗的队伍信息
	local team = MutipleTeam:getTeam(MutipleTeam:getDefault())
	--  战斗时从队伍中随机选一个英雄播放音效
	local len = 5
	for i=5,1, -1 do
		if team[i] == -1 then
			len = 5 - i
			break
		end
	end
	if len == 0 then
	else
		local random = math.random(1,len)
		local pid = team[6 - random]
		local role = ActorManager:GetRole(pid)   --  获取英雄信息
		local naviInfo
		if role.lvl.lovelevel == LovePanel.MAX_LOVE_TASK_LEVEL then
			naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(role.resid + 10000));
		else
			naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(role.resid));
		end
		--  获取声音
		if naviInfo then
			local path = random % (#naviInfo['soundlist']) + 1
			local soundPath = naviInfo['soundlist'][path]
			SoundManager:PlayVoice( tostring(soundPath) )
		end
	end
end
function ArenaPanel:StartTimer()
  if roundTimer == 0 then
    roundTimer = timerManager:CreateTimer(1.0, 'ArenaPanel:onRefreshTime', 0);
  end
end

function ArenaPanel:ReStartTimer(time)
  if time then
    LuaTimerManager.fightArenaCDTime = time
    countDownTime = time
    LimitTaskPanel:updateTask(LimitNews.arena);
  end
  -- countDownTime = time
  if roundTimer ~= 0 then
    timerManager:DestroyTimer(roundTimer);
    roundTimer = 0;
  end
  roundTimer = timerManager:CreateTimer(1.0, 'ArenaPanel:onRefreshTime', 0);
end

function ArenaPanel:onRefreshTime()
  if countDownTime == 0 then
    countDown.Visibility = Visibility.Hidden
    timeLeft.Visibility = Visibility.Hidden
    canChallenge.Visibility = Visibility.Visible
    if self.remainTimes > 0 then
      canChallenge.Text = LANG_ARENA_CAN_CHALLENGE
    else
      canChallenge.Text = LANG_ARENA_NO_CHALLENGE
    end
    return;
  end

  if countDownTime > 0 then
    countDownTime = countDownTime - 1;
  else 
    if 0 ~= roundTimer then
      timerManager:DestroyTimer(roundTimer);
      roundTimer = 0;
    end
  end
  if not countDownTime then
    countDownTime = 0
  end
  timeLeft.Text = tostring(Time2MinSecStr(countDownTime))
end

--======================================================================================
function ArenaPanel:onRetBuyChallengeCount(msg)
  self.remainTimes = msg.fight_count +self. remainTimes;
  lblTimes.Text = tostring(self.remainTimes);
  --  挑战次数是否已经用完
  if countDownTime == 0 then
    canChallenge.Visibility = Visibility.Visible
    if self.remainTimes > 0 then
      --  判断是否在冷却时间内
      canChallenge.Text = LANG_ARENA_CAN_CHALLENGE
    else
      canChallenge.Text = LANG_ARENA_NO_CHALLENGE
    end
  end
end

function ArenaPanel:onRetClearTime(msg)
  countDownTime = 0
  if self.remainTimes > 0 then
    --  判断是否在冷却时间内
    canChallenge.Text = LANG_ARENA_CAN_CHALLENGE
  else
    canChallenge.Text = LANG_ARENA_NO_CHALLENGE
  end
end

function ArenaPanel:onBuyChallengeCount()
  BuyCountPanel:ApplyData(VipBuyType.vop_buy_fight_count);
end

function ArenaPanel:OnArenaFightOverCallBack(data)
  local result = (data == Victory.left);
  Network:Send(NetworkCmdType.req_end_arena_fight, {is_win = result, salt = tostring(_G['salt#arena'])});      --战斗结束通知
  ArenaPanel:ReqArenaInfo(self.flag);     --刷新竞技场界面
end
--======================================================================================
function ArenaPanel:ResetChallengeTimeAt24()
  self.remainTimes = 5;
  
  if arenaPanel.Visibility == Visibility.Visible then
    labelRemainTimes.Text = tostring(self.remainTimes);
  end  
end

function ArenaPanel:GetTime( t )
  if t < 60 then
    --1分钟内
    return LANG_arenaPanel_18;
  elseif t < 3600 then
    --1小时内
    return math.floor(t / 60) .. LANG_arenaPanel_19;
  elseif t < 86400 then
    --1天内
    return math.floor(t / 3600) .. LANG_arenaPanel_20;
  elseif t < 2592000 then
    --1月内
    return math.floor(t / 86400) .. LANG_arenaPanel_21;
  end
end

function ArenaPanel:onEnterUserGuilde(  )
  if UserGuidePanel:IsInGuidence(UserGuideIndex.arenaTask, 1) and UserGuidePanel.isArenaBegin then          --  竞技场
    UserGuidePanel:ShowGuideShade( rankList[5].challenge,GuideEffectType.hand,GuideTipPos.right,'', 0.3)
  end
end

--======================================================================================
