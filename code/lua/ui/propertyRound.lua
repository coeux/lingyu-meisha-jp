--propertyRound.lua
PropertyRoundPanel =
{
  showPropertyTeam = false;
  curProperty = 0;
  preProperty = 0;
  refreshAt24Flag = false;
  max_round = 3;
};

--控件
local mainDesktop;
local panel;
local topPanel;
local leftPanel;
local leftImg;
local leftBtn;
local rightPanel;
local rightImg;
local rightBtn;
local roundPanel;
local lblTitle;
local listView;
local illustrationPanel;
local lblContent;
local infoPanel;
local shader;
local oPanel;
local backBtn;
local resetBtn;

local explainPanel
local explainBtn
local remainTimesLabel
local consumeAP
local cdTime
local cdLabel
local content
local bg
local touchScrollPanel
local touchHScrollBar
local stackPanel

--变量
local roundTimer;
local reqRoundId;
local difficultList = {};
local scrollCount; -- 滚动个数
local totalTimes;

local itemList = {}
local itemCount = 1
local isOnFight = false
local isGuideReturn = false
local isChooseLeft = false
local isClickBackBtn = false

function PropertyRoundPanel:InitPanel(desktop)
  roundTimer = 0;
  scrollCount = nil;
  difficultList = {};
  self.refreshAt24Flag = false;
  self.max_round = 3;

  mainDesktop = desktop;
  panel = Panel(desktop:GetLogicChild('propertyRoundPanel'));
  panel.Visibility = Visibility.Hidden;
  panel:IncRefCount();
  panel.ZOrder = PanelZOrder.property;

  topPanel          = panel:GetLogicChild('topPanel');
  leftPanel         = panel:GetLogicChild('leftPanel');
  leftImg           = leftPanel:GetLogicChild('img');
  leftBtn           = leftPanel:GetLogicChild('fight');
  rightPanel        = panel:GetLogicChild('rightPanel');
  rightImg          = rightPanel:GetLogicChild('img');
  rightBtn          = rightPanel:GetLogicChild('fight');
  roundPanel        = panel:GetLogicChild('diff');
  roundPanel.Visibility = Visibility.Hidden;
  lblTitle          = roundPanel:GetLogicChild('title');
  listView           = roundPanel:GetLogicChild('listView');
  touchScrollPanel  = roundPanel:GetLogicChild('touchScroll')
  touchHScrollBar   = touchScrollPanel:GetInnerHScrollBar()
  stackPanel        = touchScrollPanel:GetLogicChild('stackPanel')
  shader             = panel:GetLogicChild('shader');
 

  infoPanel         = panel:GetLogicChild('infoPanel');
  totalTimes		= infoPanel:GetLogicChild('totalTimes');
  consumeAP         = infoPanel:GetLogicChild('consumeAP')
  consumeAP.Visibility = Visibility.Visible
  remainTimesLabel  = infoPanel:GetLogicChild('remainTimes')
  cdLabel           = infoPanel:GetLogicChild('cdLabel')
  cdLabel.Visibility = Visibility.Hidden
  cdTime             = infoPanel:GetLogicChild('cdTime')
  cdTime.Visibility = Visibility.Hidden
  resetBtn          = infoPanel:GetLogicChild('resetButton');
  resetBtn:SubscribeScriptedEvent('Button::ClickEvent','PropertyRoundPanel:resetBtnClick');

  explainBtn        = panel:GetLogicChild('explainBtn')
  explainBtn:SubscribeScriptedEvent('Button::ClickEvent','PropertyRoundPanel:showExplainPanel')
  bg                = panel:GetLogicChild('explainBG')
  bg.Visibility = Visibility.Hidden
  bg:SubscribeScriptedEvent('UIControl::MouseClickEvent','PropertyRoundPanel:closeExplainPanel')
  explainPanel      = panel:GetLogicChild('explain')
  explainPanel.Visibility = Visibility.Hidden
  content           = explainPanel:GetLogicChild('content'):GetLogicChild('explainLabel')
  content.Text = LANG_property_explain
  oPanel             = explainPanel:GetLogicChild('o'):GetLogicChild('ig');
  panel:GetLogicChild('returnBtn'):RemoveAllEventHandler();
  backBtn = panel:GetLogicChild('returnBtn')
  backBtn:SubscribeScriptedEvent('Button::ClickEvent', 'PropertyRoundPanel:onReturn');
  consumeAP.Text = ' 消費スタミナ： 6';
  panel:GetLogicChild('infoPanel'):GetLogicChild('tip').Text = 'スキル進化素材と鍛錬ポイントをゲット';
  self:initText();
