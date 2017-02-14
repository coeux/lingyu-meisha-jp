--cardRankupPanel.lua
--========================================================================
--¿¨ÅÆÉýÐÇµ¯´°

CardRankupPanel =
{
};


--±äÁ¿
local currentRole;
local iconAll;
local curNum;
local AllNum;
local allbottomtable;
local roleicontable;
--¿Ø¼þ
local mainDesktop;
local cardRankupPanel;
local centerPanel;
local btnClose;
local cardRankupRole;
local bglinelist;
local consumItem;
local btnRankup;
local CurIcon;
local pieceInfo;
local richTextBox;
local font;
local recordNextPartnerInfoList;      --¼ÇÂ¼Éý¼¶ºóÊôÐÔµÄ±ä»¯ 
local partnerlv;
local timer;
local progressBar;
local roleName;
local desLabel;
local arrowImage ;
local  s_allcurPro, s_allnextPro = {};
local roleIconinfo;
local oldPro ={};

local recordBeforePartnerInfoList = {'atk', 'mgc', 'def', 'res', 'hp'};

--  点击英雄头像弹出对应获取路径
local obtainHeroPiecePanel
local closeBtn
local getBtn
local countPro
local obtainWay1
local obtainWay2
local obtainWay3
local heroPieceName
local unenoughLabel
local ownHeroPieceNum
local totalNeedHeroPieceNum
local piecePanel
local pingbiLayer
local pieceImg
local taskList = {}  --  任务列表
local scrollPanel
local stackPanel
local upSound
--³õÊ¼»¯Ãæ°å
function CardRankupPanel:InitPanel( desktop )
  --±äÁ¿³õÊ¼»¯
  eatType = 1;
  upSound = nil
  --½çÃæ³õÊ¼»¯	
  mainDesktop = desktop;		
  cardRankupPanel = Panel(desktop:GetLogicChild('UpStarPanel'));
  cardRankupPanel:IncRefCount();
  cardRankupPanel.Visibility = Visibility.Hidden;
  local icon1 = cardRankupPanel:GetLogicChild('Icon1');
  local icon2 = cardRankupPanel:GetLogicChild('Icon2');
  iconAll = {icon1, icon2};
  bglinelist = cardRankupPanel:GetLogicChild('BottomBgListClip'):GetLogicChild('cardList');
  btnRankup = cardRankupPanel:GetLogicChild('UpStarBtn');
  btnRankup:SubscribeScriptedEvent('Button::ClickEvent', 'CardRankupPanel:rankUp');
  local CurKaPaiPanel = cardRankupPanel:GetLogicChild('CurKaPaiPanel'); 
  curNum = CurKaPaiPanel:GetLogicChild('haveCurNum');   --µ±Ç°ËéÆ¬µÄÊýÁ¿
  AllNum = CurKaPaiPanel:GetLogicChild('haveAllNum');   --×ÜµÄËéÆ¬µÄÊýÁ¿
  CurIcon = CurKaPaiPanel:GetLogicChild('CurIcon');
  richTextBox = CurKaPaiPanel:GetLogicChild('richTextBox');
  progressBar = CurKaPaiPanel:GetLogicChild('level');
  roleName = cardRankupPanel:GetLogicChild('nameLabel');
  desLabel =  cardRankupPanel:GetLogicChild('describLabel');
  desLabel.Visibility =Visibility.Hidden;
  arrowImage = cardRankupPanel:GetLogicChild('arrowImg');
  self.isShow = false;
  font = uiSystem:FindFont('huakang_21_noborder');

  --  获取碎片面板初始化
  obtainHeroPiecePanel = cardRankupPanel:GetLogicChild('getHeroPanel'):GetLogicChild(0)
  closeBtn = obtainHeroPiecePanel:GetLogicChild('close')   --  关闭按钮
  getBtn = obtainHeroPiecePanel:GetLogicChild('getBtn')    --  获得按钮
  countPro = obtainHeroPiecePanel:GetLogicChild('countPro')   --  进度
  heroPieceName = obtainHeroPiecePanel:GetLogicChild('name')    --  碎片名字
  unenoughLabel = obtainHeroPiecePanel:GetLogicChild('unenough')     --  碎片不足
  ownHeroPieceNum = obtainHeroPiecePanel:GetLogicChild('have')          --  拥有碎片数量
  totalNeedHeroPieceNum = obtainHeroPiecePanel:GetLogicChild('total')       --  需要碎片的数量
  piecePanel = obtainHeroPiecePanel:GetLogicChild('piecePanel') --  碎片图片 
  scrollPanel = obtainHeroPiecePanel:GetLogicChild('scrollPanel')
  stackPanel = scrollPanel:GetLogicChild('getWayList')

  pingbiLayer = cardRankupPanel:GetLogicChild('bg')
  obtainHeroPiecePanel.Visibility =  Visibility.Hidden
  pingbiLayer.Visibility =  Visibility.Hidden

  cardRankupPanel:GetLogicChild('BottomBgListClip'):GetLogicChild(0).Background = CreateTextureBrush('home/bag_bg.ccz','godsSenki');
  CurKaPaiPanel.Background = CreateTextureBrush('home/home_cardlist_upgrade_item_bg.ccz','godsSenki');
  
