--selectActorPanel.lua
--======================================================================================
SelectActorPanel = 
{
  isExpedition = false,
  isPropertyRound = false,
  isCardEvent = false,
  REVIVE_ID = 14,
};

local mainDesktop;
local panel;
local touchPanel;
local allActorPanel;
local lblFp;
local lblName;
local lblDiff;
local enemyPanel;
local headPanel;
local topPanel;
local propertyTip 
--
local curType;
local full;
local actorList = {};
local actorPidList = {};
local partnerObjectList = {};
local selectedPidList = {};
local curFp = 0;
local roundid = 0;
local isCanBeginFight = false;
local eventData

local expeditionRoleList = {}
local expeditionCount = 1
local selectRole = 1
local comboPro = {}

local propertyRoleList = {}
local propertyCount = 1

local btnFight
local allBtn;

local heroPanel;
local footPanel;
local nowRoleList;
local buttonList;
local fpLabel;
local cardEventData
local cardPanel;
local cardEventUI;
local comboProBtn;
local comboProPanel;

--======================================================================================
--Init BEGIN
function SelectActorPanel:InitPanel(desktop)
  full = 0;
  curFp = 0;
  curType = 0;
  roundid = 0;
  actorList = {}; -- UI位置
  actorPidList = {}; -- UI上伙伴
  selectedPidList = {}; -- 选中的伙伴
  partnerObjectList = {}; -- 拥有的伙伴
  isCanBeginFight = false;

  mainDesktop = desktop;
  panel = desktop:GetLogicChild('selectActorPanel');
  panel:IncRefCount();
  panel.Visibility = Visibility.Hidden;
  panel.ZOrder = PanelZOrder.select_actor;
  
  comboProPanel = panel:GetLogicChild('comboProPanel');
  comboProPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'SelectActorPanel:comboProClose');
  comboProPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'SelectActorPanel:comboProClose');
  self:InitHeadPanel();
  self:InitMiddlePanel();
  self:InitFootPanel();
  self:InitCardEventPanel();
  self:BindButton();
  eventData = CardEvent:event()
end

function SelectActorPanel:InitHeadPanel()
  topPanel = panel:GetLogicChild('topPanel');
  lblName = topPanel:GetLogicChild('name');
  lblDiff = topPanel:GetLogicChild('diff');
  headPanel = panel:GetLogicChild('headPanel');
  enemyPanel = headPanel:GetLogicChild('oppositePanel');
  propertyTip = panel:GetLogicChild('propertyTip')
  comboProBtn = headPanel:GetLogicChild('comboProBtn');
  comboProBtn:SubscribeScriptedEvent('Button::ClickEvent','SelectActorPanel:comboProShow');
end

function SelectActorPanel:InitMiddlePanel()
  nowRoleList = panel:GetLogicChild('NowRoleList')
  local actorPanel = nowRoleList:GetLogicChild('stackPanel');
  for i = 1, 5 do
    local actor = actorPanel:GetLogicChild(tostring(i));
    local arm = actor:GetLogicChild('armature');
    local btn = actor:GetLogicChild('button');
    btn.Tag = i;
    btn:SubscribeScriptedEvent('Button::ClickEvent', 'SelectActorPanel:Unselected');
    table.insert(actorList, {armature = arm, pid = -1, hp = 0, index = -1, hit_area = 99999, path = "", img = ""});
  end
end

function SelectActorPanel:InitFootPanel()
  footPanel = panel:GetLogicChild('footPanel');
  heroPanel = footPanel:GetLogicChild('panel');
  touchPanel = heroPanel:GetLogicChild('tsp');
  allActorPanel = heroPanel:GetLogicChild('tsp'):GetLogicChild('sp');
  lblFp = footPanel:GetLogicChild('zhandouli');
  lblFp.Text = '0';
  btnFight = footPanel:GetLogicChild('fightButton');
  btnFight:SubscribeScriptedEvent('Button::ClickEvent', 'SelectActorPanel:onFight');
  buttonList = footPanel:GetLogicChild('ig');
  fpLabel = footPanel:GetLogicChild('label');
end

function SelectActorPanel:InitCardEventPanel()
	cardPanel = panel:GetLogicChild('cardEventPanel');
	cardEventUI = {};
	cardEventUI.setDifficult = function(di)
		cardPanel:GetLogicChild('brush_difficult'):GetLogicChild('labelDifficult').Text = resTableManager:GetValue(ResTable.event_difficulty, tostring(di), 'name');
	end
	cardEventUI.setLevel = function(level)
		cardPanel:GetLogicChild('brush_level'):GetLogicChild('labelLevel').Text = string.format(LANG_CardEvent_31,tostring(level),tostring(Configuration.CardEventStageNum));
	end
	cardPanel:GetLogicChild('brush_difficult').Background = CreateTextureBrush("card_event/select_actor_di.ccz", 'card_event');
	cardPanel:GetLogicChild('brush_level').Background = CreateTextureBrush("card_event/select_actor_level.ccz", 'card_event');

end