end
function PropertyRoundPanel:resetBtnClick( Args ) 
  local okDelegate = Delegate.new(PropertyRoundPanel, PropertyRoundPanel.resetLimitRoundTimes, 0);
  MessageBox:ShowDialog(MessageBoxType.OkCancel,LANG_propertyRoundPanel_14, okDelegate);
end
function PropertyRoundPanel:resetLimitRoundTimes()
    Network:Send(NetworkCmdType.req_reset_limit_round,{});
end
function PropertyRoundPanel:retResetLimitRoundData()
    remainTimesLabel.Text = tostring(3);
    remainTimesLabel:SetFont('huakang_20_noborder');
end
function PropertyRoundPanel:showExplainPanel()
  explainPanel.Visibility = Visibility.Visible
  bg.Visibility = Visibility.Visible
end

function PropertyRoundPanel:closeExplainPanel()
  explainPanel.Visibility = Visibility.Hidden
  bg.Visibility = Visibility.Hidden
end

function PropertyRoundPanel:initText()
  panel:GetLogicChild('guizeshuoming'):GetLogicChild('shuoming1').Text = LANG_propertyRoundPanel_1;
  panel:GetLogicChild('guizeshuoming'):GetLogicChild('shuoming2').Text = LANG_propertyRoundPanel_2;
  panel:GetLogicChild('guizeshuoming'):GetLogicChild('shuoming3').Text = LANG_propertyRoundPanel_10;
end

function PropertyRoundPanel:Show()
  self.refreshAt24Flag = false;
  panel:GetLogicChild("bg").Background = CreateTextureBrush('background/default_bg.jpg', 'background')
  local img1 = resTableManager:GetValue(ResTable.limit_round, tostring(RoundIDSection.LimitRoundBegin + ActorManager.user_data.round.limit_open_round[1] * 10 + 1), 'img');
  local img2 = resTableManager:GetValue(ResTable.limit_round, tostring(RoundIDSection.LimitRoundBegin + ActorManager.user_data.round.limit_open_round[2] * 10 + 1), 'img');
  leftImg.Image = GetPicture('xianshifuben/' .. img1 .. ".ccz");
  rightImg.Image = GetPicture('xianshifuben/' .. img2 .. ".ccz");
  if ActorManager.user_data.round.limit_round_sec == 0 then
    consumeAP.Visibility = Visibility.Visible
    cdTime.Visibility = Visibility.Hidden
    cdLabel.Visibility = Visibility.Hidden
  elseif ActorManager.user_data.round.limit_round_sec > 0 then
    consumeAP.Visibility = Visibility.Hidden
    cdLabel.Visibility = Visibility.Visible
    cdTime.Visibility = Visibility.Visible
    cdTime.Text = Time2HMSStr(ActorManager.user_data.round.limit_round_sec or 0)
  end
  
  --local max_round = resTableManager:GetValue(ResTable.vip, tostring(ActorManager.user_data.viplevel), 'reset_trial') or 4;

  if ActorManager.user_data.round.limit_round_left then
    remainTimesLabel.Text = tostring(self.max_round - ActorManager.user_data.round.limit_round_left)
    if (self.max_round - ActorManager.user_data.round.limit_round_left) == 0 then
      remainTimesLabel:SetFont('huakang_16_miaobian_R232G37B74')
    end
  else
    remainTimesLabel.Text = tostring(0)
    remainTimesLabel:SetFont('huakang_16_miaobian_R232G37B74')
  end

  self:refresh();
  self:StartTimer();


  totalTimes.Text = '/3'--resTableManager:GetValue(ResTable.vip, tostring(ActorManager.user_data.viplevel), 'reset_trial') or 4;

  panel.Visibility = Visibility.Visible;
  --mainDesktop:DoModal(panel);
  StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
  --  新手引导
  if UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) then
    timerManager:CreateTimer(0.1, 'PropertyRoundPanel:onEnterUserGuilde', 0, true)
    isChooseLeft = true
  end
  --屏幕适配
  if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
    local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
    leftPanel:SetScale(factor,factor);
    rightPanel:SetScale(factor,factor);
    --间距也要相应的改变
    leftPanel.Translate = Vector2(250*(1-factor),0);
    rightPanel.Translate = Vector2(250*(factor-1),0);
    roundPanel:SetScale(factor,factor);
  end