end

--Ïú»Ù
function CardRankupPanel:Destroy()
  cardRankupPanel:DecRefCount();
  cardRankupPanel = nil;
end

function CardRankupPanel:getSelfPanel()
  return cardRankupPanel;
end

--ÏÔÊ¾
function CardRankupPanel:Show(roleindex, roleinfo)
  self.isShow = true;
    -- 适配
  if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
    local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
    cardRankupPanel:GetLogicChild('getHeroPanel').Translate = Vector2(350*(1-factor)+40,0);
  end
  --StoryBoard:ShowUIStoryBoard(cardRankupPanel, StoryBoardType.ShowUI1);  
  cardRankupPanel:SetUIStoryBoard("storyboard.showUIBoard2");  
  local roleindex = roleindex or 1;
  currentRole = roleinfo;
  roleicontable = {};
  for i = 1, 2 do                                              --³õÊ¼»¯ÉÏ·½µÄÁ½¸öÍ·Ïñ
    roleIconinfo = customUserControl.new(iconAll[i], 'cardHeadTemplate');
    if(currentRole.rank == 5) then
      roleIconinfo.initWithPid(currentRole.pid, 90);
      --desLabel.Visibility =Visibility.Visible;
      arrowImage.Visibility = Visibility.Hidden;
      roleName.Visibility = Visibility.Visible;
      roleName.Text = tostring(currentRole.name);
      iconAll[2].Visibility =Visibility.Hidden;
    else
      if i == 1 then
        roleIconinfo.initWithPid(currentRole.pid, 90);
      elseif i == 2 then
        roleIconinfo.initWithPid(currentRole.pid, 90, true);
      end
      --desLabel.Visibility =Visibility.Hidden;
      arrowImage.Visibility = Visibility.Visible;
      roleName.Visibility = Visibility.Hidden;
      iconAll[2].Visibility =Visibility.Visible;
    end
    roleicontable[i] = roleIconinfo;
  end
  CardRankupPanel:recordInfo(currentRole.pro);
  local bottominfo;
  allbottomtable = {};   --±£ÁôµÄÒýÓÃ
  bglinelist:RemoveAllChildren();  
  for i = 1, 5 do                                              --³õÊ¼»¯ÖÐ¼ä²¿·ÖµÄÎå¸öÊôÐÔ
    bottominfo = customUserControl.new(bglinelist, 'UpStar_BottomBgTemplate');
    bottominfo.initbg(i);

    bottominfo.initProperInfo(currentRole, i);
    allbottomtable[i] = bottominfo;
  end
  pieceInfo = customUserControl.new(CurIcon, 'itemTemplate');

  pieceInfo.initWithInfo(30000+roleindex,-1,65,false);
  pieceInfo.addExtraClickEvent(roleindex, 'CardRankupPanel:onHeroPieceClick');
  --³õÊ¼»¯¿¨ÅÆ×Ô¶¨Òå¿Ø¼þ²¢ÏÔÊ¾
  local rankUpRole = 
  {
    midImage = currentRole.midImage;
    lvl =
    {
      level = currentRole.lvl.level;
      lovelevel = currentRole.lvl.lovelevel;
    };
    skls = {};
    equips = {};	
    rank = currentRole.rank+1;
    attribute = currentRole.attribute;
  }

  partnerlv = tonumber(currentRole.lvl.level);
  --self:recordProperInfo(partnerlv, false);
  -- ÉèÖÃÏûºÄÊý¾Ý
  self:checkTranceNum();

  --ÏÔÊ¾Õû¸öÃæ°å
  cardRankupPanel.Visibility = Visibility.Visible;
  if UserGuidePanel:IsInGuidence(UserGuideIndex.upstar, 1) then
	  timerManager:CreateTimer(0.2, 'CardRankupPanel:upstarUserguide', 0, true)
  end
