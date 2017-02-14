--menuPanel.lua

--========================================================================
--依赖

LoadLuaFile("lua/base/enum.lua");

--========================================================================
--菜单界面

MenuPanel =
  {
    chuxiangEffectPath      = 'chuxianxintubiao_output/';    --功能开启的特效
    chuxiangEffectName      = 'chuxianxintubiao';

    kaifangEffectPath      = 'xitongkaiqi_output/';      --功能可以点击的特效
    kaifangEffectName      = 'xitongkaiqi';

    leftCountList        = {};

    functionMap          = {};    --功能映射
  };

local refreshTimer = 0;
local showLeftmenuFlag = true;

--控件
local mainDesktop;
local extentButton;
local extentBrush;
local firstButtonPanel;
local topPanel;
local bottomPanel;
local secondButtonPanel;
local extentMergeOne;
local extentMergeTwo;
local subLevelMenuPanel;

--下面一排按钮
local btnRole;
local btnTeam;
local btnRefine;
local btnStrength;
local btnMergeStrength;
local btnGem;
local btnBag;
local btnPub;
local btnTask;
local btnMergeFirst;

--上面一排
local btnUnion;
local btnFriend;
local btnMiku;
--local btnTrain;
local btnSkill;
local btnStarMap;
local btnRune;
local btnDragon;
local btnRoleAdvance;
local btnLimitround;
local btnWing;

--右边排按钮
local btnElite;
local btnArena;
local btnTrial;
local btnZodiac;
local btnMergeSecond;

--中间弹出按钮
local subbtnRoleAdvance;

--左边按钮
local btnHome;
local btnTask;
local pubHeroBtn;
local taskBtn;
local showUnionBtn;

local isMoveOut = true;              --+号默认不移入

local taskid;
local level;
local curMenu;        --当前的按钮
-- leftMenuPanel
local LeftMenuPanel;
local adPanel;
local showPanel;
local eventPanel;
local lftMenuPanel;
local controlBtn;
local controlImg;
local feedbackBtn;
--排行榜
local signBtn;


-- rightMenuPanel
local RightMenuPanel;
local armature   --  特效
local pveArmature