end

function PropertyRoundPanel:refresh()
  local hash = {
    [1] = {
      ['icon'] = resTableManager:GetValue(ResTable.item, '14200', 'icon'),
      ['count'] = Package:GetItem(14200);
    },
    [2] = {
      ['icon'] = resTableManager:GetValue(ResTable.item, '14201', 'icon'),
      ['count'] = Package:GetItem(14201);
    },
    [3] = {
      ['icon'] = resTableManager:GetValue(ResTable.item, '14202', 'icon'),
      ['count'] = Package:GetItem(14202);
    },
    [4] = {
      ['icon'] = resTableManager:GetValue(ResTable.item, '14203', 'icon'),
      ['count'] = Package:GetItem(14203);
    },
    [5] = {
      ['icon'] = resTableManager:GetValue(ResTable.item, '14204', 'icon'),
      ['count'] = Package:GetItem(14204);
    },
    [6] = {
      ['icon'] = resTableManager:GetValue(ResTable.item, '15001', 'icon'),
      ['count'] = Package:GetItem(15001);
    },
  }
  for i = 1, 6 do
    local icon = oPanel:GetLogicChild(tostring(i)):GetLogicChild('icon');
    local count = oPanel:GetLogicChild(tostring(i)):GetLogicChild('count');
    icon.Image = GetIcon(hash[i]['icon']);
    count.Text = tostring(hash[i]['count'] and hash[i]['count'].num or 0);
  end
end

function PropertyRoundPanel:isShow()
  return panel.Visibility == Visibility.Visible
end

function PropertyRoundPanel:onShow()
	if ActorManager.hero:GetLevel() < FunctionOpenLevel.limitround then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_propertyRoundPanel_12); 
	else
		self:Show();
	end
    --MainUI:Push(self);
end

function PropertyRoundPanel:onDestroy()
  panel:GetLogicChild("bg").Background = nil;
  DestroyBrushAndImage('background/default_bg.jpg', 'background');
  StoryBoard:OnPopUI();
end

function PropertyRoundPanel:Hide()
  StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'PropertyRoundPanel:onDestroy');
end

function PropertyRoundPanel:onClose()
  self:onCloseFight();
  --roundPanel.Visibility = Visibility.Hidden;
  panel.Visibility = Visibility.Hidden;
  if 0 ~= roundTimer then
    timerManager:DestroyTimer(roundTimer);
    roundTimer = 0;
  end
  --MainUI:Pop();
end

function PropertyRoundPanel:Destroy()
  panel:DecRefCount();
  panel = nil;
end

function PropertyRoundPanel:StartTimer()
  if roundTimer == 0 then
    roundTimer = timerManager:CreateTimer(1.0, 'PropertyRoundPanel:onRefreshTime', 0);
  end
