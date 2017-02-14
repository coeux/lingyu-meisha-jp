--taskDialogPanel.lua
--========================================================================
--NPC对话界面
TaskDialogPanel =
{
  signYMD; -- 编年史签到日期
  iChronicle; -- 编年史对话
  iLoveTask; -- 爱恋度对话（爱恋度面板）
  iLoveTaskFromCardPanel; -- 爱恋度对话（卡牌详情面板）
  iFinished; -- 对话完成
  iNovice; -- 旷世大战(新手引导)
  iTest; -- 测试

  isTaskDialogPanelOpen = false;
  isDoFirstTask         = false;
  hidNameAndImg = false;
};

--控件
local mainDesktop;
local taskDialogPanel;
local leftPanel;
local lImage;
local lName;
local rightPanel;
local rImage;
local rName;
local gButton;
local content;
local btnSkip;
local shadow;
local selectPanel;
local option = {};

--变量
local leftId;
local rightId;
local leftScale;
local rightScale;
local  leftDirc;
local rightDirc;
local tasks = {};
local whospeak;
local None = -1;
local Mine = 0;
local MainHero = 0;
local Player = -2;
local z;
local cdTimer;
local optionId = {};
local plotId;
local taskId;
local isSkip;
local isOption;
local currentTask;
local npcSound;

local animationPanel;
local armatureFront;
local armatureAfter;
local armatureAfter;

local midPanel; 
local midImg;   
local namePanel;
local midName;  
--================================================================================
--基本初始化
--
--初始化
function TaskDialogPanel:InitPanel(desktop)
	self.loveComplete = false
	npcSound = nil
  --变量初始化
  rightId = ActorManager.user_data.role.resid; -- 默认右端人物为玩家本人
  whospeak = TaskWhoSpeak.Left; --默认说话人为NPC
  isSkip = false;
  isOption = false;
  self.hidNameAndImg = false;
  --
  --界面初始化
  mainDesktop = desktop;
  taskDialogPanel = Panel(desktop:GetLogicChild('scenarioPanel'));
  taskDialogPanel:IncRefCount();

  leftPanel = Panel(taskDialogPanel:GetLogicChild('leftPanel'));
  lImage = ImageElement(leftPanel:GetLogicChild('leftImage'));
  lName = Label(leftPanel:GetLogicChild('leftName'));
  rightPanel = Panel(taskDialogPanel:GetLogicChild('rightPanel'));
  rImage = ImageElement(rightPanel:GetLogicChild('rightImage'));
  rName = Label(rightPanel:GetLogicChild('rightName'));
  btnSkip = Button(taskDialogPanel:GetLogicChild('btnSkip'));
  btnSkip:SubscribeScriptedEvent('Button::ClickEvent', 'TaskDialogPanel:onSkip');
  btnSkip.Zorder = 1000;
  gButton = Button(taskDialogPanel:GetLogicChild('scenarioBtn'));
  gButton:SubscribeScriptedEvent('Button::ClickEvent', 'TaskDialogPanel:onNext');
  content = Label(taskDialogPanel:GetLogicChild('scpanel1'):GetLogicChild(0):GetLogicChild('scenarioInfo'));
  selectPanel = taskDialogPanel:GetLogicChild('selectPanel');

  --新居中立绘
  midPanel  = taskDialogPanel:GetLogicChild('midPanel');
  midImg    = midPanel:GetLogicChild('midImg');
  namePanel = taskDialogPanel:GetLogicChild('namePanel');
  midName   = namePanel:GetLogicChild('midName');

  --选项初始化
  for i=1, 5 do
    local btn = selectPanel:GetLogicChild('choiceBtn' .. i);
    btn:SubscribeScriptedEvent('Button::ClickEvent', 'TaskDialogPanel:onOptionClick');
    btn.Tag = i;
    table.insert(option, btn);
  end
  shadow = BrushElement(taskDialogPanel:GetLogicChild('shadow'));
  z = shadow.ZOrder;

  taskDialogPanel.Visibility = Visibility.Hidden;
end