--初始化面板
function MenuPanel:InitPanel(desktop)
  --类变量初始化
  MenuPanel.leftCountList = {};
  self.isHaveAcceptFlower = false
  self.isCanSendFlower = false
  self.isHaveFriend = false
  --变量初始化
  refreshTimer = 0;
  isMoveOut = true;              --+号默认不移入
  taskid = 0;
  level = 0;

  --========================================================================
  --事件绑定
  --========================================================================
  --任务
  RightMenuPanel = desktop:GetLogicChild('RightMenuPanel');
  RightMenuPanel.Visibility = Visibility.Visible;
  
  taskBtn = desktop:GetLogicChild('RightMenuPanel'):GetLogicChild('taskPanel'):GetLogicChild('taskbutton');
  taskBtn:SubscribeScriptedEvent('Button::ClickEvent', 'MainUI:onTask');
  taskBtn.Visibility = Visibility.Visible;
  --招募
  pubHeroBtn = desktop:GetLogicChild('RightMenuPanel'):GetLogicChild('recruitPanel'):GetLogicChild('recruit1button');
  pubHeroBtn:SubscribeScriptedEvent('Button::ClickEvent', 'MainUI:onYingLingDian');
  pubHeroBtn.Visibility = Visibility.Visible;
  --公会
  showUnionBtn = desktop:GetLogicChild('RightMenuPanel'):GetLogicChild('unionPanel'):GetLogicChild('unionbutton');
  showUnionBtn:SubscribeScriptedEvent('Button::ClickEvent', 'MainUI:onShowUnion');
  showUnionBtn.Visibility = Visibility.Visible;
  --商城
  local shopBtn = desktop:GetLogicChild('RightMenuPanel'):GetLogicChild('shopPanel'):GetLogicChild('shopbutton');
  shopBtn:SubscribeScriptedEvent('Button::ClickEvent', 'MainUI:onShopClick');
  shopBtn.Visibility = Visibility.Visible;
  --回家
  btnHome = desktop:GetLogicChild('RightMenuPanel'):GetLogicChild('homebutton');
  btnHome:SubscribeScriptedEvent('Button::ClickEvent', 'HomePanel:onEnterHomePanel');

  --副本
  btnPve = desktop:GetLogicChild('RightMenuPanel'):GetLogicChild('taskbutton');
  btnPve:SubscribeScriptedEvent('Button::ClickEvent', 'WorldMapPanel:onEnterWorldMapPanel')

  pveArmature = PlayEffect('fuben2_output/',Rect(0,7,8,0),'fuben2',btnPve)
  pveArmature:SetScale(1.5,1.5)
  
  --广告
  adPanel = desktop:GetLogicChild('adPanel')
  local imgImg  = adPanel:GetLogicChild('Img');
  if platformSDK.m_Platform == 'uc'  or platformSDK.m_Platform == 'downjoy' then
	  imgImg.Image = GetPicture('zhujiemian/zhujiemian_ad_uc.jpg');
  else
	  imgImg.Image = GetPicture('zhujiemian/zhujiemian_ad.jpg');
  end
  adPanel.Visibility = Visibility.Hidden;

  showPanel = desktop:GetLogicChild('showPanel');
  showPanel.Visibility = Visibility.Visible;

  --反馈面板
  feedbackBtn = desktop:GetLogicChild('feedPanelBtn')
  feedbackBtn.Background = CreateTextureBrush('main/feedback_1.ccz', 'menuPanel');
  --feedbackBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','FeedbackPanel:Show');
  feedbackBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','MenuPanel:clickFeedBack');
  feedbackBtn.Visibility = Visibility.Visible;
  self:isShowFeedbackPanel();  
  
  --活动面板
  eventPanel = showPanel:GetLogicChild('eventPanel');
  eventPanel.Visibility = Visibility.Visible;
  eventPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'MenuPanel:EventCard');
  self:UpdateEventPanel();
  
  --界面初始化
  mainDesktop = desktop;
  extentButton = desktop:GetLogicChild('extentButton');
  extentBrush = desktop:GetLogicChild('extentBrush');
  firstButtonPanel = desktop:GetLogicChild('firstButtonPanel');
  firstButtonPanel:IncRefCount();
  secondButtonPanel = desktop:GetLogicChild('secondButtonPanel');
  secondButtonPanel:IncRefCount();
  extentMergeOne = desktop:GetLogicChild('mergeOne');
  extentMergeTwo = desktop:GetLogicChild('mergeTwo');
  subLevelMenuPanel = desktop:GetLogicChild('subLevelMenuPanel');
  subLevelMenuPanel:IncRefCount();

  self:LeftMenuPanelInit();
  if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		RightMenuPanel:SetScale(-factor,factor);
		RightMenuPanel.Translate = Vector2(474*(1-factor)/2,78*(1-factor)/2);
		showPanel:SetScale(factor,factor);
		showPanel.Translate = Vector2(269*(factor-1)/2,87*(1-factor)/2);
    feedbackBtn:SetScale(factor,factor);
    feedbackBtn.Translate = Vector2(269*(factor-1)/2,87*(1-factor)/2);
		LeftMenuPanel:SetScale(factor,factor);
		LeftMenuPanel.Translate = Vector2(365*(factor-1)/2, 59*(1-factor)/2);
  end
  subLevelMenuPanel.Show = function ()
    mainDesktop:DoModal(subLevelMenuPanel);
  end
  subLevelMenuPanel.Hide = function ()
    mainDesktop:UndoModal();
  end

  firstButtonPanel.Visibility = Visibility.Hidden;
  secondButtonPanel.Visibility = Visibility.Hidden;
  firstButtonPanel.Storyboard = 'storyboard.moveOut_1';
  secondButtonPanel.Storyboard = 'storyboard.moveOut_2';
  subLevelMenuPanel.Visibility = Visibility.Hidden;

  topPanel = StackPanel(firstButtonPanel:GetLogicChild('topPanel'));
  bottomPanel = StackPanel(firstButtonPanel:GetLogicChild('bottomPanel'));

  btnRole = Button(bottomPanel:GetLogicChild('renwu'));
  btnTeam = Button(bottomPanel:GetLogicChild('duiwu'));
  btnRefine = Button(bottomPanel:GetLogicChild('qianli'));
  btnStrength = Button(bottomPanel:GetLogicChild('qianghua'));
  btnGem = Button(bottomPanel:GetLogicChild('baoshi'));
  btnPub = Button(bottomPanel:GetLogicChild('yinglingdian'));
  btnBag = Button(bottomPanel:GetLogicChild('beibao'));
  btnTask = Button(bottomPanel:GetLogicChild('task'));
  btnMergeFirst = Button(bottomPanel:GetLogicChild('merge'));
  btnRoleAdvance = Button(bottomPanel:GetLogicChild('shengxing'));

  --弹出界面
  local mergeIconGrid = subLevelMenuPanel:GetLogicChild('iconGrid');
  btnMergeStrength = mergeIconGrid:GetLogicChild('qianghua');

  --二级界面层
  btnRune = Button(topPanel:GetLogicChild('fuwen'));
  btnUnion = Button(topPanel:GetLogicChild('union'));
  btnFriend = Button(topPanel:GetLogicChild('haoyou'));
  --btnTrain = TeamOrderPanel.btnTrain;
  btnSkill = Button(topPanel:GetLogicChild('jineng'));
  btnStarMap = Button(topPanel:GetLogicChild('starmap'));
  btnLimitround = Button(topPanel:GetLogicChild('limitround'));
  btnWing = Button(topPanel:GetLogicChild('chibang'));

  --二级界面层
  btnMiku = Button(secondButtonPanel:GetLogicChild('miku'));
  btnDragon = Button(secondButtonPanel:GetLogicChild('dragon'));
  btnElite = Button(secondButtonPanel:GetLogicChild('jingying'));
  btnArena = Button(secondButtonPanel:GetLogicChild('jingjichang'));
  btnTrial = Button(secondButtonPanel:GetLogicChild('trial'));
  btnZodiac = Button(secondButtonPanel:GetLogicChild('shiergong'));
  btnMergeSecond = Button(secondButtonPanel:GetLogicChild('merge'));

  --中间界面
  subbtnRoleAdvance = Button(subLevelMenuPanel:GetLogicChild('iconGrid'):GetLogicChild('shengxing'));

  --==============================================================================
  --==============================================================================

  --新手引导开放
  --self.userGuidMap = {};

  --self.userGuidMap[SystemTaskId.strength]  = { clickbutton = btnStrength, prompt = LANG_menuPanel_1 };          --强化
  --self.userGuidMap[SystemTaskId.team]    = { clickbutton = btnTeam, prompt = LANG_menuPanel_2 };            --队伍
  --self.userGuidMap[SystemTaskId.pub]    = { clickbutton = btnPub, prompt = LANG_menuPanel_3 };          --英灵殿
