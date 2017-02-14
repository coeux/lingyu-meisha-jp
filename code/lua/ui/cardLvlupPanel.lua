--cardLvlupPanel.lua
--========================================================================
--卡牌升级弹窗

CardLvlupPanel =
{
};

--变量
local eatType;
local currentRole;
local currentItemId;
local cardList;


local upRolePanel;

--控件
local mainDesktop;
local cardLvlupPanel;
local centerPanel;
local upGredePanel;
local btnClose;
local cardRole;
local panelPopWindow;
local btnOKpop;
local btnCancelpop;

local labelLv;
local labelHp;
local labelNormalAtk;
local labelSkillAtk;
local labelNormalDef;
local labelSkillDef;
local progressExp;

local infoPanel;

local itemPop;
local textBoxNum;
local popLvl;
local rolename;
local alleatPanel; 
local progressLabel;
local curexp;
local nextexp;
local partnerlv;
local timer;
local recordBeforePartnerInfoList;    --记录升级前属性的变化
local recordNextPartnerInfoList;      --记录升级后属性的变化 
local rolepid;
local recordEat = false;
local playTimes = 1;  --升级特效播放次数

local userguideBtn;
local upSound;
--初始化面板
function CardLvlupPanel:InitPanel( desktop )
  --变量初始化
  eatType = 1;
  upSound = nil
  --界面初始化	
  mainDesktop = desktop;	
  upGredePanel = Panel(desktop:GetLogicChild('UpGredePanel'));
  upRolePanel = Panel(desktop:GetLogicChild('UpRolePanel'));
  upGredePanel:IncRefCount();
  upGredePanel.Visibility = Visibility.Hidden;
  labelLv = upGredePanel:GetLogicChild('Panel'):GetLogicChild('lvlabel');
  progressExp = upGredePanel:GetLogicChild('level');
  rolename = upGredePanel:GetLogicChild('Panel'):GetLogicChild('label');
  curexp = progressExp:GetLogicChild('curexp');
  nextexp = progressExp:GetLogicChild('nextexp');
  cardList = upGredePanel:GetLogicChild('cardListClip'):GetLogicChild('cardList');
  self.isShow = false;

end

--销毁
function CardLvlupPanel:Destroy()
  upGredePanel:DecRefCount();
  upGredePanel = nil;
end

function CardLvlupPanel:getSelfPanel()
  return  upGredePanel;
end

--显示
function CardLvlupPanel:Show(roleindex, roleinfo)
  if TaskAcceptAndRewardPanel:IsShow() then
	 return;
  end
  self.isShow = true;
  rolepid = roleindex;
  if(rolepid == 0 or rolepid == ActorManager.user_data.role.resid) then
    rolepid = ActorManager.user_data.role.resid;
  end
  currentRole = roleinfo; 
  rolename.Text = currentRole.name;
  alleatPanel = {};
  cardList:RemoveAllChildren(); 
  for i = 1, 3 do
	  local eatPanel = customUserControl.new(cardList, 'UpgreadeTemplate');
	  eatPanel.initWithItem(11000 + i, currentRole);
	  alleatPanel[11000 + i] = eatPanel;
	  if i == 1 and UserGuidePanel:IsInGuidence(UserGuideIndex.hire, 1) then
		  timerManager:CreateTimer(0.1, 'CardLvlupPanel:enterTeamBtnGuide', 0, true);
		  userguideBtn = alleatPanel[11000 + i].getBtn();
	  elseif i == 1 and UserGuidePanel:IsInGuidence(UserGuideIndex.cardrolelvup, 1) then
		--  timerManager:CreateTimer(0.1, 'CardLvlupPanel:enterTeamBtnGuide', 0, true);
		  userguideBtn = alleatPanel[11000 + i].getBtn();
	  end
  end
  self:initLevelInfo(currentRole); 
  upGredePanel:SetUIStoryBoard("storyboard.showUIBoard2");   
  upGredePanel.Visibility = Visibility.Visible;
  self.upGredePanel = upGredePanel;
  if(rolepid == 0 or rolepid == ActorManager.user_data.role.resid) then
	  CardLvlupPanel:ShowRoleInfo(roleinfo)
    upRolePanel.Visibility = Visibility.Visible;
    upGredePanel.Visibility = Visibility.Hidden;
  else
	  upRolePanel.Visibility = Visibility.Hidden;
  end
end

function CardLvlupPanel:enterTeamBtnGuide()
	UserGuidePanel:ShowGuideShade(userguideBtn,GuideEffectType.hand, GuideTipPos.right);
end

function CardLvlupPanel:initLevelInfo(Roleinfo)
  if(Roleinfo) then
    labelLv.Text = tostring(currentRole.lvl.level);
    partnerlv = tonumber(labelLv.Text);
    self:recordProperInfo(partnerlv, false);
	progressExp.MaxValue = currentRole.lvl.levelUpExp;
    progressExp.CurValue = currentRole.lvl.curLevelExp;
  end
end