--显示
function TaskDialogPanel:Show()
  iFinished = false;
  self:onNext();

  --新手引导处理guidechange
  if Task:getMainTaskId() < 100003 then
	  shadow.Background = CreateTextureBrush('background/open_talk.jpg', 'background');
	  shadow.Opacity = 1;
  else
	  --shadow.Background = Converter.String2Brush("EidolonSystem.Black")
	  --shadow.Opacity = 0.75;
  end

  --新手引导处理
  if taskDialogPanel.Visibility == Visibility.Hidden then
    if Task:getMainTaskId() < 100003 then
	     shadow.Visibility = Visibility.Visible; -- 自带遮罩
    else
        shadow.Visibility = Visibility.Hidden;
    end
	  --设置模式对话框
	  mainDesktop:DoModal(taskDialogPanel);
	  --增加UI弹出时候的效果
	  StoryBoard:ShowUIStoryBoard(taskDialogPanel, StoryBoardType.ShowUI1);
  end

  self.isTaskDialogPanelOpen = true
end

--隐藏
function TaskDialogPanel:Hide()
  isSkip = false;
  
  --新手引导特殊处理guidechange
  if not (Task:getMainTaskId() == 100001 or Task:getMainTaskId() == 100002) then
	shadow.Visibility = Visibility.Hidden;
	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(taskDialogPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');
  end
  self.isTaskDialogPanelOpen = false
end

--关闭
function TaskDialogPanel:onClose()
      MainUI:Pop();
end

--销毁
function TaskDialogPanel:Destroy()
  taskDialogPanel:DecRefCount();
  taskDialogPanel = nil;
end
--================================================================================
--UI逻辑（公用对话方式）
--
--====================================
-- 剧情人物形象
-- panel: 人物形象panel
-- image: 人物形象image
-- zo:     人物形象ZOrder
-- scale: 人物形象缩放比例
-- dirc:   人物形象面朝方向(+1:不进行左右翻转, -1:左右翻转)
-- 注：每次刷新后leftId or rightId 被置为None
--====================================
function TaskDialogPanel:RefreshUI(panel, image, zo, scale, dirc)
  self:Refresh(scale,dirc);
  panel.Visibility = Visibility.Hidden;
  --if not zo then return end;
  --image.ZOrder, panel.Visibility = zo, Visibility.Visible;
end

--人物刷新
function TaskDialogPanel:Refresh(scale, dirc)
	local data;
  --print('leftId->'..tostring(leftId)..' rightId->'..tostring(rightId));

  if self.hidNameAndImg then
    midImg.Image = nil;
    namePanel.Visibility = Visibility.Hidden;
  end
	if leftId ~= None and whospeak == TaskWhoSpeak.Left then
		if leftId == MainHero then
			data = resTableManager:GetRowValue(ResTable.actor, tostring(ActorManager.user_data.role.resid));
			midImg.Image = GetPicture('navi/' .. ActorManager.user_data.role.roleImage .. '.ccz');
			midName.Text = data['name'];
		elseif leftId == Player then
			midImg.Image = nil;
			--midName.Text = 'Main Hero';
			midName.Text = tostring(ActorManager.user_data.role.name);
		else
			data = resTableManager:GetRowValue(ResTable.npc, tostring(leftId));
			midImg.Image = GetPicture('navi/' .. data['portrait'] .. '.ccz');
			midName.Text = data['name'];
		end
		local sc = scale and scale or 1;
		local di = dirc and dirc or 1;
		--midImg:SetScale(di*sc, sc);
		leftId = None;
    namePanel.Visibility = Visibility.Visible;
	end
	if rightId ~= None and whospeak == TaskWhoSpeak.Right then
		if rightId == MainHero then
			data = resTableManager:GetRowValue(ResTable.actor, tostring(ActorManager.user_data.role.resid));
			midImg.Image = GetPicture('navi/' .. ActorManager.user_data.role.roleImage .. '.ccz');
			midName.Text = data['name'];
		elseif rightId == Player then
			midImg.Image = nil;
			--midName.Text = 'Main Hero';
			midName.Text = tostring(ActorManager.user_data.role.name);
		else
			data = resTableManager:GetRowValue(ResTable.npc, tostring(leftId));
			data = resTableManager:GetRowValue(ResTable.npc, tostring(rightId));
			midImg.Image = GetPicture('navi/' .. data['portrait'] .. '.ccz');
			midName.Text = data['name'];
		end
		local sc = scale and scale or 1;
		local di = dirc and dirc or 1;
		--midImg:SetScale(di*sc, sc);
    namePanel.Visibility = Visibility.Visible;
	end
end

--对话跳转（屏幕点击）
function TaskDialogPanel:onNext()
  --对话终止
  if iFinished then
    if cdTimer then
      timerManager:DestroyTimer(cdTimer);
      cdTimer, isSkip = nil, nil;
    end
    return
  end;
  --普通对话
  if not taskId then
    self:NormalDialog();
    return ;
  end
  --对话完成
  if plotId == None then
  	if LovePanel.loveStorySound then
  		soundManager:DestroySource(LovePanel.loveStorySound);
  		LovePanel.loveStorySound = nil
  	end
    if npcSound then
  		soundManager:DestroySource(npcSound);
  		npcSound = nil
	  end
    iFinished = true;
    self:finishDialog();
	  if self.loveComplete then --觉醒动画显示
  		LovePanel:showAnimation()
  		self.loveComplete = false
	  end
    return ;
  end

  local plot = resTableManager:GetRowValue(ResTable.plot, tostring(plotId));
  if not plot then
    self:onClose();
    MessageBox:ShowDialog(MessageBoxType.Ok, string.format(LANG_taskDialogPanel_15, tostring(plotId)));
    return;
  end
  if npcSound ~= nil then
	soundManager:DestroySource(npcSound);
	npcSound = nil
  end
  local voiceStr = string.gsub(plot['voice'], "^%s*(.-)%s*$", "%1")
  if string.len(voiceStr)>1 then
	npcSound = SoundManager:PlayVoice( tostring(plot['voice']))
  end
  if not isSkip then 
    content.Text = plot['content']
  end
  --对话里用**表示主角名字，##表示根据主角性别来称呼
  local isLookStar = true
  local isLookHarshKey = true
  local strResult = plot['content']
  while string.find(strResult,"*") and isLookStar do
    strResult,isLookStar = self:changeStr(strResult,'*')
    -- print("IIIIIIIIIIIIIIIII = ",isLookStar)
  end

  while string.find(strResult,"#") and isLookHarshKey do
    strResult,isLookHarshKey = self:changeStr(strResult,'#')
    -- print("UUUUUUUUUUUUUUUUUU = ",isLookHarshKey )
  end

  if strResult and not isSkip then
    content.Text = tostring(strResult)
  end

  whospeak = plot['whospeak'];
  leftId, rightId = plot['role_id'][1], plot['role_id'][2];
  leftScale, rightScale = plot['scale'][1], plot['scale'][2];
  leftDirc, rightDirc = plot['dirc'][1],plot['dirc'][2];
  --print('plotId->'..tostring(plotId)..' leftId->'..tostring(leftId)..' rightId->'..tostring(rightId));
  --print('whospeak->'..tostring(whospeak));
  if not isSkip then
    self.hidNameAndImg = false;
    if leftId == None and rightId == None then
        self.hidNameAndImg = true;
    end
    self:RefreshUI(leftPanel, leftPanel, leftId ~= None and z + (whospeak == TaskWhoSpeak.Left and 1 or -1), leftScale, leftDirc);
    self:RefreshUI(rightPanel, rightPanel, rightId ~= None and z + (whospeak == TaskWhoSpeak.Right and 1 or -1), rightScale, rightScale);
  end
  --声音---------------
  --local whoVoice = leftId ~= None and leftId or rightId;
    --local data = resTableManager:GetValue(ResTable.npc, tostring(), 'vioce');
    --SoundManager:PlayVoice(data);
  --声音---------------

  --后续行为
  for i=1, 5 do
    selectPanel.Visibility = Visibility.Visible;
    option[i].Visibility = Visibility.Hidden;
  end
  if #plot['next_type'] == 1 then -- 无选项
    local enum = plot['next_type'][1];
    local id = plot['next_id'][1];
    plotId = enum == 1 and id or -1;
    taskId = enum == 2 and id or -1;
    btnSkip.Visibility = Visibility.Visible;
    isOption = false;
    selectPanel.Visibility = Visibility.Hidden;
  else
    if cdTimer then
      timerManager:DestroyTimer(cdTimer);
      cdTimer, isSkip = nil, nil;
    end
    for i, v in ipairs(plot['next_type']) do
      local enum = tonumber(plot['next_type'][i]);
      local id = tonumber(plot['next_id'][i]);
      optionId[i] = {};
      optionId[i].plotId = enum == 1 and id or -1;
      optionId[i].taskId = enum == 2 and id or -1;
      option[i].Text = plot['option' .. i];
      option[i].Visibility = Visibility.Visible;
    end
    btnSkip.Visibility = Visibility.Hidden;
    isOption = true;
  end

  local tempTime = 0.2
  if isSkip then 
    tempTime = 0
  end

  if isSkip and not cdTimer then
    cdTimer = timerManager:CreateTimer(tempTime, 'TaskDialogPanel:onNext', 0);
  end
end


function TaskDialogPanel:changeStr( content, dest)
  local str1
  local str2
  local index1
  local index2
  local str
  local isFind2 = false
  index1 = string.find(content,dest)
  if index1 then
    str = string.sub(content,1,index1-1) .. string.sub(content,index1+1,-1)  --  去掉第一个*
  end
  if str then
    index2 = string.find(str,dest)
  end
  --  替换主角名字
  if index1 and index2 and index2 == index1 then  --两个**相连
    isFind2 = true
    str1 = string.sub(content,1,index1-1)
    str2 = string.sub(content,index1+2,-1)
    if not str1 then
      str1 = ''
    end
    if not str2 then
      str2 = ''
    end
    if dest == "#" then
       if tonumber(ActorManager.user_data.role.resid) == 103 then
        str = str1.. LANG_chenghu_boy .. str2
      else
        str = str1.. LANG_chenghu_girl .. str2
      end
    elseif dest == "*" then
      str = str1.. ActorManager.user_data.role.name .. str2
    end
  else
    -- 如果没有找到**，则将str还原
    str = content
    isFind2 = false
  end
  return str,isFind2
end

--跳过对话
function TaskDialogPanel:onSkip()
  if isOption then return end;
  isSkip = true;
  self:onNext();
end

--选择选项
function TaskDialogPanel:onOptionClick(Args)
  local args = UIControlEventArgs(Args);
  plotId = optionId[args.m_pControl.Tag].plotId;
  taskId = optionId[args.m_pControl.Tag].taskId;
  self:onNext();
end

--结束对话
function TaskDialogPanel:finishDialog()
  if taskId ~= None then
    if self.iChronicle then -- 请求完成当日编年史任务
      NetworkMsg_Chronicle:reqChronicleSign(self.signYMD);
      self.iChronicle = nil;
    elseif self.iLoveTask then --恢复Panel
      --判断是否是最后一个觉醒任务
      if LovePanel.love_stage == 4 then
        --更换背景图
        HomePanel:changeNaviPic(LovePanel.pid);
        local role = ActorManager:GetRole(LovePanel.pid);
        local naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(role.resid + 10000));
        role.headImage = naviInfo['role_path_icon'];
      end
      self.iLoveTask = nil;
    elseif self.iLoveTaskFromCardPanel then -- 恢复panel
      CardDetailPanel:backToPanel();
      self.iLoveTaskFromCardPanel = nil;
    elseif self.iTest then
      self.iTest = nil;
    elseif self.iNovice then
      self.iNovice = nil;
      FightUIManager:Active();
      MainUI:ShowMainUI();
      PlotManager:Continue();
    else -- 正常接交任务
      if Task.TaskUnreceive == currentTask.step then
        local msg = {};
        msg.resid = currentTask.id;
        Network:Send(NetworkCmdType.req_get_task, msg);
        --向服务器发送统计数据
        if msg.resid <= MenuOpenLevel.statistics then
          NetworkMsg_GodsSenki:SendStatisticsData(msg.resid, 1);
        end
      elseif Task:isComplete(currentTask) then
        self:requestCommitTask();
      end
    end
  end
  self:onClose();