end

function CardRankupPanel:upstarUserguide()
	UserGuidePanel:ShowGuideShade( btnRankup,GuideEffectType.hand,GuideTipPos.right,'');
end

-- 显示获取英雄碎片的面板
function CardRankupPanel:onHeroPieceClick( Args )

  local resid =  Args.m_pControl.Tag
	cardRankupPanel:GetLogicChild('getHeroPanel').Visibility = Visibility.Visible;
  obtainHeroPiecePanel.Visibility = Visibility.Visible;
  getBtn.Visibility = Visibility.Hidden
  unenoughLabel.Visibility = Visibility.Hidden
  pingbiLayer.Visibility = Visibility.Visible 
  closeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'CardRankupPanel:onCloseClick')
  stackPanel:RemoveAllChildren()
  
  local it = customUserControl.new(piecePanel,'itemTemplate');
  it.initWithInfo(resid + 30000,-1,80);
  --  从role.txt表中获取英雄的所有信息
  local dataInfo = resTableManager:GetRowValue(ResTable.actor, tostring(resid))
  -- 设置英雄碎片姓名
  heroPieceName.Text = dataInfo['name']
  local stuffID = currentRole.resid * 10 + currentRole.rank + 1 + 1   -- 根据英雄当前星级从qualityup_stuff.txt表中获取下一星级所需要英雄碎片的数量
  if currentRole.rank == 5 then
    stuffID = currentRole.resid * 10 + 6
  end

  local stuffData = resTableManager:GetRowValue(ResTable.qualityup_stuff, tostring(stuffID))
  local chipId = 30000 + currentRole.resid
  local chipItem = Package:GetChip( chipId ) 
  local taskBtnList = {}
  local taskInfo = resTableManager:GetRowValue(ResTable.item_path, tostring(chipId))
  local count = 1
  while (taskInfo['path' .. count]) do
    count = count  + 1
  end
  count = count - 1
  for i=1,count do
    
    local btn = uiSystem:CreateControl('Button')
    btn.Size = Size(240, 40)
    taskBtnList[i] = btn
    stackPanel:AddChild(taskBtnList[i])
  end

  for index = 1, 3 do
	  obtainHeroPiecePanel:GetLogicChild('point'):GetLogicChild(tostring(index)).Visibility = Visibility.Hidden;
  end

  --  设置获取碎片路径，从item_path.txt表读取
  for index = 1,count do
    if taskInfo['path' .. index] ~= nil then
	    obtainHeroPiecePanel:GetLogicChild('point'):GetLogicChild(tostring(index)).Visibility = Visibility.Visible;
      local typeCount = taskInfo['path' .. index][1];
      if typeCount == 1 then
        taskBtnList[index].Pick = true
        taskBtnList[index].Font = uiSystem:FindFont('huakang_20_noborder_underline')
        taskBtnList[index].TextColor = QuadColor( Color(19, 169, 164,255)  )
        taskBtnList[index]:RemoveAllEventHandler()
        --  根据不同路径跳转到对应界面
        if taskInfo['path' .. index][2] <= 10 then  --  抽卡
    			taskBtnList[index].Tag = taskInfo['path' .. index][2];
    			taskBtnList[index]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardDetailPanel:GetMaterialPathItem')
        else
          --  通过关卡判断是否开启获取，需要获取所有掉落该英雄碎片的关卡，然后判断D
          if taskInfo['path' .. index][2] > 1000 and taskInfo['path' .. index][2] < 5000 then     --  普通副本
            if ActorManager.user_data.round.openRoundId < taskInfo['path' .. index][2] then
              taskBtnList[index].Font = uiSystem:FindFont('huakang_20_noborder')
              taskBtnList[index].TextColor = QuadColor( Color(19, 169, 164,255)  )
              taskBtnList[index]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardDetailPanel:roundNotOpen')
            else
              taskBtnList[index].Tag = index
              taskBtnList[index]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardRankupPanel:TaskClick')
              taskList[index] = taskInfo['path' .. index][2]
            end
          elseif taskInfo['path' .. index][2] > 5000 then   --  精英副本
            if ActorManager.user_data.round.elite_roundid < taskInfo['path' .. index][2] then
              taskBtnList[index].Font = uiSystem:FindFont('huakang_20_noborder')
              taskBtnList[index].TextColor = QuadColor( Color(19, 169, 164,255)  )
              taskBtnList[index]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardDetailPanel:roundNotOpen')
            else
              taskBtnList[index].Tag = index
              taskBtnList[index]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardRankupPanel:TaskClick')
              taskList[index] = taskInfo['path' .. index][2]
            end
          end
        end
      elseif typeCount == 0 then
        taskBtnList[index].Pick = false
        taskBtnList[index].Font = uiSystem:FindFont('huakang_20_noborder')
        taskBtnList[index].TextColor = QuadColor( Color(0, 0, 0,255) )
      end
      taskBtnList[index].Text = taskInfo['path_description' .. index]
      taskBtnList[index].Visibility = Visibility.Visible;
    else
      taskBtnList[index].Visibility = Visibility.Hidden;
    end
  end
  stackPanel.VScrollPos = 0
  --  设置进度条
  if chipItem then
    ownHeroPieceNum.Text = tostring(chipItem.count)
    totalNeedHeroPieceNum.Text = tostring(stuffData['var1'])   
    if(tonumber(ownHeroPieceNum.Text) < tonumber(totalNeedHeroPieceNum.Text)) then
      countPro.CurValue = chipItem.count
      ownHeroPieceNum.TextColor = QuadColor( Color(255, 0, 0, 255) )
    else
      countPro.CurValue = stuffData['var1']
      ownHeroPieceNum.TextColor = QuadColor( Color(0, 255, 0, 255) )
    end
  else
    ownHeroPieceNum.Text = tostring(0);
    totalNeedHeroPieceNum.Text = tostring(stuffData['var1']);
    countPro.CurValue = 0 
  end
  countPro.MaxValue = stuffData['var1']
  