function SelectActorPanel:BindButton()
  local buttonPanel = panel:GetLogicChild('footPanel'):GetLogicChild('ig');
  allBtn = buttonPanel:GetLogicChild('AllButton');
  local frontBtn = buttonPanel:GetLogicChild('frontButton');
  local centerBtn = buttonPanel:GetLogicChild('centerButton');
  local backBtn = buttonPanel:GetLogicChild('backButton');
  allBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'SelectActorPanel:onAll');
  frontBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'SelectActorPanel:onFront');
  centerBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'SelectActorPanel:onCenter');
  backBtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'SelectActorPanel:onBack');
end
--Init End
--======================================================================================

--======================================================================================
--UI Controller BEGIN
function SelectActorPanel:Show()
  --屏幕适配
  if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
    local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
    heroPanel:SetScale(factor,factor);
    btnFight:SetScale(factor,factor);
    heroPanel.Translate = Vector2(730*(factor-1)/2,100*(1-factor)/2);
    btnFight.Translate = Vector2(150*(1-factor)/2,80*(1-factor)/2);
    nowRoleList:SetScale(factor,factor);
    headPanel:SetScale(factor,factor);
    headPanel.Translate = Vector2(600*(1-factor)/2,130*(factor-1)/2);
    topPanel:SetScale(factor,factor);
    propertyTip:SetScale(factor,factor);
    topPanel.Translate = Vector2(470*(1-factor)/2,55*(factor-1)/2);
    propertyTip.Translate = Vector2(360*(1-factor)/2,40*(factor-1)/2);
    buttonList:SetScale(factor,factor);
    buttonList.Translate = Vector2(420*(factor-1)/2,38*(1-factor)/2);
    fpLabel:SetScale(factor,factor);
    fpLabel.Translate = Vector2(170*(factor-1)/2,25*(factor-1)/2);
  end

  panel:GetLogicChild('bg').Background = CreateTextureBrush("background/duiwu_bg.jpg", 'background');
  panel.Visibility = Visibility.Visible;
  StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1, nil, '');  
end

function SelectActorPanel:onShow(id)
  self.isExpedition = false
  self.isPropertyRound = false
  self.isCardEvent = false
  roundid = id;
  if RoundIDSection.LimitRoundBegin <= roundid and
    roundid <= RoundIDSection.LimitRoundEnd
  then    --  属性试炼
    self.isPropertyRound = true
    topPanel.Visibility = Visibility.Visible;
    headPanel.Visibility = Visibility.Hidden;
    propertyTip.Visibility = Visibility.Visible;
	fpLabel.Visibility = Visibility.Hidden;
	cardPanel.Visibility = Visibility.Hidden;
    self:initPropertyTeam();
    self:refreshTopPanel();

  elseif RoundIDSection.ExpeditionBegin <= roundid and
    roundid <= RoundIDSection.ExpeditionEnd 
  then   --   远征
    self.isExpedition = true 
    topPanel.Visibility = Visibility.Hidden;
    headPanel.Visibility = Visibility.Visible;
    propertyTip.Visibility = Visibility.Hidden;
	fpLabel.Visibility = Visibility.Hidden;
	cardPanel.Visibility = Visibility.Hidden;
    self:initExpeditionTeam();
    Network:Send(NetworkCmdType.req_expedition_team_t, {});

  elseif RoundIDSection.CardEventBegin <= roundid and roundid <= RoundIDSection.CardEventEnd 
  then -- 卡牌活动
    self.isCardEvent = true
    topPanel.Visibility = Visibility.Hidden
    headPanel.Visibility = Visibility.Visible
    propertyTip.Visibility = Visibility.Hidden
	fpLabel.Visibility = Visibility.Visible;
	cardPanel.Visibility = Visibility.Visible;
	cardEventUI.setDifficult(CardEventPanel:getDifficulty());
	cardEventUI.setLevel(CardEventPanel:getLevel())
    self:initCardEventTeam()

  end
  touchPanel:VScrollBegin();
  self:Show();
  timerManager:CreateTimer(0.1,'SelectActorPanel:onEnterUserGuildeProperty',0,true)
end

function SelectActorPanel:Hide()
  panel.Visibility = Visibility.Hidden;
  StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'SelectActorPanel:onDestroy');
end

function SelectActorPanel:onDestroy()
  panel:GetLogicChild('bg').Background = nil;
  DestroyBrushAndImage("background/duiwu_bg.jpg", 'background');
  StoryBoard:OnPopUI();
end

function SelectActorPanel:Destroy()
  panel:DecRefCount();
  panel = nil;
end

function SelectActorPanel:onForceReturn()
  self:Hide();
  self.isExpedition = true
  ExpeditionPanel:onShow();
end

function SelectActorPanel:onAll()
  curType = 0;
  self:refreshActorList();
end

function SelectActorPanel:onFront()
  curType = 1;
  self:refreshActorList();
end

function SelectActorPanel:onCenter()
  curType = 2;
  self:refreshActorList();
end

function SelectActorPanel:onBack()
  curType = 3;
  self:refreshActorList();
end
--UI Controller END
--======================================================================================