end

function TaskDialogPanel:NpcShopClick()
  self:onClose();
  -- NpcShopPanel:OpenNormalClick();
  ShopSetPanel:show(ShopSetType.mysteryShop)
end

function TaskDialogPanel:SpShopClick()
  self:onClose();
  -- NpcShopPanel:OpenSpecialClick();
  ShopSetPanel:show(ShopSetType.specialShop)
end


function TaskDialogPanel:ChipSmashClick()
  self:onClose();
  ChipSmashPanel:onShow()
end
--================================================================================
--<1> NPC无可接、可交任务时
--
--普通对话
function TaskDialogPanel:NormalDialog()
  local npcId = leftId;
  local data = resTableManager:GetValue(ResTable.npc, tostring(leftId), {'dialogue', 'scale', 'dirc','vioce'});
  if MainUI:GetSceneType() == SceneType.MainCity and data['vioce']then
	npcSound = SoundManager:PlayVoice(tostring(data['vioce']));
  end
  rightId = None;
  self.hidNameAndImg = false;
    if leftId == None and rightId == None then
        self.hidNameAndImg = true;
    end
  whospeak = TaskWhoSpeak.Left;
  --print('NormalDialog-leftId->'..tostring(leftId));
  self:RefreshUI(leftPanel, leftPanel, z + 1, data['scale'], data['dirc']);
  self:RefreshUI(rightPanel, rightPanel, nil);
  btnSkip.Visibility = Visibility.Hidden;
  content.Text = data['dialogue'];
   --对话里用**表示主角名字，##表示根据主角性别来称呼
  local isLookStar = true
  local isLookHarshKey = true
  local strResult = data['dialogue']
  while string.find(strResult,"*") and isLookStar do
    strResult,isLookStar = self:changeStr(strResult,'*')
  end

  while string.find(strResult,"#") and isLookHarshKey do
    strResult,isLookHarshKey = self:changeStr(strResult,'#')
  end

  if strResult then
    content.Text = tostring(strResult)
  end


  taskId, plotId = None, None;
  if npcId == 103 then
    selectPanel.Visibility = Visibility.Visible;
    option[4].Visibility = Visibility.Visible;
    option[4].Text = LANG_TaskDialogPanel_1;
    option[4]:RemoveAllEventHandler();
    option[4]:SubscribeScriptedEvent('Button::ClickEvent', 'TaskDialogPanel:NpcShopClick');
    option[5].Visibility = Visibility.Visible;
    option[5].Text = LANG_TaskDialogPanel_2;
    option[5]:RemoveAllEventHandler();
    option[5]:SubscribeScriptedEvent('Button::ClickEvent', 'TaskDialogPanel:onClose');
  elseif npcId == 123 then
    selectPanel.Visibility = Visibility.Visible;
    option[4].Visibility = Visibility.Visible;
    option[4].Text = LANG_TaskDialogPanel_3;
    option[4]:RemoveAllEventHandler();
    option[4]:SubscribeScriptedEvent('Button::ClickEvent', 'TaskDialogPanel:SpShopClick');
    option[5].Visibility = Visibility.Visible;
    option[5].Text = LANG_TaskDialogPanel_4;
    option[5]:RemoveAllEventHandler();
    option[5]:SubscribeScriptedEvent('Button::ClickEvent', 'TaskDialogPanel:onClose');
  elseif npcId == 110 then
    selectPanel.Visibility = Visibility.Visible;
    option[4].Visibility = Visibility.Visible;
    option[4].Text = LANG_TaskDialogPanel_5;
    option[4]:RemoveAllEventHandler();
    option[4]:SubscribeScriptedEvent('Button::ClickEvent', 'TaskDialogPanel:ChipSmashClick');
    option[5].Visibility = Visibility.Visible;
    option[5].Text = LANG_TaskDialogPanel_6;
    option[5]:RemoveAllEventHandler();
    option[5]:SubscribeScriptedEvent('Button::ClickEvent', 'TaskDialogPanel:onClose');
  else
    selectPanel.Visibility = Visibility.Hidden;
    option[1].Visibility = Visibility.Hidden;
    option[2].Visibility = Visibility.Hidden;
    option[3].Visibility = Visibility.Hidden;
  end