end

function CardRankupPanel:refreshHaveCount()
  if not currentRole then
	  --异常处理
	  return
  end
  local stuffID = currentRole.resid * 10 + currentRole.rank + 1 + 1   -- 根据英雄当前星级从qualityup_stuff.txt表中获取下一星级所需要英雄碎片的数量
  if currentRole.rank == 5 then
    stuffID = currentRole.resid * 10 + 6
  end

  local stuffData = resTableManager:GetRowValue(ResTable.qualityup_stuff, tostring(stuffID))
  local chipId = 30000 + currentRole.resid
  local chipItem = Package:GetChip( chipId ) 
  if chipItem then
    ownHeroPieceNum.Text = tostring(chipItem.count)
    totalNeedHeroPieceNum.Text = tostring(stuffData['var1'])   
    if(tonumber(ownHeroPieceNum.Text) < tonumber(totalNeedHeroPieceNum.Text)) then
      countPro.CurValue = chipItem.count
      ownHeroPieceNum.TextColor = QuadColor( Color(255, 0, 0, 255) )
    else
      countPro.CurValue = stuffData['var1']
      ownHeroPieceNum.TextColor = QuadColor( Color(0, 255, 0, 255) )
    end
  else
    ownHeroPieceNum.Text = tostring(0);
    totalNeedHeroPieceNum.Text = tostring(stuffData['var1']);
    countPro.CurValue = 0 
  end
  countPro.MaxValue = stuffData['var1']
end

--关闭按钮
function CardRankupPanel:onCloseClick()
  self:checkTranceNum()
	cardRankupPanel:GetLogicChild('getHeroPanel').Visibility = Visibility.Hidden;
  obtainHeroPiecePanel.Visibility = Visibility.Hidden;
  pingbiLayer.Visibility = Visibility.Hidden;
end

function CardRankupPanel:TaskClick(args)
  -- cardRankupPanel:GetLogicChild('getHeroPanel').Visibility = Visibility.Hidden;
  -- pingbiLayer.Visibility = Visibility.Hidden;
  -- HomePanel:onLeaveHomePanel()
  local index = args.m_pControl.Tag;
  PveBarrierPanel:OpenToPage(taskList[index]);
end

-- 任务跳转
function CardRankupPanel:gotoObtainHeroPiecePanel(args)
  local index = args.m_pControl.Tag;
  PveBarrierPanel:OpenToPage(taskList[index])
end