--======================================================================================
--Common Function BEGIN
function SelectActorPanel:onFight()
  if not self:onCheck() then return end;

  if RoundIDSection.LimitRoundBegin <= roundid and 
    roundid <= RoundIDSection.LimitRoundEnd then
    self:onPropertyRoundFight();

  elseif RoundIDSection.ExpeditionBegin <= roundid and 
    roundid <= RoundIDSection.ExpeditionEnd then
    ExpeditionPanel:onClose();
    self:onExpeditionFight();
    Loading.waitMsgNum = 1;

  elseif self.isCardEvent then
    if (ActorManager.user_data.functions.card_event.is_close) then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_ERROR_CODE_2700);
		return;
	end
	  
    self:onCardEventFight()
    Loading.waitMsgNum = 1

  end
  self:playRoleSound()
  self:Hide();
  Game:SwitchState(GameState.loadingState);
end

function SelectActorPanel:onReturn()
  if self.isExpedition then
    self:ntExpeditionTeamChange();
  elseif self.isPropertyRound then
    self:ntPropertyTeamChange();
  elseif self.isCardEvent then
    self:ntCardEventTeamChange()
  end
  self:Hide();
end

function SelectActorPanel:onCheck()
  local isCanBegin = false;
  for _, al in pairs(actorList) do
    if al.pid ~= -1 then isCanBegin = true end;
  end
  if not isCanBegin then
    ToastMove:CreateToast(LANG_selectActorPanel_2);
    return false;
  end
  if self.isExpedition or self.isCardEvent then
    if not isCanBeginFight then
      ToastMove:CreateToast(LANG_selectActorPanel_1); 
      return false;
    end
  end
  return true;
end

function SelectActorPanel:reset(actor)
  actor.armature:Destroy();
  actor.resid = -1;
  actor.pid = -1;
  actor.hp = 0;
  actor.index = -1;
  actor.hit_area = 99999;
  actor.path = "";
  actor.img = "";
end

function SelectActorPanel:reload(new)
  for _, al in ipairs(actorList) do
    table.insert(actorPidList,
    {resid = al.resid, pid = al.pid, hp = al.hp, index = al.index, hit_area = al.hit_area, path = al.path, img = al.img});
  end
  if new then
    for i, apl in ipairs(actorPidList) do
      if new.hit_area < apl.hit_area then
        table.insert(actorPidList, i, new);
        break;
      end
    end
  end
  local i = 1;
  for j = 2, 5 do
    if actorPidList[i].pid == -1 and actorPidList[j].pid ~= -1 then
      actorPidList[i],actorPidList[j] = actorPidList[j],actorPidList[i];
    end
    i = i + 1;
  end
  for i = 1, 5 do
    local apl = actorPidList[i];
    apl.armature = actorList[i].armature;
    actorList[i] = apl;
    apl.armature:Destroy();
    AvatarManager:LoadFile(apl.path);
    apl.armature:LoadArmature(apl.img);
    apl.armature:SetAnimation(AnimationType.f_idle);
    apl.armature:SetScale(1.65, 1.65);
  end
end

function SelectActorPanel:Selected(Args)
  local args = UIControlEventArgs(Args);
  self:setSelected(args.m_pControl.Tag);
end

-- 点击下方英雄头像将英雄放到中间队伍列表
function SelectActorPanel:setSelected(index)
  if partnerObjectList[index].isSelected() then --击下方英雄头像，如果当前英雄已经选中，此时点会把英雄从队伍中撤离
    for i=1, #actorList do
      if actorList[i].pid == partnerObjectList[index].pid then
        self:setUnselected(i)
        return
      end
    end
  elseif full == 5 then --如果这个英雄没有被选中，并且队伍已经有5个人了，那就什么都不做
    return
  end 
  if partnerObjectList[index].isDied() then 
    if self.isCardEvent then
      self:CardEventRevive(index)
    end
    --英雄已经死亡，再点击头像不会有任何操作
    return
  end
  partnerObjectList[index].Selected();
  -- timerManager:CreateTimer(0.1,'SelectActorPanel:onEnterUserGuildeExpedition',0,true)
  full = full + 1;
  actorPidList = {};
  local role = partnerObjectList[index].role;
  local data = resTableManager:GetValue(ResTable.actor, tostring(role.resid), {'path', 'img'});
  local hp = 1
  if self.isExpedition then
    hp = Expedition:HP(role.pid)
  elseif self.isCardEvent then
    hp = CardEvent:HP(role.pid)
  end
  local new = {
    resid    = role.resid,
    pid      = role.pid,
    hp       = hp,
    index    = index,
    hit_area = resTableManager:GetValue(ResTable.actor, tostring(role.resid), 'hit_area'),
    path     = GlobalData.AnimationPath .. data['path'] .. '/',
    img      = data['img'],
  };
  self:reload(new);
  if self.isCardEvent then
	  if eventData['role_id'] == role.resid or eventData['role_id_1'] == role.resid or eventData['role_id_2'] == role.resid then
		  footPanel:GetLogicChild('label'):GetLogicChild('up').Visibility = Visibility.Visible;
		  CardEvent.special = true;
		  CardEvent.specialRank = role.rank;
	  end
	  curFp = self:calculateCardEventFp();
  else
	  curFp = 0;
	  for i=1, 5 do
		  if actorList[i].pid ~= -1 then
			  local role = ActorManager:GetRole(actorList[i].pid);
			  if role then
				  local add_fp = GemPanel:reCalculateFp(role, 6-i);
				  curFp = curFp + add_fp;
			  end
		  end
	  end
  end
  lblFp.Text = tostring(math.floor(curFp));