--显示主角对应信息
function CardLvlupPanel:ShowRoleInfo(Roleinfo)
	upRolePanel.Visibility = Visibility.Visible;
	upRolePanel:SetUIStoryBoard("storyboard.showUIBoard2");  
	upGredePanel.Visibility = Visibility.Hidden;
	self.upGredePanel = upRolePanel;
	local roleLv = upRolePanel:GetLogicChild('Panel'):GetLogicChild('lvlabel');
	local proExp = upRolePanel:GetLogicChild('level');
	local rolenameLabel = upRolePanel:GetLogicChild('Panel'):GetLogicChild('label');
	local expcur = proExp:GetLogicChild('curexp');
	local expnext = proExp:GetLogicChild('nextexp');
	local taskNum = upRolePanel:GetLogicChild('DailyTask'):GetLogicChild('taskNum');
	local taskExp = upRolePanel:GetLogicChild('DailyTask'):GetLogicChild('getExp');
	local dailyTaskBtn = upRolePanel:GetLogicChild('DailyTask'):GetLogicChild('taskBtn');
	dailyTaskBtn:SubscribeScriptedEvent('Button::ClickEvent', 'CardLvlupPanel:EnterDailyTask');
	local pveBtn = upRolePanel:GetLogicChild('fubenPanel'):GetLogicChild('fubenBtn');
	pveBtn:SubscribeScriptedEvent('Button::ClickEvent', 'CardLvlupPanel:EnterPvE');
	taskNum.Text, taskExp.Text = Task:getLeftTaskInfo();
	if(Roleinfo) then
		roleLv.Text = tostring(Roleinfo.lvl.level);
		proExp.MaxValue = ActorManager.user_data.role.lvl.levelUpExp;
		proExp.CurValue = ActorManager.user_data.role.lvl.curLevelExp;
		rolenameLabel.Text = Roleinfo.name;
	end
end

--离开主角信息进入副本
function CardLvlupPanel:EnterPvE()
	HomePanel:onLeaveHomePanel();
	PveBarrierPanel:onEnterPveBarrier()
end

--离开主角信息进入每日任务
function CardLvlupPanel:EnterDailyTask()
	HomePanel:onLeaveHomePanel();
	PlotTaskPanel:onShow();
end

--隐藏
function CardLvlupPanel:Hide()
  if UserGuidePanel:IsInGuidence(UserGuideIndex.hire, 1) then
	UserGuidePanel:ShowGuideShade(HomePanel:GetReturnBtn(),GuideEffectType.hand, GuideTipPos.right);
  elseif UserGuidePanel:IsInGuidence(UserGuideIndex.cardrolelvup, 1) then
	--  UserGuidePanel:ShowGuideShade(HomePanel:GetReturnBtn(),GuideEffectType.hand, GuideTipPos.right);
  end
  self.isShow = false;
  --销毁生成的自定义控件
  CardDetailPanel:refreshFp();
  upGredePanel.Visibility = Visibility.Hidden;	
  upRolePanel.Visibility = Visibility.Hidden;
end

function CardLvlupPanel:showPanel( )
  self.isShow = true;
  --销毁生成的自定义控件
  upGredePanel.Visibility = Visibility.Visible;
end


--事件
function CardLvlupPanel:onClose()
	self:Hide();
end

function CardLvlupPanel:recordProperInfo(partnerlv, nextstate)  --记录一下所有物防和 生命等信息
  local atk = resTableManager:GetValue(ResTable.levelup_attribute, tostring(partnerlv), 'atk');
  local mgc = resTableManager:GetValue(ResTable.levelup_attribute, tostring(partnerlv), 'mgc');  --技能攻击
  local def = resTableManager:GetValue(ResTable.levelup_attribute, tostring(partnerlv), 'def');  --物防 
  local res = resTableManager:GetValue(ResTable.levelup_attribute, tostring(partnerlv), 'res');  --技能防御
  local hp = resTableManager:GetValue(ResTable.levelup_attribute, tostring(partnerlv), 'hp');
  if(not nextstate) then
    recordBeforePartnerInfoList = {atk, mgc, def, res, hp};
  else                          --说明此时是主角增长后的信息
    recordNextPartnerInfoList   = {atk, mgc, def, res, hp};
    -- timer = timerManager:CreateTimer(0.8, 'CardLvlupPanel:makeTimer', 1); 
    -- fix temply
    for i = 1, 5 do
      local minis = recordNextPartnerInfoList[i] - recordBeforePartnerInfoList[i];
      if minis > 0 then
        ToastMove:CreateToast(LANG_cardLvlup_att[i], Configuration.GreenColor);
        --ToastMove:CreateToast(GemWord[i]..' '.. '+'..' '.. minis, Configuration.GreenColor);
      end
    end
  end
end

local eatCramList = {};