function CardRankupPanel:checkTranceNum()
  richTextBox:RemoveAllChildren();

  local stuffID = currentRole.resid * 10 + currentRole.rank + 1 + 1;	
  if currentRole.rank == 5 then
    stuffID = currentRole.resid * 10 + 6;	
  end
  local stuffData = resTableManager:GetRowValue(ResTable.qualityup_stuff, tostring(stuffID));
  --ÅÐ¶ÏËéÆ¬ÊýÁ¿
  local chipId = tostring(30000 + currentRole.resid);
  local chipItem = Package:GetChip(tonumber(chipId));
  if chipItem then
    curNum.Text = tostring(chipItem.count);
    AllNum.Text = tostring(stuffData['var1']);	
	progressBar.MaxValue =  tonumber(AllNum.Text);
    if(tonumber(curNum.Text) < tonumber(AllNum.Text)) then
      progressBar.CurValue = tonumber(curNum.Text);
      curNum.TextColor = Configuration.RedColor;
    else
      progressBar.CurValue = tonumber(AllNum.Text);
      curNum.TextColor = Configuration.GreenColor;
    end

    richTextBox:AddText(curNum.Text,  curNum.TextColor, font);
    richTextBox:AddText('/', Configuration.GrayColor, font);
    richTextBox:AddText(AllNum.Text, Configuration.GrayColor, font);         
    if chipItem.count >= stuffData['var1'] and currentRole.rank < Configuration.RoleMaxStarNum then
    	btnRankup.Enable = true;
    else
    	btnRankup.Enable = false;
    end
  else
    AllNum.Text = tostring(stuffData['var1']);
    richTextBox:AddText('0', Configuration.RedColor, font);
    richTextBox:AddText('/', Configuration.GrayColor, font);
    richTextBox:AddText(AllNum.Text, Configuration.GrayColor, font);	
    progressBar.CurValue = 0;
    progressBar.MaxValue = tonumber(AllNum.Text); 
    btnRankup.Enable = false;
  end
end

--Òþ²Ø
function CardRankupPanel:Hide()
  self.isShow = false;
  --Ïú»ÙÉú³ÉµÄ×Ô¶¨Òå¿Ø¼þ
  cardRankupPanel.Visibility = Visibility.Hidden;	
  CardDetailPanel:refreshFp();
end

function CardRankupPanel:showPanel( )
  self.isShow = true;
  --Ïú»ÙÉú³ÉµÄ×Ô¶¨Òå¿Ø¼þ
  cardRankupPanel.Visibility = Visibility.Visible;	
end

function CardRankupPanel:recordProperInfo(nextstate)  --¼ÇÂ¼Ò»ÏÂËùÓÐÎï·ÀºÍ ÉúÃüµÈÐÅÏ¢
  if(nextstate) then                          
    timer = timerManager:CreateTimer(0.8, 'CardRankupPanel:makeTimer', 1);
  end
end
local properinfowolrd = {'ÉúÃü', 'Îï¹¥', '¼¼¹¥', 'Îï·À', '¼¼·À'};
local time = 0;
function CardRankupPanel:makeTimer()
  time = time + 1;
  if(time <= 5)  then
    ToastMove:CreateToast(properinfowolrd[time]..' '.. '+'..'%'..s_allcurPro[time] * 100 - s_allnextPro[time] * 100, Configuration.GreenColor);
  else
    timerManager:DestroyTimer(timer);
    time = 0;
  end
end

--Éý½×ÒÔºó·þÎñÆ÷»Øµ÷Ë¢ÐÂ
function CardRankupPanel:Refresh(role)
  if(currentRole.rank == 5) then
    iconAll[2].Visibility =Visibility.Hidden;
    arrowImage.Visibility = Visibility.Hidden;
    roleName.Visibility = Visibility.Visible;
    roleName.Text = tostring(currentRole.name);
    --desLabel.Visibility =Visibility.Visible;
    roleicontable[1].initWithPid(currentRole.pid, 90);
  else
    for i = 1, #roleicontable do   
      if i == 1 then
        roleicontable[1].initWithPid(currentRole.pid, 90);
      elseif i == 2 then
        roleicontable[2].initWithPid(currentRole.pid, 90, true);
      end
    end
  end

  for i = 1, #allbottomtable do                --Ë¢ÐÂµ×²¿µÄÊôÐÔÐÅÏ¢
    allbottomtable[i].initProperInfo(role, i);
  end

  local roleindex = role.resid; 
  pieceInfo.initWithInfo(30000+roleindex,-1,65,false);
  pieceInfo.addExtraClickEvent(roleindex, 'CardRankupPanel:onHeroPieceClick');
  -- self:recordProperInfo(true);
  -- ÉèÖÃÏûºÄÊý¾Ý
  self:checkTranceNum();
  --local voicePath = resTableManager:GetValue(ResTable.actor, tostring(currentRole.pid), 'voice');
  --SoundManager:PlayVoice(tostring(voicePath));