end
--
--================================================================================
--<2> NPC接交任务逻辑处理
--
--（寻路找到NPC）显示对话UI
function TaskDialogPanel:onShowDialog()
  leftId = Task.currentNpc;
  tasks = Task:GetTasksByNpc(leftId);

  --无任务
  if #tasks == 0 then
    taskId = nil;
  else
    --先获得剧情ID
    currentTask = tasks[1];
    taskId = currentTask.id;
    --local data = resTableManager:GetRowValue(ResTable.new_task, tostring(taskId));
    local data = resTableManager:GetRowValue(ResTable.task, tostring(taskId));

    if not data and FightManager.mFightType == FightType.noviceBattle and not self.isDoFirstTask then
      data = resTableManager:GetRowValue(ResTable.task, tostring(100001))
      self.isDoFirstTask = true
      -- print("TTTTTTTTTTTTTTTTTTT")
    end
    --完成任务
    if Task:isComplete(currentTask) then
      plotId = data['finish_plot_id'];
      if(plotId == 100011) then
      --  self.recordIdByUserGuideState = true;
      end
    --领取任务
    elseif ActorManager.user_data.role.lvl.level >= data['level'] and currentTask.step == Task.TaskUnreceive then
      plotId = data['plot_id'];
    --未完成 和 不可领取
    else
      taskId = nil;
    end
  end
  MainUI:PopAll();
  MainUI:Push(self);