--  self.userGuidMap[SystemTaskId.elite]  = { clickbutton = btnElite, prompt = LANG_menuPanel_4 };        --精英关卡

  btnElite.Visibility = Visibility.Hidden;    --精英关闭

  --==============================================================================
  --==============================================================================

  --初始化功能映射
  self.functionMap = {};

  --功能点开放
  table.insert( self.functionMap, { brush = btnArena.NormalBrush, effectbutton = btnArena, clickbutton = btnArena, panel = ArenaPanel, firstClick = FunctionFirstClickOpen.arena, openLevel = FunctionOpenLevel.arena, prompt = LANG_menuPanel_5 } );    --竞技场
  table.insert( self.functionMap, { brush = btnTrial.NormalBrush, effectbutton = btnTrial, clickbutton = btnTrial, panel = TrainPanel, firstClick = FunctionFirstClickOpen.trial, openLevel = FunctionOpenLevel.trial, prompt = LANG_menuPanel_6 } );    --试炼
  table.insert( self.functionMap,  { brush = btnSkill.NormalBrush, effectbutton = btnSkill, clickbutton = btnSkill, panel = SkillPanel, firstClick = FunctionFirstClickOpen.skill, openLevel =FunctionOpenLevel.skill, prompt = LANG_menuPanel_7 } );    --技能
  table.insert( self.functionMap,  { brush = btnZodiac.NormalBrush, effectbutton = btnZodiac, clickbutton = btnZodiac, panel = ZodiacSignPanel, firstClick = FunctionFirstClickOpen.zodiac, openLevel = FunctionOpenLevel.zodiac, prompt = LANG_menuPanel_8 } );    --十二宫
  --table.insert( self.functionMap, { brush = btnTrain.NormalBrush, effectbutton = btnTrain, clickbutton = btnTeam, panel = TrainPanel, firstClick = FunctionFirstClickOpen.train, openLevel = FunctionOpenLevel.train, prompt = LANG_menuPanel_9 } );    --训练场
  table.insert( self.functionMap, { brush = btnUnion.NormalBrush, effectbutton = btnUnion, clickbutton = btnUnion, panel = UnionPanel, firstClick = FunctionFirstClickOpen.union, openLevel = FunctionOpenLevel.union, prompt = LANG_menuPanel_10 } );    --公会
  table.insert( self.functionMap, { brush = btnDragon.NormalBrush, effectbutton = btnDragon, clickbutton = btnDragon, panel = TreasurePanel, firstClick = FunctionFirstClickOpen.dragon, openLevel = FunctionOpenLevel.dragon, prompt = LANG_menuPanel_11 } );    --巨龙宝库
  table.insert( self.functionMap, { brush = btnStarMap.NormalBrush, effectbutton = btnStarMap, clickbutton = btnStarMap, panel = StarMapPanel, firstClick = FunctionFirstClickOpen.starMap, openLevel = FunctionOpenLevel.starMap, prompt = LANG_menuPanel_12 } );  --星魂
  table.insert( self.functionMap, { brush = btnRune.NormalBrush, effectbutton = btnRune, clickbutton = btnRune, panel = RunePanel, firstClick = FunctionFirstClickOpen.rune, openLevel = FunctionOpenLevel.rune, prompt = LANG_menuPanel_13 } );    --符文
  table.insert( self.functionMap, { brush = btnGem.NormalBrush, effectbutton = btnGem, clickbutton = btnGem, panel = GemPanel, firstClick = FunctionFirstClickOpen.gem, openLevel = FunctionOpenLevel.gem, prompt = LANG_menuPanel_14 } );    --宝石
  table.insert( self.functionMap, { brush = btnRoleAdvance.NormalBrush, effectbutton = btnRoleAdvance, clickbutton = btnRoleAdvance, panel = RoleAdvancePanel, firstClick = FunctionFirstClickOpen.roleadvance, openLevel = FunctionOpenLevel.roleadvance, prompt = LANG_menuPanel_15 } );    --人物升星
  table.insert( self.functionMap, { brush = btnRefine.NormalBrush, effectbutton = btnRefine, clickbutton = btnRefine, panel = RoleRefinementPanel, firstClick = FunctionFirstClickOpen.refine, openLevel =FunctionOpenLevel.refine, prompt = LANG_menuPanel_16 } );    --潜力
  table.insert( self.functionMap, { brush = btnMiku.NormalBrush, effectbutton = btnMiku, clickbutton = btnMiku, panel = RoleRefinementPanel, firstClick = FunctionFirstClickOpen.miku, openLevel =FunctionOpenLevel.miku, prompt = LANG_menuPanel_17 } );    --迷窟
  table.insert( self.functionMap, { brush = btnLimitround.NormalBrush, effectbutton = btnLimitround, clickbutton = btnLimitround, panel = PropertyRoundPanel, firstClick = FunctionFirstClickOpen.limitround, openLevel = FunctionOpenLevel.limitround, prompt = LANG_menuPanel_19 } );    --限时副本
  table.insert( self.functionMap, { brush = btnWing.NormalBrush, effectbutton = btnWing, clickbutton = btnWing, panel = PropertyRoundPanel, firstClick = FunctionFirstClickOpen.wing, openLevel = FunctionOpenLevel.wing, prompt = LANG_menuPanel_20 } );    --翅膀

  --按等级排序功能开启
  local function compareFunctionPT( funcPoint1, funcPoint2 )
    if funcPoint1.openLevel ~= funcPoint2.openLevel then
      return funcPoint1.openLevel < funcPoint2.openLevel;
    end

    return funcPoint1.firstClick < funcPoint2.firstClick;
  end

  table.sort(self.functionMap, compareFunctionPT);

end