end

function PropertyRoundPanel:ReStartTimer()
  if roundTimer ~= 0 then
    timerManager:DestroyTimer(roundTimer);
    roundTimer = 0;
  end
  roundTimer = timerManager:CreateTimer(1.0, 'PropertyRoundPanel:onRefreshTime', 0);
end

function PropertyRoundPanel:onRefreshTime()
  if ActorManager.user_data.round.limit_round_sec == 0 then
    consumeAP.Visibility = Visibility.Visible
    cdLabel.Visibility = Visibility.Hidden
    cdTime.Visibility = Visibility.Hidden
    return;
  end

  if ActorManager.user_data.round.limit_round_sec > 0 then
    ActorManager.user_data.round.limit_round_sec = ActorManager.user_data.round.limit_round_sec - 1;
    consumeAP.Visibility = Visibility.Hidden
    cdLabel.Visibility = Visibility.Visible
    cdTime.Visibility = Visibility.Visible
    cdTime.Text = Time2HMSStr(ActorManager.user_data.round.limit_round_sec or 0)
  else
    if 0 ~= roundTimer then
      timerManager:DestroyTimer(roundTimer);
      roundTimer = 0;
    end
  end
end

function PropertyRoundPanel:onIllustrate()
  illustrationPanel.Visibility = Visibility.Visible;
  self:ShowShader();
end

function PropertyRoundPanel:onReturn()
  isClickBackBtn = true
  self:onClose();
end

function PropertyRoundPanel:onCloseFight()
  roundPanel.Visibility = Visibility.Hidden;
  shader.Visibility = Visibility.Hidden;
  -- 
  if UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and not isClickBackBtn then
    isGuideReturn = true
    timerManager:CreateTimer(0.1, 'PropertyRoundPanel:onEnterUserGuilde', 0, true)
  end
  if UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and isClickBackBtn then
    timerManager:CreateTimer(0.1, 'PropertyRoundPanel:onEnterUserGuilde', 0, true)
  end
end

function PropertyRoundPanel:initIconGrid(ig)
  ig.CellHeight = 280;
  ig.CellWidth = 240;
  ig.CellHSpace = 15;
  ig.Size = Size(750,300);
end

function PropertyRoundPanel:onFight(Args)
	--local max_round = resTableManager:GetValue(ResTable.vip, tostring(ActorManager.user_data.viplevel), 'reset_trial') or 4;
  if (self.max_round - ActorManager.user_data.round.limit_round_left) <= 0 and ActorManager.user_data.round.limit_round_reset_times <= 0 then
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG__51);
    return;
  elseif (self.max_round - ActorManager.user_data.round.limit_round_left) <= 0 
    and ActorManager.user_data.round.limit_round_reset_times > 0 then
      local contents = {};
      table.insert(contents,{cType = MessageContentType.Text; text = LANG_propertyRoundPanel_16})
      table.insert(contents,{cType = MessageContentType.Text; text = LANG_propertyRoundPanel_17})
    local okdelegate = Delegate.new(PropertyRoundPanel,PropertyRoundPanel.resetLimitRoundTimes,0);
    MessageBox:ShowDialog(MessageBoxType.OkCancel, contents,okdelegate);
    return;
  elseif ActorManager.user_data.round.limit_round_sec ~= 0 then
	  local level = resTableManager:GetValue(ResTable.vip_open, '31', 'viplv');
	  if ActorManager.user_data.viplevel >= level then
		local okDelegate = Delegate.new(NetworkMsg_LimitRound, NetworkMsg_LimitRound.req_clearCD, 0);
		MessageBox:ShowDialog(MessageBoxType.OkCancel, {[1]=LANG__52, [2]=LANG__121}, okDelegate);
	  else
		  MessageBox:ShowDialog(MessageBoxType.Ok, {[1]=LANG__122, [2]=string.format(LANG__123,level)});
	  end
    return;
  end
  shader.Visibility = Visibility.Visible;
  local args = UIControlEventArgs(Args);
  roundPanel.Visibility = Visibility.Visible;

  local base;
  if args.m_pControl.Tag == 1 then
    base = RoundIDSection.LimitRoundBegin + ActorManager.user_data.round.limit_open_round[1] * 10;
  elseif args.m_pControl.Tag == 2 then
    base = RoundIDSection.LimitRoundBegin + ActorManager.user_data.round.limit_open_round[2] * 10;
  end
  stackPanel:RemoveAllChildren()
  for index = 1, 5 do
    local it = customUserControl.new(stackPanel, 'propertyRoundTemplate');
    it.initWithId(base + index)
    itemList[itemCount] = it
    itemCount = itemCount + 1
  end

  -- local fillListView = function(b, e)
  --   local iconGrid = uiSystem:CreateControl('IconGrid');
  --   self:initIconGrid(iconGrid);
  --   for i = b, e do
  --     local it = customUserControl.new(iconGrid, 'propertyRoundTemplate');
  --     it.initWithId(base + i);
  --     itemList[itemCount] = it
  --     itemCount = itemCount + 1
  --   end
  --   listView:AddChild(iconGrid);
  -- end

  -- listView:RemoveAllChildren();
  -- fillListView(1, 3);
  -- fillListView(4, 5);

  local data = resTableManager:GetValue(ResTable.limit_round, tostring(base + 1), {'name'});
  lblTitle.Text = data['name'];
  --  开启第二个手势
  if UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) then
    isOnFight = true
    timerManager:CreateTimer(0.1, 'PropertyRoundPanel:onEnterUserGuilde', 0, true)
  end