function CardLvlupPanel:refresh(msg)
  local itemData = Package:GetItem(currentItemId);
  if itemData then
    local checkstate = alleatPanel[currentItemId].setNum(itemData.num, currentRole);	
    if(checkstate) then
      local buttonGroup;
      for  i = 1, 3 do
        buttonGroup = alleatPanel[11000 + i].setEnable();
        buttonGroup[1].Enable = false;
        buttonGroup[2].Enable = false;
      end
    end
  end	
  if(partnerlv < tonumber(currentRole.lvl.level)) then
    ToastMove:CreateToast('レベルアップ！', Configuration.GreenColor);
    --ToastMove:CreateToast('等级增加'..' '..tostring(tonumber(currentRole.lvl.level) - partnerlv), Configuration.GreenColor);
	local effect = PlayEffectScale('shengji_output/', Rect(240,30,0,0), 'shengji', 4, 4, HomePanel:returnHomePanel():GetLogicChild('navi'));
	if(partnerlv < tonumber(currentRole.lvl.level) - 1) then
		playTimes = 3;
	else 
		playTimes = 1;
	end
	effect:SetScriptAnimationCallback('CardLvlupPanel:replay',0);
  end
  --local voicePath = resTableManager:GetValue(ResTable.actor, tostring(rolepid), 'voice');
  --SoundManager:PlayVoice(tostring(voicePath));
  self:recordProperInfo(currentRole.lvl.level, true);  	                                                   

  labelLv.Text = tostring(currentRole.lvl.level);   
  partnerlv = tonumber(labelLv.Text);
  --Debug.print_var_dump('currentRole', currentRole.lvl);
  --Debug.print_var_dump('msg', msg);
  progressExp.MaxValue = currentRole.lvl.levelUpExp; 
  progressExp.CurValue = currentRole.lvl.curLevelExp;
  --HomePanel:RoleShow();  
  --  更新战斗力
  uiSystem:UpdateDataBind()
end

function CardLvlupPanel:replay()	
	if playTimes == 1 then
		return;
	end
	local effect = PlayEffectScale('shengji_output/', Rect(240,30,0,0), 'shengji', 4, 4, HomePanel:returnHomePanel():GetLogicChild('navi'));
	playTimes = playTimes - 1;
	effect:SetScriptAnimationCallback('CardLvlupPanel:replay',0);
end

function CardLvlupPanel:cancelEatAlot()	
  panelPopWindow.Visibility = Visibility.Hidden;
end

function CardLvlupPanel:onEat(Arg)	
  local arg = UIControlEventArgs(Arg);	
  local tag = arg.m_pControl.Tag;
  currentItemId = tag;
  local msg = {};
  msg.param = tostring(currentRole.pid);
  msg.resid = tag;	
  msg.num = 1;
  Network:Send(NetworkCmdType.req_use_item_t, msg);	
  if UserGuidePanel:IsInGuidence(UserGuideIndex.hire, 1) then
	UserGuidePanel:ShowGuideShade(HomePanel:GetReturnBtn(),GuideEffectType.hand, GuideTipPos.right);
  elseif UserGuidePanel:IsInGuidence(UserGuideIndex.cardrolelvup, 1) then
--	  UserGuidePanel:ShowGuideShade(HomePanel:GetReturnBtn(),GuideEffectType.hand, GuideTipPos.right);
  end
end

function CardLvlupPanel:onCram(Arg)	
  local arg = UIControlEventArgs(Arg);	
  local tag = arg.m_pControl.Tag;
  currentItemId = tag;		
  local msg = {};
  msg.param = tostring(currentRole.pid);
  recordEat = true
  msg.resid = tag;	

  msg.num = self:getEatNum(tag);
  Network:Send(NetworkCmdType.req_use_item_t, msg);	
end

function CardLvlupPanel:touchIcon(Arg)     --点击icon事件
  local args = UIControlEventArgs(Arg);
  if args.m_pControl.Tag == 0 then
    return;
  end
  local item = {};
  item.resid = args.m_pControl.Tag;	
  local itemType = resTableManager:GetValue(ResTable.item, tostring(item.resid), 'type');
  if itemType == ItemType.power then
    TooltipPanel:ShowItem(upGredePanel, item, TipMaterialShowButton.SynthesisObtain, Rect(113, 24, 0, 0));	
  end	
end

function CardLvlupPanel:getEatNum(Arg)	
  local itemInfo = Package:GetItem(Arg);
  if not itemInfo then
	  ToastMove:CreateToast('该物品不存在', Configuration.GreenColor);
  end

  local eatNum = 0;
  local expNum = resTableManager:GetValue(ResTable.drug, tostring(Arg), 'num');
  local curExp = currentRole.lvl.exp 
  for i = 1, itemInfo.num do
	  eatNum = eatNum + 1;
	  if curExp + expNum <= ActorManager.user_data.role.lvl.exp then
		  curExp = curExp + expNum;
		  i = i + 1;
	  else
		  return eatNum;
	  end
  end
  return eatNum;
end

function CardLvlupPanel:setInfo()
  if currentItemId then
    local eatNum = Package:GetItem(currentItemId).num; 
  end
end
function CardLvlupPanel:destoryLevelupSound()
	if upSound ~= nil then
		soundManager:DestroySource(upSound);
		upSound = nil
	end
end
function CardLvlupPanel:LevelUpSound()
	local randomNum = math.random(1,2)
	local soundName = resTableManager:GetValue(ResTable.actor,tostring(rolepid),'foster_voice')
	if soundName then
		self:destoryLevelupSound()
		upSound = SoundManager:PlayVoice( tostring(soundName[math.floor(randomNum)]))
	end
end