end

--弹出NPC对话框（寻找NPC和当前NPC同一个人，交接任务）
function TaskDialogPanel:onPopUpNpcDialog()
  self:onShowDialog();
  ActorManager.hero:SetFindPathType(FindPathType.no);
  TaskFindPathPanel:Hide();
end

--接完任务后的处理
function TaskDialogPanel:AfterGetTask()
  Task:UpdateMainSceneUI();
  TaskAcceptAndRewardPanel:AcceptTask(currentTask);
end

--提交任务
function TaskDialogPanel:requestCommitTask()
  local msg = {};
  msg.resid = currentTask.id;
  msg.next_id = taskId;
  Network:Send(NetworkCmdType.req_commit_task, msg);

  --向服务器发送统计数据
  if msg.resid <= MenuOpenLevel.statistics then
    NetworkMsg_GodsSenki:SendStatisticsData(msg.resid, 2);
  end
end

--交任务后的处理
function TaskDialogPanel:AfterCommitTask(taskid)
  TaskAcceptAndRewardPanel:FinishTask(currentTask);
  tasks = Task:GetTasksByNpc(npcid);
  if false == TableIsEmpty(tasks) then
    -- self:onShowNpcDialog();
  end
end
--
--================================================================================
--<3> 任务完成特殊对话（无选项）
--
function TaskDialogPanel:FinishTaskSpecialDialog()
  if not Task.newDoneTask then return end;
  taskId = None;
  local data = resTableManager:GetValue(ResTable.task, tostring(Task.newDoneTask.id), {'trigger_type', 'trigger_content'});
  if data['trigger_type'] == TaskSpecialContentTriggerType.Dialog then
    plotId = tonumber(data['trigger_content']);
    Task.newDoneTask = nil;
  else
    return;
  end
  MainUI:PopAll();
  MainUI:Push(self);