function MenuPanel:isShowFeedbackPanel()
   if ActorManager.user_data.extra_data.isSend == 0 and ActorManager.user_data.round.roundid >= 1010 then
        feedbackBtn.Visibility = Visibility.Visible;
    else
        feedbackBtn.Visibility = Visibility.Hidden;
   end
end
function MenuPanel:showPveArmature()
  pveArmature.Visibility = Visibility.Visible
end

function MenuPanel:hidePveArmature()
  pveArmature.Visibility = Visibility.Hidden
end

function MenuPanel:LeftMenuPanelInit()
  LeftMenuPanel = mainDesktop:GetLogicChild('LefttMenuPanel')
  LeftMenuPanel.Visibility = Visibility.Visible;
  lftMenuPanel = LeftMenuPanel:GetLogicChild('menuPanel');
  --聊天
  local chatBtn = lftMenuPanel:GetLogicChild('chatPanel'):GetLogicChild('chat');
  chatBtn:SubscribeScriptedEvent('Button::ClickEvent', 'MainUI:onChat');
  chatBtn.Visibility = Visibility.Visible;
  lftMenuPanel:GetLogicChild('chatPanel').Visibility = Visibility.Visible;
  --好友
  local friendBtn = lftMenuPanel:GetLogicChild('FriendsPanel'):GetLogicChild('friends');
  friendBtn:SubscribeScriptedEvent('Button::ClickEvent', 'FriendListPanel:Show');
  friendBtn.Visibility = Visibility.Visible;
  --邮件
  local mailBtn = lftMenuPanel:GetLogicChild('emailPanel'):GetLogicChild('email');
  mailBtn:SubscribeScriptedEvent('Button::ClickEvent', 'EmailPanel:onRequestEmail');
  mailBtn.Visibility = Visibility.Visible;
  --排行榜
  local rankBtn = lftMenuPanel:GetLogicChild('rewardPanel'):GetLogicChild('reward');
  rankBtn:SubscribeScriptedEvent('Button::ClickEvent', 'RankPanel:ShowRankPanel');
  rankBtn.Visibility = Visibility.Visible;

  --signBtn = Button(LeftMenuPanel:GetLogicChild('signinPanel'):GetLogicChild('signinButton'));
  --signBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','DailySignPanel:reqSignInfo');

  local setBtn = lftMenuPanel:GetLogicChild('setPanel'):GetLogicChild('set');
  setBtn:SubscribeScriptedEvent('Button::ClickEvent', 'MenuPanel:onShowSettingPanel');

  controlBtn = LeftMenuPanel:GetLogicChild('controlBtn');
  controlBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent','MenuPanel:showLeftMenuPanel');
  controlImg = controlBtn:GetLogicChild('controlImg');

  showLeftmenuFlag = true;
  self:showLeftMenuPanel();

  LeftMenuPanel.chatBtn = chatBtn;
  LeftMenuPanel.friendBtn = friendBtn;
  LeftMenuPanel.mailBtn = mailBtn;
  LeftMenuPanel.rankBtn = rankBtn;
  LeftMenuPanel.setBtn = setBtn;
end

function MenuPanel:showLeftMenuPanel()
  if showLeftmenuFlag then
      controlImg:SetScale(-1,1);
      showLeftmenuFlag = false;
       --lftMenuPanel.Visibility = Visibility.Visible;
       -- LeftMenuPanel:SetUIStoryBoard("storyboard.leftMenuPanelIn");
       -- 适配
      --if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
        --LeftMenuPanel:SetUIStoryBoard("storyboard.leftMenuPanelInScale");
      --else
        LeftMenuPanel:SetUIStoryBoard("storyboard.leftMenuPanelIn");
      --end
  else
      controlImg:SetScale(1,1);
      showLeftmenuFlag = true;
      --lftMenuPanel.Visibility = Visibility.Hidden;
      -- LeftMenuPanel:SetUIStoryBoard("storyboard.leftMenuPanelOut");
      -- 适配
      --if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
      --  LeftMenuPanel:SetUIStoryBoard("storyboard.leftMenuPanelOutScale");
      --else
        LeftMenuPanel:SetUIStoryBoard("storyboard.leftMenuPanelOut");
      --end
  end
end

--签到提示更新  追加周礼包领取提示
function MenuPanel:UpdateSignTip(flag)
    RolePortraitPanel:UpdateSignTip(flag);
  --[[
	local effectBtn = LeftMenuPanel:GetLogicChild('signinPanel'):GetLogicChild('cricle')
   
    if  flag or WeekRewardPanel:isCanGetReward()  then
        effectBtn.Visibility =Visibility.Visible;
    else
        effectBtn.Visibility = Visibility.Hidden 
    end 
    ]]
end


function MenuPanel:onShowSettingPanel()
  MainUI:Push(SettingPanel);
end

--  竞技场可挑战时出城按钮显示特效
function MenuPanel:displayLeaveMainCityEffect()
  if armature then
    armature:Destroy()
  end
  -- armature = PlayEffect('fubenjiemian_output/', Rect(0,5, 5, 0), 'fubenjiemian',btnPve)
  -- armature.ZOrder = -10
end

function MenuPanel:removeEffectFromPveBtn()
  if armature then
    armature:Destroy()
  end
end

--销毁
function MenuPanel:Destroy()
  extentButton = nil;
  extentBrush = nil;
  firstButtonPanel:DecRefCount();
  firstButtonPanel = nil;
  secondButtonPanel:DecRefCount();
  secondButtonPanel = nil;
end

function MenuPanel:getUserGuideBtn()
  return btnHome;
end