end

function PropertyRoundPanel:onReqFight(Args)
	print(370)
	--local max_round = resTableManager:GetValue(ResTable.vip, tostring(ActorManager.user_data.viplevel), 'reset_trial') or 4;
  local args = UIControlEventArgs(Args);
  local roundId = args.m_pControl.Tag;
  local needPower = resTableManager:GetValue(ResTable.limit_round, tostring(roundId), 'power');

  if ActorManager.user_data.power < needPower then
    BuyCountPanel:ApplyData(VipBuyType.vop_buy_power);
    BuyCountPanel:SetTitle(LANG_propertyRoundPanel_3);
  elseif (self.max_round - ActorManager.user_data.round.limit_round_left) <= 0 and ActorManager.user_data.round.limit_round_reset_times <= 0 then
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG__51);
  elseif (self.max_round - ActorManager.user_data.round.limit_round_left) <= 0 
    and ActorManager.user_data.round.limit_round_reset_times > 0 then
      local contents = {};
      table.insert(contents,{cType = MessageContentType.Text; text = LANG_propertyRoundPanel_16})
      table.insert(contents,{cType = MessageContentType.Text; text = LANG_propertyRoundPanel_17})
    local okdelegate = Delegate.new(PropertyRoundPanel,PropertyRoundPanel.resetLimitRoundTimes,0);
    MessageBox:ShowDialog(MessageBoxType.OkCancel, contents,okdelegate);
    return;
  elseif ActorManager.user_data.round.limit_round_sec ~= 0 then
	  local okDelegate = Delegate.new(NetworkMsg_LimitRound, NetworkMsg_LimitRound.req_clearCD, 0);
	  MessageBox:ShowDialog(MessageBoxType.OkCancel, {LANG__52, LANG__121}, okDelegate);
  else
    local property = (roundId - RoundIDSection.LimitRoundBegin)/10;
    local property = property - property % 1;

    if self.preProperty ~= property then
      self.preProperty = property;
      if property == PropertyRound.Light then
        self.curProperty = RoleProperty.Light;
      elseif property == PropertyRound.Wind then
        self.curProperty = RoleProperty.Wind;
      elseif property == PropertyRound.Water then
        self.curProperty = RoleProperty.Water;
      elseif property == PropertyRound.Fire then
        self.curProperty = RoleProperty.Fire;
      elseif property == PropertyRound.None then
        self.curProperty = RoleProperty.None;
      end
      MutipleTeam:clearPropertyTeam();
    end
    SelectActorPanel:onShow(roundId);
  end