end

function CardRankupPanel:recordProperInfo(nextRole) 
  for i = 1, #recordBeforePartnerInfoList do
	  local addCount = tonumber(nextRole.pro[recordBeforePartnerInfoList[i]]) -tonumber(oldPro[recordBeforePartnerInfoList[i]])
	  if addCount > 0 then
		  ToastMove:CreateToast(GemWord[i] ..'+'..' '.. addCount, Configuration.GreenColor);
	  end
  end
  CardRankupPanel:recordInfo(nextRole.pro);
end

function CardRankupPanel:upCardRankUpCallBack(msg)
  if(currentRole.rank == 5) then
    btnRankup.Enable = false;     
  end
end

--ÊÂ¼þ
function CardRankupPanel:onClose()
  self:Hide();
end

function CardRankupPanel:rankUp()
  local msg = {};
  msg.pid = currentRole.pid;
  Network:Send(NetworkCmdType.req_quality_up, msg);
  PlayEffectScale('shengji_output/', Rect(240,30,0,0), 'shengji', 4, 4, HomePanel:returnHomePanel():GetLogicChild('navi'));
end

function CardRankupPanel:success()
  local effect = PlayEffectLT('shengxingchenggong_output/', Rect(bglinelist:GetAbsTranslate().x + bglinelist.Width * 0.5 , bglinelist:GetAbsTranslate().y + bglinelist.Height * 0.5, 0, 0), 'shengxingchenggong');
  effect:SetScale(2, 2);

  --更新角色进阶提示信息
  CardListPanel:UpdateRankUpTip();

  --  更新战斗力
  uiSystem:UpdateDataBind()
end


--某角色是否可以进阶
function CardRankupPanel:isRoleCanAdvance( role )
	local actorCanAdvance = true;
	--是否满星
	if role.rank >= Configuration.RoleMaxStarNum then
		return false;
	end
	--设置消耗数据
	local stuffID = role.resid * 10 + role.quality + 2;	
	local stuffData = resTableManager:GetRowValue(ResTable.qualityup_stuff, tostring(stuffID));

	--判断碎片数量
	local chipId = 30000 + stuffData['resid'];
	local chipItem = Package:GetChip(tonumber(chipId));	
	if (chipItem == nil or chipItem.count < stuffData['var1']) and stuffData['var1'] ~= 0 then
		return false;
	end
	return actorCanAdvance;
end

--是否有角色可以进阶
function CardRankupPanel:IsHaveRoleCanAdv()
	for _,roleinfo in ipairs(ActorManager.user_data.partners) do
		if CardRankupPanel:isRoleCanAdvance(roleinfo) then
			TipFlag:UpdateFlagRankUp(true);
			return;
		end
	end
	if CardRankupPanel:isRoleCanAdvance(ActorManager.user_data.role) then
		TipFlag:UpdateFlagRankUp(true);
		return;
	end
	TipFlag:UpdateFlagRankUp(false);
	return;
end

 --记录一下所有物防和 生命等信息
function CardRankupPanel:recordInfo(proInfo)  --记录一下所有物防和 生命等信息
	for i = 1, #recordBeforePartnerInfoList do
		oldPro[recordBeforePartnerInfoList[i]] = proInfo[recordBeforePartnerInfoList[i]];
	end
end
function CardRankupPanel:destroyStarUpgradeSound()
	if upSound ~= nil then
		soundManager:DestroySource(upSound);
		upSound = nil
	end
end
function CardRankupPanel:StarUpgradeSound(resid)
	local randomNum = math.random(1,2)
	local soundName = resTableManager:GetValue(ResTable.actor,tostring(resid),'foster_voice')
	if soundName then
		self:destroyStarUpgradeSound()
		upSound = SoundManager:PlayVoice( tostring(soundName[math.floor(randomNum)]))
	end
end

function CardRankupPanel:isVisible()
  return cardRankupPanel.Visibility == Visibility.Visible;
end