function MenuPanel:getGuideCardBtn()
  return pubHeroBtn;
end
function MenuPanel:getUserGuideFriendBtn()
  return LeftMenuPanel:GetLogicChild('menuPanel'):GetLogicChild('FriendsPanel'):GetLogicChild('friends');
end
	

function MenuPanel:getGuideTaskBtn()
  return taskBtn;
end

function MenuPanel:getGuideCardPanel()
  return RightMenuPanel:GetLogicChild('recruitPanel');
end

function MenuPanel:getUserGuideTaskBtn(  )
  return btnPve
end

function MenuPanel:getBtnDungeons()
	return btnPve; 
end

function MenuPanel:getEventPanel()
  return eventPanel;
end

--测试替换函数
function MenuPanel:Ceshi(Args)
  Toast:MakeToast(Toast.TimeLength_Long, '功能暂未开放,敬请期待');
end

--card event 进入函数
function MenuPanel:EventCard()
  CardEventPanel:enterCardEvent();
	--CardEventPanel:onShow()
end

function MenuPanel:UpdateEventPanel()
	if not CardEvent:is_close() then
		eventPanel:GetLogicChild('brush').Background = CreateTextureBrush('card_event/event_entrance_in.ccz', 'card_event');
	else
		eventPanel:GetLogicChild('brush').Background = CreateTextureBrush('card_event/event_entrance_out.ccz', 'card_event');
	end

end

--任务初始化完成后，初始化显示菜单
function MenuPanel:InitMenu()
  local taskid = Task:getMainTaskId();
  local hero = ActorManager.hero;
  local level = hero:GetLevel();

  --=========================================================================
  --需要用新手引导步骤判定的

  --if taskid > SystemTaskId.strength or (taskid == SystemTaskId.strength and ActorManager:IsGuidStepDone(GuideStep.strength)) then
  if false then
    btnStrength.Visibility = Visibility.Visible;
  else
    btnStrength.Visibility = Visibility.Hidden;
  end
--[[
  if taskid > SystemTaskId.team or (taskid == SystemTaskId.team and ActorManager:IsGuidStepDone(GuideStep.team)) then
    btnTeam.Visibility = Visibility.Visible;
  else
    btnTeam.Visibility = Visibility.Hidden;
  end

  if taskid > SystemTaskId.pub or (taskid == SystemTaskId.pub and ActorManager:IsGuidStepDone(GuideStep.pub)) then
    btnPub.Visibility = Visibility.Visible;
  else
    btnPub.Visibility = Visibility.Hidden;
  end

  if taskid >= SystemTaskId.elite or (taskid == SystemTaskId.elite and ActorManager:IsGuidStepDone(GuideStep.elite)) then
    btnElite.Visibility = Visibility.Visible;
  else
    btnElite.Visibility = Visibility.Hidden;
  end--]]

  --=========================================================================
  --功能开放
  --抽卡
  if ActorManager.user_data.userguide.isnew >= UserGuideIndex.card then
	  RightMenuPanel:GetLogicChild('recruitPanel').Visibility = Visibility.Visible;
  else
	  RightMenuPanel:GetLogicChild('recruitPanel').Visibility = Visibility.Hidden;
  end
--[[
  --每日任务
  if ActorManager.user_data.userguide.isnew >= UserGuideIndex.dailytask then
	  taskBtn.Visibility = Visibility.Visible;
  else
	  taskBtn.Visibility = Visibility.Hidden;
  end
--]]
  --好友
  if taskid > MenuOpenLevel.guidEnd then
    btnFriend.Visibility = Visibility.Visible;
  else
    btnFriend.Visibility = Visibility.Hidden;
  end

  --竞技场
  if level >= FunctionOpenLevel.arena then
    btnArena.Visibility = Visibility.Visible;
  else
    btnArena.Visibility = Visibility.Hidden;
  end

  --试练
  if level >= FunctionOpenLevel.trial then
    btnTrial.Visibility = Visibility.Visible;
  else
    btnTrial.Visibility = Visibility.Hidden;
  end

  --技能
  if level >= FunctionOpenLevel.skill then
    btnSkill.Visibility = Visibility.Visible;
  else
    btnSkill.Visibility = Visibility.Hidden;
  end

  --十二宫
  if level >= FunctionOpenLevel.zodiac then
    btnZodiac.Visibility = Visibility.Visible;
  else
    btnZodiac.Visibility = Visibility.Hidden;
  end

  --训练场
  --[[
  if level >= FunctionOpenLevel.train then
    btnTrain.Visibility = Visibility.Visible;
  else
    btnTrain.Visibility = Visibility.Hidden;
  end
  --]]

  --公会
  if level >= FunctionOpenLevel.union then
    RightMenuPanel:GetLogicChild('unionPanel').Visibility = Visibility.Visible;
  else
    RightMenuPanel:GetLogicChild('unionPanel').Visibility = Visibility.Hidden;
  end

  --巨龙宝库
  if level >= FunctionOpenLevel.dragon then
    btnDragon.Visibility = Visibility.Visible;
  else
    btnDragon.Visibility = Visibility.Hidden;
  end

  --星魂
  if level >= FunctionOpenLevel.starMap then
    btnStarMap.Visibility = Visibility.Visible;
  else
    btnStarMap.Visibility = Visibility.Hidden;
  end

  --宝石
  if level >= FunctionOpenLevel.gem then
    btnGem.Visibility = Visibility.Visible;
  else
    btnGem.Visibility = Visibility.Hidden;
  end

  --升星
  if level >= FunctionOpenLevel.roleadvance then
    btnRoleAdvance.Visibility = Visibility.Visible;
  else
    btnRoleAdvance.Visibility = Visibility.Hidden;
  end

  --潜力
  if level >= FunctionOpenLevel.refine then
  --  btnRefine.Visibility = Visibility.Visible;
  else
  --  btnRefine.Visibility = Visibility.Hidden;
  end

  --迷窟
  if level >= FunctionOpenLevel.miku then
    btnMiku.Visibility = Visibility.Visible;
  else
    btnMiku.Visibility = Visibility.Hidden;
  end

  --限时副本
  if level >= FunctionOpenLevel.limitround then
    btnLimitround.Visibility = Visibility.Visible;
  else
    btnLimitround.Visibility = Visibility.Hidden;
  end

  --翅膀
  if level >= FunctionOpenLevel.wing then
    btnWing.Visibility = Visibility.Visible;
  else
    btnWing.Visibility = Visibility.Hidden;
  end

  --=========================================================================
  --合并按钮开放

  if taskid >= MenuOpenLevel.openMerge then
  else
  end

  --刷新剩余次数提示
  self:InitLeftCountList(level);