end

function PropertyRoundPanel:ServerResCallback(is_win)
	--local max_round = resTableManager:GetValue(ResTable.vip, tostring(ActorManager.user_data.viplevel), 'reset_trial') or 4;
  if not is_win then return end;
  if self.refreshAt24Flag then
    self.refreshAt24Flag = false;
    return;
  end
  ActorManager.user_data.round.limit_round_left = ActorManager.user_data.round.limit_round_left + 1;
  ActorManager.user_data.round.limit_round_sec = 900;
  self:ReStartTimer();
  if ActorManager.user_data.round.limit_round_left then
    remainTimesLabel.Text = tostring(self.max_round - ActorManager.user_data.round.limit_round_left)
    if (self.max_round - ActorManager.user_data.round.limit_round_left) == 0 then
      remainTimesLabel:SetFont('huakang_16_miaobian_R232G37B74')
    end
  else
    remainTimesLabel.Text = tostring(0)
    remainTimesLabel:SetFont('huakang_16_miaobian_R232G37B74')
  end
end

function PropertyRoundPanel:OnNormalFightCallBack(resultData)
  local msg = {};
  msg.roundid = resultData.id;
  if resultData.result == Victory.left then
    msg.result = 1;
    fightRes = 1;
  else
    msg.result = 0;
    fightRes = 0;
  end
  msg.salt = _G['salt#limit'];
  Network:Send(NetworkCmdType.req_limit_quit_t, msg);
end

function PropertyRoundPanel:ResetRoundAt24()
--[[
  ActorManager.user_data.round.limit_round_left = 5;
  ActorManager.user_data.round.limit_round_sec = 0;
  if panel.Visibility == Visibility.Visible then
    local okdelegate = Delegate.new(PropertyRoundPanel, PropertyRoundPanel.onShow, 0);
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG_pveBarrierInfoPanel_13, okdelegate);
  end
  ]]
end
function PropertyRoundPanel:newResetRoundAt24()
   if panel.Visibility == Visibility.Visible then
      self.refreshAt24Flag = true;
      self:onShow();
   end
end
function PropertyRoundPanel:GetPropertyRoundNum()
	--local max_round = resTableManager:GetValue(ResTable.vip, tostring(ActorManager.user_data.viplevel), 'reset_trial') or 4;
  return self.max_round - ActorManager.user_data.round.limit_round_left;
end
--  新手引导
function PropertyRoundPanel:onEnterUserGuilde(  )
 if UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and isChooseLeft then      --  选择左边的
    UserGuidePanel:ShowGuideShade( leftBtn,GuideEffectType.hand,GuideTipPos.right,'', 0)
    isChooseLeft = false
  elseif UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and isGuideReturn then      --  返回按钮
    UserGuidePanel:ShowGuideShade( backBtn,GuideEffectType.hand,GuideTipPos.right,'', 0)
    isGuideReturn = false
  elseif UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and isOnFight then      --  选择第一个
    UserGuidePanel:ShowGuideShade( itemList[1].getButton(),GuideEffectType.hand,GuideTipPos.right,'', 0.5)  
    isOnFight = false
   elseif UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and isClickBackBtn then      --  选择第一个
    UserGuidePanel:ShowGuideShade( WorldMapPanel:getReturnBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0)  
    isClickBackBtn = false
  end
end

function PropertyRoundPanel:onCloseRoundPanel(  )
 if UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) then      --  关闭
    UserGuidePanel:ShowGuideShade( roundPanel:GetLogicChild('colse'),GuideEffectType.hand,GuideTipPos.right,'', 0)
  end
end