end
--
--================================================================================
--<4> 编年史特殊对话（有选项）
--
function TaskDialogPanel:ChronicleDialog(year, month, day)
  local y, m, d = year, month, day
  if not y then
    y = math.floor(ChroniclePanel.today / 10000);
    m = math.floor((ChroniclePanel.today / 100 % 100));
    d = ChroniclePanel.today % 100;
  end
  plotId = ChroniclePanel.story[y][m][d].plot_id;
  taskId = None;
  self.iChronicle = true;
  self.signYMD = y * 10000 + m * 100 + d
  MainUI:Push(self);
end
--================================================================================
--<5> 爱念度特殊对话（无选项）(结束标记0)
function TaskDialogPanel:LoveTaskDialog()
  plotId = LovePanel.plot_id;
  taskId = None;
  self.iLoveTask = true;
  MainUI:Push(self);
end
--
--================================================================================
--<6> 爱恋度特殊对话（无选项）(结束标记0) -- 从卡牌详情界面跳转而来
function TaskDialogPanel:LoveTaskDialogFromCardPanel(plot_id)
  plotId = plot_id;
  taskId = None;
  self.iLoveTaskFromCardPanel = true;
  MainUI:Push(self);
end
--
--================================================================================
--<n> novice 旷世大战剧情
function TaskDialogPanel:onNovice(plot_id)
  if self.iNovice then return end;
  MainUI:HideMainUI();
  plotId = plot_id;
  self.iNovice = true;
  taskId = None;
  MainUI:Push(self);
end
--
--================================================================================
--<t> test 策划专用测试剧情接口
function TaskDialogPanel:TestPlot()
  self.iTest = true;
  plotId = TopRenderStep:getPlotId();
  taskId = None;
  MainUI:Push(self);
end
--================================================================================
--获得对话Panel
function TaskDialogPanel:GetTaskPanel()
  return taskDialogPanel;
end
-- 备注
-- 同一个人有任务弹出弹框的前提条件是主线任务

--[[
cgmars #3726
1.像这种对话框出现的bug应该极少是程序这边的问题了，通常是策划表填写的有一些问题。 今天的这个编年史任务是策划填表出现了错误，没有剧情id为302307的剧情，让填表的人查一查是不是填写对了数据。
2.我在程序这边做一个异常处理，方便策划查看某一个剧情是否存在。
3.如果有必要我可以配合策划把每一个剧情过一遍是否正确。
4.表填写好后，最好自己先测试一下，否则只能出现各种各样问题，发现的我可以做个异常处理，没发现的可能造成严重后果，甚至于游戏崩溃。
--]]