end

--打开菜单
function MenuPanel:openMenu()
  --先让菜单打开
  MenuPanel:moveIn();
  --添加遮罩，防止点击
  UserGuidePanel:ShowNewFeatureShade();
  --等待一段时间开启遮罩
  refreshTimer = timerManager:CreateTimer(0.5, 'MenuPanel:openNewMenuShade', 0);
end

--开启新菜单遮罩
function MenuPanel:openNewMenuShade()

  if 0 ~= refreshTimer then
    timerManager:DestroyTimer(refreshTimer);
    refreshTimer = 0;
  end

  --标示下需要遮罩，在具体功能中使用
  UserGuidePanel:SetInGuiding(true);

  if curMenu ~= nil then
    curMenu.Visibility = Visibility.Visible;
  end
  --先关闭所有模式对话框
  MainUI:PopAll();

  --显示点击指定菜单提示
  UserGuidePanel:ShowGuideShade(curMenu, GuideEffectType.arrow, GuideTipPos.left, LANG_menuPanel_18);

end

--获取新开启按钮的位置
function MenuPanel:getNewMenuPos()
  if not curMenu:IsVisible() then
    curMenu.Visibility = Visibility.Collapsed;
  end

  firstButtonPanel:ForceLayout();
  topPanel:ForceLayout();
  bottomPanel:ForceLayout();
  secondButtonPanel:ForceLayout();
  local targetPos = Vector2(curMenu:GetAbsTranslate().x - mainDesktop.Width/2 + curMenu.Width*0.50, curMenu:GetAbsTranslate().y - mainDesktop.Height/2 + curMenu.Height*0.50);
  return targetPos;
end

--显示公会特效
function MenuPanel:ShowUnionButtonEffect()
    if (nil == unionButtonEffect) then
        unionButtonEffect = uiSystem:CreateControl('ArmatureUI');
        unionButtonEffect:LoadArmature('shouchong');
        unionButtonEffect:SetAnimation('play');
        unionButtonEffect.Margin = Rect(53, 41, 0, 0);
        btnUnion:AddChild(unionButtonEffect);
    end
end

--隐藏公会按钮特效
function MenuPanel:HideUnionButtonEffect()
    if (nil ~= unionButtonEffect) then
        btnUnion:RemoveChild(unionButtonEffect);
        unionButtonEffect = nil;
    end
end

--动画移入
function MenuPanel:moveIn()
  if not isMoveOut then
    return;
  end

  firstButtonPanel.Visibility = Visibility.Visible;
  secondButtonPanel.Visibility = Visibility.Visible;
  isMoveOut = false;
  extentButton.Storyboard = 'storyboard.moveIn';
  firstButtonPanel.Storyboard = 'storyboard.moveIn_1';
  secondButtonPanel.Storyboard = 'storyboard.moveIn_2';
  extentMergeOne.Visibility = Visibility.Hidden;
  extentMergeTwo.Visibility = Visibility.Hidden;

  MainUI:HideLetter();
end

--动画移出
function MenuPanel:moveOut()
  if isMoveOut then
    return;
  end

  firstButtonPanel.Visibility = Visibility.Visible;
  secondButtonPanel.Visibility = Visibility.Hidden;
  isMoveOut = true;
  extentButton.Storyboard = 'storyboard.moveOut';
  firstButtonPanel.Storyboard = 'storyboard.moveOut_1';
  secondButtonPanel.Storyboard = 'storyboard.moveOut_2';

  MainUI:ShowLetter();
end

--扩展按钮按下
function MenuPanel:onExtentClick()
end

function MenuPanel:onExtentClickOne()
  MainUI:Push(subLevelMenuPanel);
end

function MenuPanel:onExtentClickTwo()
end

function MenuPanel:onCloseSubMenu()
  MainUI:Pop();
end

--菜单收回，打开聊天
function MenuPanel:onMenuOut()
  local taskid = Task:getMainTaskId();
  if not isMoveOut and taskid >= MenuOpenLevel.normalTask then
    self:moveOut();
  end
end

--显示菜单相关UI
function MenuPanel:onShowMenu()
  extentButton.Visibility = Visibility.Visible;
  extentBrush.Visibility = Visibility.Visible;

end

--隐藏菜单相关UI
function MenuPanel:onHideMenu()
  self:moveOut();
  extentButton.Visibility = Visibility.Hidden;
  extentBrush.Visibility = Visibility.Hidden;
  firstButtonPanel.Visibility = Visibility.Hidden;
  secondButtonPanel.Visibility = Visibility.Hidden;