end
function SelectActorPanel:actorGemFp()
	local role_list = {};
	for i = 1, 5 do
		role_list[i]=0;
	end

	local actorNum = 0;
	for i = 1, 5 do
		if actorList[i].pid ~= -1 and not MutipleTeam:isInDefaultTeam(actorList[i].pid) then
			role_list[i] = 1;
		end
	end 
	return GemPanel:gemFp(role_list);
end
function SelectActorPanel:Unselected(Args)
  local args = UIControlEventArgs(Args);
  self:setUnselected(args.m_pControl.Tag);
end

function SelectActorPanel:setUnselected(index)
  if not actorList[index] or actorList[index].pid == -1 then return end;
  partnerObjectList[actorList[index].index].Unselected();
  local role = ActorManager:GetRole(actorList[index].pid)
  if self.isCardEvent then
	  if eventData['role_id'] == role.resid then
		  footPanel:GetLogicChild('label'):GetLogicChild('up').Visibility = Visibility.Hidden;
		  CardEvent.special = false;
	  end
  end
  full = full - 1;
  self:reset(actorList[index]);
  if self.isCardEvent then
	  curFp = self:calculateCardEventFp();
  else
	  curFp = 0;
	  for i=1, 5 do
		  if actorList[i].pid ~= -1 then
			  local role = ActorManager:GetRole(actorList[i].pid);
			  if role then
				  local add_fp = GemPanel:reCalculateFp(role, 6-i);
				  curFp = curFp + add_fp;
			  end
		  end
	  end
  end
  if curFp < 0 then curFp = 0; end;
  lblFp.Text = tostring(math.floor(curFp));
  actorPidList = {};
  self:reload();
  if self.isCardEvent and eventData['role_id'] == role.resid then
    self:CardEventRoleNotInTeam()
  end
end

function SelectActorPanel:refreshActorList()
  for _, o in pairs(partnerObjectList) do
    if self:filter(o.role) then
      o.ctrlShow();
    else
      o.ctrlHide();
    end
  end
end

function SelectActorPanel:reloadPartner()
  partnerObjectList = {};
  local m_role = ActorManager:GetRole(0);
  if self:filter(m_role) then
    table.insert(partnerObjectList, m_role);
  end
  for _, role in pairs(ActorManager.user_data.partners) do
    if self:filter(role) then
      table.insert(partnerObjectList, role);
    end
  end
  table.sort(partnerObjectList, function(a, b) return a.pro.fp > b.pro.fp; end);
end

function SelectActorPanel:filter(role)
  local data = resTableManager:GetValue(ResTable.actor, tostring(role.resid), {'attribute', 'hit_area'});
  local propertyRound = function()
    if PropertyRoundPanel.curProperty ~= data['attribute'] then return false end;
    if curType == 0 then
      return true;
    elseif curType == 1 then
      return data['hit_area'] == NormalAttackRange.Front;
    elseif curType == 2 then
      return data['hit_area'] == NormalAttackRange.Middle;
    elseif curType == 3 then
      return data['hit_area'] == NormalAttackRange.Rear;
    else
      return false;
    end
  end
  local expedition = function()
    if curType == 0 then
      return role.lvl.level >= 1;
    elseif curType == 1 then
      return role.lvl.level >= 1 and data['hit_area'] == NormalAttackRange.Front;
    elseif curType == 2 then
      return role.lvl.level >= 1 and data['hit_area'] == NormalAttackRange.Middle;
    elseif curType == 3 then
      return role.lvl.level >= 1 and data['hit_area'] == NormalAttackRange.Rear;
    else
      return false;
    end
  end
  local cardEvent = function()
    if curType == 0 then
      return true;
    elseif curType == 1 then
      return data['hit_area'] == NormalAttackRange.Front;
    elseif curType == 2 then
      return data['hit_area'] == NormalAttackRange.Middle;
    elseif curType == 3 then
      return data['hit_area'] == NormalAttackRange.Rear;
    else
      return false;
    end
  end
  if RoundIDSection.LimitRoundBegin <= roundid and 
    roundid <= RoundIDSection.LimitRoundEnd then
    return propertyRound();
  elseif RoundIDSection.ExpeditionBegin <= roundid and 
    roundid <= RoundIDSection.ExpeditionEnd then
    return expedition();
  elseif self.isCardEvent then
    return cardEvent()
  end
end
--Common Function END
--======================================================================================
--
--======================================================================================
function SelectActorPanel:comboProShow()
	comboProPanel:GetLogicChild('att1').Text = string.format('%s%%',tostring(comboPro.combo_d_down or 0));
	comboProPanel:GetLogicChild('att2').Text = string.format('%s%%',tostring(comboPro.combo_r_down or 0));
	comboProPanel:GetLogicChild('att3').Text = string.format('%s%%',tostring(comboPro.combo_d_up or 0));
	comboProPanel:GetLogicChild('att4').Text = string.format('%s%%',tostring(comboPro.combo_r_up or 0));
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
	local att5 = comboProPanel:GetLogicChild('att5');
	att5.Text = string.format('%s/%s/%s/%s/%s（怒气）',tostring(combo10),tostring(combo20),tostring(combo30),tostring(combo35),tostring(combo40));
	comboProPanel.Visibility = Visibility.Visible;
	mainDesktop.FocusControl = comboProPanel;
end
function SelectActorPanel:comboProClose()
	comboProPanel.Visibility = Visibility.Hidden;
end
--expedition team BEGIN
function SelectActorPanel:initExpeditionTeam()
  if not (RoundIDSection.ExpeditionBegin <= roundid and 
          roundid <= RoundIDSection.ExpeditionEnd) then
    return; --非远征关卡
  end
  curType = 0;
  allBtn.Selected = true;
  self:reloadPartner(); -- 重新加载伙伴
  full, curFp = 0, 0;
  --清空armature
  for _, actor in ipairs(actorList) do
    self:reset(actor);
  end
  selectedPidList = {};
  --从UI上移除原有伙伴 并筛选出可用伙伴
  allActorPanel:RemoveAllChildren();

  --在UI上创建伙伴icon, 若已有伙伴在队伍中，选中并放置
  --远征中若伙伴死亡，设置死亡状态
  for _, role in pairs(partnerObjectList) do
    local o = customUserControl.new(allActorPanel, 'cardHeadTemplate')--'teamInfoTemplate'
    o.initWithPid(role.pid, 85)
    o.ctrlSetInfo(_,role)
    o.clickEvent('SelectActorPanel:Selected',_)
    partnerObjectList[_] = o;
    --  记录当前可以上场的前5个英雄
    if tonumber(Expedition:HP(o.pid)) > 0 and
      expeditionCount <= 5 and
      UserGuidePanel:IsInGuidence(UserGuideIndex.expeditonTask, 2) 
    then
      expeditionRoleList[expeditionCount] = o
      expeditionCount = expeditionCount + 1
    end
    if tonumber(Expedition:HP(o.pid)) == 0 then
      o.setDied();
    end
  end
end

function SelectActorPanel:ntExpeditionTeamChange()
  local msg = {};
  msg.anger = 0;
  msg.team = {};
  Expedition.allyTeamList = {};
  for i = 1, 5 do
    table.insert(msg.team, {pid = actorList[i].pid, hp = actorList[i].hp});
    if actorList[i].pid ~= -1 then
      table.insert(Expedition.allyTeamList, {pid = actorList[i].pid, resid = actorList[i].resid, hp = actorList[i].hp});
    end
  end
  Network:Send(NetworkCmdType.nt_expedition_team_change_t, msg, true);  
end

function SelectActorPanel:ExpeditionEnemys(msg)
  enemyPanel:RemoveAllChildren();

  local maxLevel = 0;
  local roleLevel = 0;

  isCanBeginFight = false;
  for _, enemy in ipairs(msg.enemys) do
    local o = customUserControl.new(enemyPanel, 'cardHeadTemplate');
    o.initEnemyInfo(enemy,90)
    -- o.initWithMsgActor(enemy);

    if enemy.level > maxLevel then
      maxLevel = enemy.level;
    end
    if enemy.resid > 100 then
      roleLevel = enemy.level;
    end
    
    if enemy.hp == 0 then
      o.setDied();
    else
      isCanBeginFight = true;
    end
  end
 
  if msg.info and msg.info[1] then
    local viplvl = headPanel:GetLogicChild('infoPanel'):GetLogicChild('vipLevel');
    viplvl.Text = 'V' .. tostring(msg.info[1].viplv or 0);
    local enemyName = headPanel:GetLogicChild('infoPanel'):GetLogicChild('enemyName');
    enemyName.Text = tostring(msg.info[1].nickname or '获取失败');
    local levelNum = headPanel:GetLogicChild('infoPanel'):GetLogicChild('levelNum');
    local unionName = headPanel:GetLogicChild('infoPanel'):GetLogicChild('unionName');
    unionName.Text = tostring(msg.info[1].unionname or '未参加');
    local fpNum = headPanel:GetLogicChild('infoPanel'):GetLogicChild('fpNum');
    fpNum.Text = tostring(msg.info[1].fp or 0);

    if roleLevel > 0 then
      levelNum.Text = tostring(roleLevel)
    else
      levelNum.Text = tostring(maxLevel)
    end
  end
  comboPro = {};
  if msg.combo_pro then
	comboPro = msg.combo_pro;
  end
end

function SelectActorPanel:refreshExpedition(team)
  for _, actor in pairs(team) do
    for i, p in ipairs(partnerObjectList) do
      if p.pid == actor.pid and actor.hp == 0 then
        self:setUnselected(i);
        p.setDied();
      elseif p.pid == actor.pid and not p.isSelected() then
        self:setSelected(i);
      end
    end
  end