end

--返回队伍按钮
function MenuPanel:getBtnTeam()
  return btnTeam;
end

--初始化剩余次数列表的初始次数
function MenuPanel:InitLeftCountList( level )
  self.leftCountList.task = {};      --日常任务
  self.leftCountList.arena = {};      --竞技场挑战
  self.leftCountList.trial = {};      --试炼
  self.leftCountList.union = {};      --公会申请和祭祀
  self.leftCountList.friend = {};      --好友申请
  self.leftCountList.chat = {};      --私聊
  self.leftCountList.strength = {};    --装备升阶
  self.leftCountList.bag = {};      --背包
  self.leftCountList.dragonTreasure = {};  --巨龙宝库剩余抢劫次数
  self.leftCountList.roleadvance = {};  --人物升星
  self.leftCountList.team = {};      --队伍界面
  self.leftCountList.pub = {};      --英灵殿
  self.leftCountList.limitround = {};    --限时副本
  self.leftCountList.wing = {};      --翅膀

  self.leftCountList.task.label = btnTask:GetLogicChild('leftCountLabel');
  self.leftCountList.arena.label = btnArena:GetLogicChild('leftCountLabel');
  self.leftCountList.trial.label = btnTrial:GetLogicChild('leftCountLabel');
  self.leftCountList.union.label = btnUnion:GetLogicChild('leftCountLabel');
  self.leftCountList.friend.label = btnFriend:GetLogicChild('leftCountLabel');
--  self.leftCountList.chat.label = mainDesktop:GetLogicChild('liaoTianPanel'):GetLogicChild('leftCountLabel');
  self.leftCountList.chat.label = mainDesktop:GetLogicChild('LefttMenuPanel'):GetLogicChild('menuPanel'):GetLogicChild('chatPanel'):GetLogicChild('cricle');
  self.leftCountList.bag.label = btnBag:GetLogicChild('leftCountLabel');
  self.leftCountList.dragonTreasure.label = btnDragon:GetLogicChild('leftCountLabel');
  self.leftCountList.roleadvance.label = btnRoleAdvance:GetLogicChild('leftCountLabel');
  self.leftCountList.team.label = btnTeam:GetLogicChild('leftCountLabel');
  self.leftCountList.pub.label = btnPub:GetLogicChild('leftCountLabel');
  self.leftCountList.limitround.label = btnLimitround:GetLogicChild('leftCountLabel');
  self.leftCountList.wing.label = btnWing:GetLogicChild('leftCountLabel');

  --根据任务决定使用哪个
  if taskid < MenuOpenLevel.openMerge then
    self.leftCountList.strength.label = btnStrength:GetLogicChild('leftCountLabel');
  else
    self.leftCountList.strength.label = btnMergeStrength:GetLogicChild('leftCountLabel');
  end

  self.leftCountList.task.leftCount = 0;
  self.leftCountList.arena.leftCount = ActorManager.user_data.counts.n_pvp;
  self.leftCountList.trial.leftCount = ActorManager.user_data.counts.n_trial;
  self.leftCountList.union.leftCount = ActorManager.user_data.counts.n_pray + ActorManager.user_data.counts.n_gang_req;
  self.leftCountList.friend.leftCount = ActorManager.user_data.counts.n_friend;
  self.leftCountList.chat.leftCount = 0;
  self.leftCountList.strength.leftCount = 0;
  self.leftCountList.bag.leftCount = Package:GetPackageCount();
  self.leftCountList.dragonTreasure.leftCount = Configuration.TreasureRobMaxCount - ActorManager.user_data.round.n_rob;
  self.leftCountList.roleadvance.leftCount = RoleAdvancePanel:GetAdvanceRoleCount();
  self.leftCountList.team.leftCount = 0;
  --self.leftCountList.team.leftCount = TeamOrderPanel:GetEmptyPositionCount();
  self.leftCountList.limitround.leftCount = PropertyRoundPanel:GetPropertyRoundNum();

  UnionAlterPanel:SetLeftTime(ActorManager.user_data.counts.n_pray);
  UnionApplyPanel:SetApplyCount(ActorManager.user_data.counts.n_gang_req);
  UnionMemberPanel:RefreshApplyCountLabel(ActorManager.user_data.counts.n_gang_req);
  UnionPanel:RefreshUnionCountLabel(self.leftCountList.union.leftCount);
  UnionPanel:RefreshApplyCountLabel(ActorManager.user_data.counts.n_gang_req);
  UnionPanel:RefreshAlterCountLabel(ActorManager.user_data.counts.n_pray);

  self:RefreshTotalLeftCount();
end

--刷新次数显示
function MenuPanel:RefreshTotalLeftCount()
  for k,item in pairs(self.leftCountList) do
  end
end

--=============================================================================================
--功能开启
--=============================================================================================

--功能点点击了（返回值 true表示当次开放，false表示当次没有开放）
function MenuPanel:FunctionClick( firstClick )
  local hero = ActorManager.hero;

  if hero:IsFunctionFirstClick(firstClick) then
    for _, func in ipairs(self.functionMap) do
      if firstClick == func.firstClick then
        local msg = {};
        msg.func = hero:SetFunctionFirstClick(firstClick);
        Network:Send(NetworkCmdType.nt_function_t, msg, true);

        if func.effectbutton.kaifang ~= nil then
          func.effectbutton:RemoveChild(func.effectbutton.kaifang);
          func.effectbutton.kaifang = nil;
        end

        break;
      end
    end

    UserGuidePanel:SetInGuiding(true);
    return true;
  end

  return false;
end