end

function SelectActorPanel:onExpeditionFight()
  if RoundIDSection.ExpeditionBegin > roundid or roundid > RoundIDSection.ExpeditionEnd then
    return;
  end
  self:ntExpeditionTeamChange();
  local msg = {};
  msg.resid = roundid;
  Network:Send(NetworkCmdType.req_enter_expedition_round_t, msg); 
  if UserGuidePanel:IsInGuidence(UserGuideIndex.expeditonTask, 2) then      --  远征引导完成
    UserGuidePanel:ReqWriteGuidence(UserGuideIndex.expeditonTask,2)
  end
end
--expedition team END
--======================================================================================

--======================================================================================
--property round BEGIN
function SelectActorPanel:initPropertyTeam()
  if not (RoundIDSection.LimitRoundBegin <= roundid and roundid <= RoundIDSection.LimitRoundEnd) then
    return; --非属性副本关卡
  end
  curType = 0;
  allBtn.Selected = true;
  self:reloadPartner(); -- 重新加载伙伴
  full, curFp = 0, 0;
  --清空armature
  for _, actor in ipairs(actorList) do
    self:reset(actor);
  end
  --重置team
  selectedPidList = {};
  local team = MutipleTeam:getPropertyTeam();
  for _, pid in ipairs(team) do
    selectedPidList[pid] = true
  end
  --从icon上移除原有伙伴并筛选出可用伙伴
  allActorPanel:RemoveAllChildren();
  --在UI上创建伙伴icon, 若已有伙伴在队伍中，选中并放置
  for _, role in pairs(partnerObjectList) do
    local o = customUserControl.new(allActorPanel, 'cardHeadTemplate');
    o.initWithPid(role.pid, 85)
    o.ctrlSetInfo(_,role)
    o.clickEvent('SelectActorPanel:Selected',_)
    -- o.initWithActorRolePR(role, _);
    partnerObjectList[_] = o;
    if propertyCount <= 5 and UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) then
      propertyCount = propertyCount + 1
    end

    if selectedPidList[o.pid] then 
      self:setSelected(o.index); --armature选中
    end 
  end
  --无队伍时默认选择
  if not next(selectedPidList) and curType == 0 then
    for _, o in pairs(partnerObjectList) do
      if not e then self:setSelected(o.index); end -- armature选中
    end
  end
end

function SelectActorPanel:refreshTopPanel()
   local data = resTableManager:GetValue(ResTable.limit_round, tostring(roundid), {'name', 'difficult'});
  lblName.Text = data['name'];
  lblDiff.Text = '-' .. data['difficult'] .. '-';
  local index = math.floor((roundid -7000)/10)
  propertyTip.Text = LANG_PROPERTY_TIP_1 .. PropertyKinds[index] .. LANG_PROPERTY_TIP_2
end

function SelectActorPanel:onPropertyRoundFight()
	--local max_round = resTableManager:GetValue(ResTable.vip, tostring(ActorManager.user_data.viplevel), 'reset_trial') or 4;
  --print('max_round->'..tostring(PropertyRoundPanel.max_round)..' limit_round_left->'..tostring(ActorManager.user_data.round.limit_round_left));
  if (PropertyRoundPanel.max_round - ActorManager.user_data.round.limit_round_left) <= 0 and ActorManager.user_data.round.limit_round_reset_times <= 0 then
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG__51);
    return;
  elseif (PropertyRoundPanel.max_round - ActorManager.user_data.round.limit_round_left) <= 0 
    and ActorManager.user_data.round.limit_round_reset_times > 0 then
    local okdelegate = Delegate.new(PropertyRoundPanel,PropertyRoundPanel.resetLimitRoundTimes,0);
      local contents = {};
      table.insert(contents,{cType = MessageContentType.Text; text = LANG_propertyRoundPanel_16})
      table.insert(contents,{cType = MessageContentType.Text; text = LANG_propertyRoundPanel_17})
      MessageBox:ShowDialog(MessageBoxType.OkCancel, contents,okdelegate);
    return;
  elseif ActorManager.user_data.round.limit_round_sec ~= 0 then
    MessageBox:ShowDialog(MessageBoxType.Ok, LANG__52);
    return;
  end
  self:ntPropertyTeamChange();
  local msg = {};
  msg.roundid = roundid;
  msg.partners = MutipleTeam:getPropertyTeam();
  PropertyRoundPanel.refreshAt24Flag = false;
  Network:Send(NetworkCmdType.req_limit_round_t, msg);
  Loading.waitMsgNum = 1;
end

function SelectActorPanel:ntPropertyTeamChange()
  local teamData = {};
  for _, a in pairs(actorList) do
    table.insert(teamData, a.pid);
  end
  MutipleTeam:propertyTeam(teamData);
end

function SelectActorPanel:onEnterUserGuildeExpedition(  )
  if UserGuidePanel:IsInGuidence(UserGuideIndex.expeditonTask, 2) then      --  远征
    -- if expeditionRoleList[selectRole] then
    --   UserGuidePanel:ShowGuideShade( expeditionRoleList[selectRole].getImageHead(),GuideEffectType.hand,GuideTipPos.right,'', 0.3)
    --   selectRole = selectRole + 1
    -- elseif selectRole > 1 then     --  表示最少有一个英雄
    --   UserGuidePanel:ShowGuideShade( btnFight,GuideEffectType.hand,GuideTipPos.right,'', 0.3)
    -- else
    --   UserGuidePanel:ReqWriteGuidence(UserGuideIndex.expeditonTask, 2)
    -- end
  end
end

function SelectActorPanel:onEnterUserGuildeProperty(  )
  if UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) then      --  属性试炼
    UserGuidePanel:ShowGuideShade( btnFight,GuideEffectType.hand,GuideTipPos.right,'', 0.3)
  end
end

--property round END
--======================================================================================
--
--======================================================================================
--card event team BEGIN
function SelectActorPanel:initCardEventTeam()
  if not self.isCardEvent then return end
  allBtn.Selected = true
  CardEvent.special = false
  self:reloadPartner()
  full, curFp = 0, 0
  for _, actor in ipairs(actorList) do
    self:reset(actor)
  end
  selectedPidList = {}
  self:CardEventRoleNotInTeam()

  allActorPanel:RemoveAllChildren()
  for _, role in pairs(partnerObjectList) do
    local o = customUserControl.new(allActorPanel, 'cardHeadTemplate')
    o.initWithPid(role.pid, 85)
    local r = ActorManager:GetRole(role.pid)
    if eventData['role_id'] == r.resid or eventData['role_id_1'] == r.resid or eventData['role_id_2'] == r.resid then
      o.setUp(true);
    end
    o.ctrlSetInfo(_,role)
    o.clickEvent('SelectActorPanel:Selected',_)
    partnerObjectList[_] = o
	if tonumber(CardEvent:HP(o.pid)) == 0 then
      o.setDied()
    end
  end
  local team = CardEvent.allyTeamList
  for _, actor in pairs(team) do
    for i, p in ipairs(partnerObjectList) do
      if p.pid == actor.pid and CardEvent:HP(actor.pid)== 0 then
        self:setUnselected(i)
        p.setDied()
      elseif p.pid == actor.pid and not p.isSelected() then
        self:setSelected(i)
      end
    end
  end
end

function SelectActorPanel:CardEventRoleInTeam()
  local up = fpLabel:GetLogicChild('up');
  up.Visibility = Visibility.Visible
	local name = resTableManager:GetValue(ResTable.actor,
                  tostring(eventData['role_id']), 'name')
  fpLabel.Text = string.format(LANG_selectActorPanel_5, name)
end

function SelectActorPanel:CardEventRoleNotInTeam()
  local up = fpLabel:GetLogicChild('up');
  up.Visibility = Visibility.Hidden
	local name = resTableManager:GetValue(ResTable.actor,
                  tostring(eventData['role_id']), 'name')
  fpLabel.Text = string.format(LANG_selectActorPanel_5, tostring(name))
end

function SelectActorPanel:CardEventEnemys(msg)
  enemyPanel:RemoveAllChildren()

  local max_level = 0
  local role_level = 0

  isCanBeginFight = false
  for _, enemy in ipairs(msg.enemys) do
    local o = customUserControl.new(enemyPanel, 'cardHeadTemplate')
    o.initEnemyInfo(enemy, 90)
    if enemy.level > max_level then
      max_level = enemy.level
    end
    if enemy.resid > 100 then
      role_level = enemy.level
    end
    if enemy.hp == 0 then
      o.setDied()
    else
      isCanBeginFight = true
    end
  end

  if msg.role then
    local infoPanel = headPanel:GetLogicChild('infoPanel')
    local viplvl = infoPanel:GetLogicChild('vipLevel')
    viplvl.Text = 'V' .. tostring(msg.role.viplv or 0);
    local enemyName = infoPanel:GetLogicChild('enemyName')
    enemyName.Text = tostring(msg.role.nickname or '获取失败');
    local unionName = infoPanel:GetLogicChild('unionName');
    unionName.Text = tostring(msg.role.unionname or '未参加');
    local fpNum = infoPanel:GetLogicChild('fpNum');
    fpNum.Text = tostring(msg.role.fp or 0);
    local levelNum = infoPanel:GetLogicChild('levelNum');
    if role_level > 0 then
      levelNum.Text = tostring(role_level)
    else
      levelNum.Text = tostring(max_level)
    end
  end
  comboPro = {};
  if msg.combo_pro then
	comboPro = msg.combo_pro;
  end
end

function SelectActorPanel:CardEventRevive(index)
  local pid = partnerObjectList[index].pid
	local value = resTableManager:GetValue(ResTable.config,
                  tostring(self.REVIVE_ID), 'value')
  if not value then
    ToastMove:CreateToast("config.txt not exists id(14).");
    return
  end

  local okDelegate = Delegate.new(
    SelectActorPanel,
    SelectActorPanel.reqCardEventRevive, 
    pid
  )
  MessageBox:ShowDialog(
    MessageBoxType.OkCancel,
    string.format(LANG_selectActorPanel_3, value),
    okDelegate, 
    nil
  )