--世界BOSS隐藏部分按钮 只显示聊天
function MenuPanel:onLeaveChatPanel()
  RightMenuPanel.Visibility = Visibility.Hidden;
  LeftMenuPanel.Visibility = Visibility.Visible;
  LeftMenuPanel.chatBtn.Visibility = Visibility.Visible;
  LeftMenuPanel.friendBtn.Visibility = Visibility.Hidden;
  LeftMenuPanel.mailBtn.Visibility = Visibility.Hidden;
  LeftMenuPanel.rankBtn.Visibility = Visibility.Hidden;
  LeftMenuPanel.setBtn.Visibility = Visibility.Hidden;
  --adPanel.Visibility = Visibility.Hidden;
  showPanel.Visibility = Visibility.Hidden;
  feedbackBtn.Visibility = Visibility.Hidden;
end
-- 从世界boss场景返回主界面
function MenuPanel:onRecover()
  RightMenuPanel.Visibility = Visibility.Visible;
  LeftMenuPanel.Visibility = Visibility.Visible;
  LeftMenuPanel.chatBtn.Visibility = Visibility.Visible;
  LeftMenuPanel.friendBtn.Visibility = Visibility.Visible;
  LeftMenuPanel.mailBtn.Visibility = Visibility.Visible;
  LeftMenuPanel.rankBtn.Visibility = Visibility.Visible;
  LeftMenuPanel.setBtn.Visibility = Visibility.Visible;
  --adPanel.Visibility = Visibility.Visible;
  showPanel.Visibility = Visibility.Visible;
   self:isShowFeedbackPanel();
end
-- circle begin (小圆点)
function MenuPanel:TaskTipsShow()
  if ActorManager.user_data.userguide.isnew >= UserGuideIndex.dailytask then
	  RightMenuPanel:GetLogicChild('taskPanel'):GetLogicChild('cricle').Visibility = Visibility.Visible;
  end
end

function MenuPanel:TaskTipsHide()
  RightMenuPanel:GetLogicChild('taskPanel'):GetLogicChild('cricle').Visibility = Visibility.Hidden;
end

function MenuPanel:HomeTips(visable)
	RightMenuPanel:GetLogicChild('homebutton'):GetLogicChild('cricle').Visibility
	= visable and Visibility.Visible or Visibility.Hidden;
end

function MenuPanel:ZhaomuTip(visable)
	if ActorManager.user_data.userguide.isnew >= UserGuideIndex.card then
	  RightMenuPanel:GetLogicChild('recruitPanel'):GetLogicChild('cricle').Visibility 
	= visable and Visibility.Visible or Visibility.Hidden
	end
end
function MenuPanel:UnionTip(visible)
	RightMenuPanel:GetLogicChild('unionPanel'):GetLogicChild('cricle').Visibility 
	= visible and Visibility.Visible or Visibility.Hidden
end
function MenuPanel:FriendTip(visable)
	LeftMenuPanel:GetLogicChild('menuPanel'):GetLogicChild('FriendsPanel'):GetLogicChild('cricle').Visibility = visable and Visibility.Visible or Visibility.Hidden
end
function MenuPanel:ChatTip(visable)
  mainDesktop:GetLogicChild('LefttMenuPanel'):GetLogicChild('menuPanel'):GetLogicChild('chatPanel'):GetLogicChild('cricle').Visibility = visable and Visibility.Visible or Visibility.Hidden;
end
-- circle end
function MenuPanel:UpdateFriendTip()
	--print("isHaveAcceptFlower-->"..tostring(self.isHaveAcceptFlower).."--isCanSendFlower-->"..tostring(self.isCanSendFlower).."--isHaveFriend-->"..tostring(self.isHaveFriend))
	if (self.isHaveAcceptFlower or self.isCanSendFlower or self.isHaveFriend) and ActorManager.user_data.role.lvl.level >= FunctionOpenLevel.friendlist then
		self:FriendTip(true)
	else
		self:FriendTip(false)
	end
	
end
function MenuPanel:Hide()
  RightMenuPanel.Visibility = Visibility.Hidden;
  --adPanel.Visibility = Visibility.Hidden;
  showPanel.Visibility = Visibility.Hidden;
  LeftMenuPanel.Visibility = Visibility.Hidden
  feedbackBtn.Visibility = Visibility.Hidden;
end

function MenuPanel:onShow()
  RightMenuPanel.Visibility = Visibility.Visible;
  --adPanel.Visibility = Visibility.Visible;
  showPanel.Visibility = Visibility.Visible;
  LeftMenuPanel.Visibility = Visibility.Visible;
  self:isShowFeedbackPanel();
end

function MenuPanel:clickFeedBack()
	local okDelegate = Delegate.new(MenuPanel, MenuPanel.sendMessage, 0);
	local str = LANG_Vip_tip_7;
	MessageBox:ShowDialog(MessageBoxType.OkCancel, str, okDelegate);
end

function MenuPanel:sendMessage()
    local msg = {};
	msg.type = 1;
   	msg.id = 1;
   	msg.msg = '';
   	msg.name = ActorManager.user_data.name;
   	msg.vipLevel = ActorManager.user_data.viplevel;
   	Network:Send(NetworkCmdType.nt_chart, msg);

	if platformSDK.m_System == "iOS" then
		appFramework:OpenUrl('https://itunes.apple.com/us/app/wu-zhuang-bai-ji/id1152293459?l=ja&ls=1&mt=8');
	elseif platformSDK.m_System == "Android" then
		platformSDK:GetExtraInfo("url", "https://play.google.com/store/apps/details?id=nz.co.qmax.erika");
	end
end