end

function SelectActorPanel:reqCardEventRevive(pid)
 	Network:Send(NetworkCmdType.req_card_event_revive_t, {pid = pid}, true)
end

function SelectActorPanel:retCardEventRevive(pid)
  local obj = nil
  __.each(partnerObjectList, function(o)
    if o.pid == pid then
      obj = o
      return
    end
  end)
  if obj then
    obj.setRevived()
  end
end

function SelectActorPanel:ntCardEventTeamChange()
  local msg = {};
  msg.anger = 0;
  msg.team = {};
  local tmp = {}
  CardEvent.allyTeamList = {}
  for i = 1, 5 do
    table.insert(msg.team, {pid = actorList[i].pid, hp = actorList[i].hp})
	CardEvent:checkAddPartner(actorList[i].pid, actorList[i].hp);
    if actorList[i].pid ~= -1 then
      table.insert(CardEvent.allyTeamList, {pid = actorList[i].pid,
                   resid = actorList[i].resid, hp = actorList[i].hp})
    end
  end
  Network:Send(NetworkCmdType.nt_card_event_change_team_t, msg, true);  
end

function SelectActorPanel:onCardEventFight()
  if not self.isCardEvent then return end
  self:ntCardEventTeamChange()
	Network:Send(NetworkCmdType.req_card_event_fight_t, {['resid'] = roundid})
end

function SelectActorPanel:calculateCardEventFp()
	local total_fp = 0;
	if CardEvent.special then
		for i=1, 5 do
			if actorList[i].pid ~= -1 then
				local role = ActorManager:GetRole(actorList[i].pid);
				local factor = self:getCardEventFactor(actorList[i].pid);
				if role then
					local add_fp = GemPanel:reCalculateFp(role, 6-i, factor);
					total_fp = total_fp + add_fp;
				end
			end
		end
	else
		for i=1, 5 do
			if actorList[i].pid ~= -1 then
				local role = ActorManager:GetRole(actorList[i].pid);
				if role then
					local add_fp = GemPanel:reCalculateFp(role, 6-i);
					total_fp = total_fp + add_fp;
				end
			end
		end
	end
	return total_fp;	
end

function SelectActorPanel:getCardEventFactor(pid)
	local baseActor = ActorManager:GetRole(pid)
	local event_data = resTableManager:GetRowValue(ResTable.event, tostring(ActorManager.user_data.functions.card_event.event_id));
	local data = {};
	if baseActor.resid == event_data['role_id'] then
		data = resTableManager:GetRowValue(ResTable.event_role, tostring(1));
	elseif baseActor.resid == event_data['role_id_1'] then
		data = resTableManager:GetRowValue(ResTable.event_role, tostring(2));
	elseif baseActor.resid == event_data['role_id_2'] then
		data = resTableManager:GetRowValue(ResTable.event_role, tostring(3));
	else
		data['atk'] = 0;
		data['mgc'] = 0;
		data['def'] = 0;
		data['res'] = 0;
		data['hp'] = 0;
	end
	local factor = {
		atk = 1 + data['atk'],
		mgc = 1 + data['mgc'],
		def = 1 + data['def'],
		res = 1 + data['res'],
		hp  = 1 + data['hp'],
	}
	return factor;
end

function SelectActorPanel:CardEventCalFp(pid)
  local baseActor = ActorManager:GetRole(pid)
  local event_data = resTableManager:GetRowValue(ResTable.event, tostring(ActorManager.user_data.functions.card_event.event_id));
  local data = {};
  if baseActor.resid == event_data['role_id'] then
	  data = resTableManager:GetRowValue(ResTable.event_role, tostring(1));
  elseif baseActor.resid == event_data['role_id_1'] then
	  data = resTableManager:GetRowValue(ResTable.event_role, tostring(2));
  elseif baseActor.resid == event_data['role_id_2'] then
	  data = resTableManager:GetRowValue(ResTable.event_role, tostring(3));
  else
		data['atk'] = 0;
		data['mgc'] = 0;
		data['def'] = 0;
		data['res'] = 0;
		data['hp'] = 0;
  end
  local actor = {
    ['pro'] = {
      atk = baseActor.pro.atk * (1 + data['atk']),
      mgc = baseActor.pro.mgc * (1 + data['mgc']),
      def = baseActor.pro.def * (1 + data['def']),
      res = baseActor.pro.res * (1 + data['res']),
      hp  = baseActor.pro.hp  * (1 + data['hp']),
    },
    ['lvl'] = {
      level = baseActor.lvl.level,
    },
    ['skls'] = baseActor.skls
  }
  return CaculateFightPoint(actor)
end
--card event team END
--======================================================================================

function SelectActorPanel:playRoleSound()
	local team = {};
	local length = 0
	for _, a in pairs(actorList) do
		table.insert(team, a.pid);
	end
	for i=1,5 do
		if team[i] > -1 then
			length = length + 1
		end
	end
	if length == 0 then
	else
		local random = math.random(1,length)
		local pid = team[random]
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
