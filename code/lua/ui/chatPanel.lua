--chatPanel.lua
--=============================================================================================
--聊天界面

ChatPanel =
  {
  };

--变量
local wispIndex = nil;
local wispList = {};
local wispComboBoxList = {};
local curPageIndex;									--从1开始
local unReadMsgCount = 0;							--未读私聊消息个数
local unReadUnMsgCount = 0;							--未读公会消息个数
local message;										--输入的消息内容
local limitTimer = nil;							--世界聊天的时间间隔触发器
local expressionPanelList = {};
local isShow;

--控件
local labelInMainDesktop;
local mainDesktop;
local panel;
local tabControl;
local msgWipLabel;								--未读私聊个数控件
local msgUnLable;								--未读公会信息个数控件
local infoPopupMenu;								--弹出菜单
local windowPanel;

local allRichTextMessage

local tabWorld;
local wdTextInput;
local wdRichTextMessage;

local unRichTextMessage;
local tabUnion;
local cbUnion;

local wispComboBox;
local wispRichTextMessage;
local wipsText;
local wipsButton;
local tabWis;

local sysPanel;
local iconGridExpression;		--表情面板
local sysRichTextMessage;
local sysTipLable;

local btnClose;
local sendText;
local sendBtn;
local textBox;
local expBtn;
local isUnionBoss = false;

local otherUid;
local feedbackPanel;
local feedRichTextMessage;
--初始化
function ChatPanel:InitPanel(desktop)
  --变量初始化
  self.feedbackSize = false 						--反馈界面取消字符限制
  wispIndex = nil;
  wispList = {};
  wispComboBoxList = {};
  curPageIndex = 1;								--从1开始
  unReadMsgCount = 0;								--未读私聊消息个数
  unReadUnMsgCount = 0;							--未读公会消息个数
  message = '';									--输入的消息内容
  limitTimer = nil;								--世界聊天的时间间隔触发器
  isShow = false;
  expressionPanelList = {};

  --控件初始化
  mainDesktop = desktop;
  panel = Panel(desktop:GetLogicChild('ChatPanel1'));
  panel:IncRefCount();
  panel.ZOrder = PanelZOrder.chatPanelZOrder;
  panel.Visibility = Visibility.Visible;
  panel:SetUIStoryBoard("storyboard.chatPanelOut");
  btnClose = Button(panel:GetLogicChild('arrow'));
  btnClose:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ChatPanel:Hide');
  msgWipLabel = Label(panel:GetLogicChild('unReadLabel3'));
  msgUnLabel = Label(panel:GetLogicChild('unReadLabel2'));
  sendText = panel:GetLogicChild('TextBox'):GetLogicChild('findLabel');
  textBox = panel:GetLogicChild('TextBox')
  sendBtn = panel:GetLogicChild('SendButton');
  sendBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ChatPanel:Send');
  expBtn = panel:GetLogicChild('expression');

  windowPanel = panel:GetLogicChild('windowPanel')
  windowPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'ChatPanel:onwindowPanelLoseFocus');
  windowPanel.Visibility = Visibility.Hidden


  tabControl = panel:GetLogicChild("tabControl");
  iconGridExpression = panel:GetLogicChild('expression1');
  for index = 1, Configuration.MaxExpressionCount do
    local expressionPanel = iconGridExpression:GetLogicChild(tostring(index));
    expressionPanel.Tag = index + 10;
    expressionPanel:SubscribeScriptedEvent('UIControl::MouseDownEvent', 'ChatPanel:onExpressionClick');
    table.insert(expressionPanelList, expressionPanel);
  end

  tabPage = tabControl:GetLogicChild('world')
  tabWorld = tabPage;
  wdRichTextMessage = tabPage:GetLogicChild('ListClip'):GetLogicChild('List');

  tabPage = tabControl:GetLogicChild('union')
  unRichTextMessage = tabPage:GetLogicChild('ListClip'):GetLogicChild('List');
  tabUnion = tabPage;
  cbUnion = tabUnion.TabItem;

  tabPage = tabControl:GetLogicChild('whisper')
  tabWis = tabPage;
  wispRichTextMessage = tabPage:GetLogicChild('ListClip'):GetLogicChild('List');
  wispComboBox = panel:GetLogicChild('talker');
  wispComboBox.Visibility = Visibility.Hidden;
  wipsText = wispComboBox:GetInnerTextBox();
  wipsButton = wispComboBox:GetInnerButton();

  tabPage = tabControl:GetLogicChild('system')
  sysPanel = tabPage;
  sysPanel.Visibility = Visibility.Visible;
  sysRichTextMessage = tabPage:GetLogicChild('ListClip'):GetLogicChild('List');
  sysTipLable = panel:GetLogicChild('SysTipPanel');

  --反馈
  tabPage = tabControl:GetLogicChild('feedback')
  feedbackPanel = tabPage
  feedRichTextMessage = tabPage:GetLogicChild('ListClip'):GetLogicChild('List');

  labelInMainDesktop = CombinedElement(desktop:GetLogicChild('liaoTianPanel'):GetLogicChild('text'));
  mainDesktop:GetLogicChild('liaoTianPanel').Visibility = Visibility.Hidden;
  if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		local chat = mainDesktop:GetLogicChild('liaoTianPanel');
		chat:SetScale(factor,factor);
		chat.Translate = Vector2(389*(factor-1)/2,41*(1-factor)/2);
  end
end

function ChatPanel:onwindowPanelLoseFocus()
  windowPanel.Visibility = Visibility.Hidden
end

--销毁
function ChatPanel:Destroy()
  panel:DecRefCount();
  panel = nil;
end

--显示
function ChatPanel:Show()
  tabWis.Background = CreateTextureBrush('chat/chat_diban1.ccz', 'chat');
  tabUnion.Background = CreateTextureBrush('chat/chat_diban1.ccz', 'chat');
  tabWorld.Background = CreateTextureBrush('chat/chat_diban1.ccz', 'chat');
  sysPanel.Background = CreateTextureBrush('chat/chat_diban1.ccz', 'chat');
  feedbackPanel.Background = CreateTextureBrush('chat/chat_diban1.ccz', 'chat');
  if 0 == ActorManager.user_data.ggid then
    tabUnion.Visibility = Visibility.Hidden;
    cbUnion.Visibility = Visibility.Hidden;
  else
    tabUnion.Visibility = Visibility.Visible;
    cbUnion.Visibility = Visibility.Visible;
  end

  tabUnion.Visibility = Visibility.Hidden;
  tabWorld.Visibility = Visibility.Hidden;
  sysPanel.Visibility = Visibility.Hidden;
  feedbackPanel.Visibility = Visibility.Hidden;
  
  
  tabUnion.TabItem.Visibility = Visibility.Hidden;
  tabWorld.TabItem.Visibility = Visibility.Hidden;
  sysPanel.TabItem.Visibility = Visibility.Hidden;
  feedbackPanel.TabItem.Visibility = Visibility.Hidden;
  
  if #(wispList) == 0 then
    wipsText.Pick = false;
    wipsButton.Pick = false;
  else
    wipsText.Pick = true;
    wipsButton.Pick = true;
  end

  StoryBoard:OnPopPlayingUI();

  panel:SetUIStoryBoard("storyboard.chatPanelIn");

  if nil == pageIndex then
    pageIndex = 0;
  end
  if pageIndex == 2  and nil ~= defaultContent then
    wdTextInput.Text = defaultContent;
  end
  --tabControl.ActiveTabPageIndex = pageIndex;
  --curPageIndex = pageIndex + 1;
  textBox.Text = LANG_chatPanel_130;
  sendText.Text = '';
  isShow = true;
  --tabControl.ActiveTabPageIndex = 0;
  --curPageIndex = 1;
  tabControl.ActiveTabPageIndex = 2;
  curPageIndex = 3;
end

--隐藏
function ChatPanel:Hide()
  tabWis.Background = nil;
  tabUnion.Background = nil;
  tabWorld.Background = nil;
  sysPanel.Background = nil;
  feedbackPanel.Background = nil;
  DestroyBrushAndImage('chat/chat_diban1.png', 'chat');
  panel:SetUIStoryBoard("storyboard.chatPanelOut");
  isShow = false;
end

--聊天界面是否显示
function ChatPanel:IsShow()
  return isShow;
end
--=======================================================================================
--功能函数
--添加私聊玩家
function ChatPanel:addTalker(uid, name, level)
  for index,item in ipairs(wispList) do
    if item.uid == uid then
      wispComboBox.SelectedIndex = index - 1;
      return;
    end
  end

  wipsText.Pick = true;
  wipsButton.Pick = true;

  if #wispList == Configuration.MaxTalker then		--已达最大人数
    table.remove(wispList, 1);
    table.insert({uid = uid, name = name});
    for index,item in ipairs(wispList) do
      wispComboBoxList[index].Text = item.name;
      wispComboBoxList[index].Tag = item.uid;
    end
  else												--人数未满
    --创建item
    local comboItem = uiSystem:CreateControl('MenuItem');
    comboItem.Size = Size(145,41);
    comboItem.Text = name;
    comboItem.Font = uiSystem:FindFont('huakang_20_nobroad');
    comboItem.Tag = uid;
    table.insert(wispComboBoxList, comboItem);
    table.insert(wispList, {uid = uid, name = name, level = level});
    wispComboBox:AddChild(comboItem);
  end

  wispComboBox.SelectedIndex = #wispList - 1;
  wispIndex = #wispList;

end

--添加聊天信息
function ChatPanel:ReceiveMessage(msg)
  --替换屏蔽字
  msg.msg = LimitedWord:replaceLimited(msg.msg);
  if (1 == msg.type) then			--世界
    if msg.uid == 1 then
      return
    end
    self:AddMsgToRTB(wdRichTextMessage, msg, LANG_chatPanel_2, Configuration.BlackColor, false);
    ChatPanel:updateWorld();
  elseif (2 == msg.type) then		--工会
    self:AddMsgToRTB(unRichTextMessage, msg, LANG_chatPanel_5, Configuration.BlackColor, false);
    ChatPanel:updateUnion();
  elseif (3 == msg.type) then		--私人
    self:AddMsgToRTB(wispRichTextMessage, msg, LANG_chatPanel_8, Configuration.BlackColor, false);
    --加聊天者
    self:addTalker(msg.uid, msg.name, msg.lv);
    local vscroll = tabWis:GetLogicChild('ListClip');
    vscroll:VScrollEnd();
    vscroll.VScrollPos = vscroll.VScrollPos + 150;
  elseif (4 == msg.type) then		--系统
    self:AddMsgToRTB(wdRichTextMessage, msg, LANG_chatPanel_10, Configuration.BlackColor, false);
    self:AddMsgToRTB(sysRichTextMessage, msg, LANG_chatPanel_11, Configuration.BlackColor, false);
    ChatPanel:updateWorld();
    ChatPanel:updateSys();
  elseif (5 == msg.type) then
    self:AddMsgToRTB(feedRichTextMessage, msg, LANG_chatPanel_135, Configuration.BlackColor, false);
    ChatPanel:updateFeedback();
  end

  --记录未读私聊消息
  if (curPageIndex ~= 3) and (3 == msg.type ) then
    unReadMsgCount = unReadMsgCount + 1;
    if unReadMsgCount > 99 then
      unReadMsgCount = 99;
    end
    self:updateUnReadMsg();
  end
  --记录未读公会消息
  if (curPageIndex ~= 2) and (2 == msg.type ) then
    unReadUnMsgCount = unReadUnMsgCount + 1;
    if unReadUnMsgCount > 99 then
      unReadUnMsgCount = 99;
    end
    self:updateUnReadMsg();
  end
end

--显示自己发送的私聊信息
function ChatPanel:addWisperOfSelf(rtb, message, title, color, isMainUI)
  color = Configuration.BlackColor;
  local underLine_font = uiSystem:FindFont('huakang_20_nobroad');
  local font = uiSystem:FindFont('huakang_20_nobroad');

  local chatInfo  = customUserControl.new(rtb, 'rightChatTemplate');
  chatInfo.initInfo(rtb, message, title, color, font, isMainUI);
  local vscroll = tabWis:GetLogicChild('ListClip');
  vscroll:VScrollEnd();
  vscroll.VScrollPos = vscroll.VScrollPos + 150;
end

--显示自己反馈的意见消息
function ChatPanel:addFeedbackOfSelf(rtb, message, title, color, isMainUI)
  self.feedbackSize = true
  color = Configuration.BlackColor;
  local underLine_font = uiSystem:FindFont('huakang_20_nobroad');
  local font = uiSystem:FindFont('huakang_20_nobroad');

  local chatInfo  = customUserControl.new(rtb, 'rightChatTemplate');
  chatInfo.initInfo(rtb, message, title, color, font, isMainUI);
  local vscroll = feedbackPanel:GetLogicChild('ListClip');
  vscroll:VScrollEnd();
  vscroll.VScrollPos = vscroll.VScrollPos + 150;
  self.feedbackSize = false
end

--显示服务器发送的聊天信息
function ChatPanel:AddMsgToRTB(rtb, msg, title, color, isMainUI)
  color = Configuration.BlackColor
  local underLine_font = uiSystem:FindFont('huakang_20_nobroad');
  local font = uiSystem:FindFont('huakang_20_nobroad');

  if (msg.uid == ActorManager.user_data.uid) then		--主城和公会界面添加自己的消息
    local chatInfo  = customUserControl.new(rtb, 'rightChatTemplate');
    chatInfo.initInfo(rtb, msg, title, color, font, isMainUI);
    labelInMainDesktop:RemoveAllChildren();
    ChatPanel:infoinmainPanel(labelInMainDesktop, msg.msg, color, font, msg.name);
  elseif msg.uid == Configuration.SystemUID then		--系统消息
  else
    local chatInfo  = customUserControl.new(rtb, 'leftChatTemplate');
    chatInfo.initInfo(rtb, msg, title, color, font, isMainUI);
    chatInfo.setIconClickEvent('ChatPanel:iconClickEvent')
    labelInMainDesktop:RemoveAllChildren();
    ChatPanel:infoinmainPanel(labelInMainDesktop, msg.msg, color, font, msg.name);
  end
end

function ChatPanel:iconClickEvent(Args)
  local args = UIControlEventArgs(Args);
  otherUid = args.m_pControl.Tag;

  PersonInfoPanel:ReqOtherInfosClick(otherUid)
  -- windowPanel.Visibility = Visibility.Visible
  -- windowPanel.Translate = Vector2(mouseCursor.Translate.x, mouseCursor.Translate.y);
  -- mainDesktop.FocusControl = windowPanel;

end

function ChatPanel:checkBtnClickEvent()
  PersonInfoPanel:ReqOtherInfosClick(otherUid)
  windowPanel.Visibility = Visibility.Hidden
end

function ChatPanel:infoinmainPanel(tb, message, color, font, messageinfo)
  tb:RemoveAllChildren();
  local preStr;
  local expressionID = 0;
  local expressionIDStr;
  message = string.sub(message, 1, 42);
  local startIndex, endIndex = string.find(message, '\\c');
  if (messageinfo == ActorManager.user_data.name) then
    tb:AddText( "我:", QuadColor(Color(28, 113, 5, 255)), font);
  else
    tb:AddText(messageinfo .. ":", QuadColor(Color(28, 113, 5, 255)), font);
  end
  while nil ~= startIndex do
    --寻找表情的转义字符位置
    preStr = string.sub(message, 1, startIndex - 1);
    tb:AppendText(preStr, color, font);
    expressionIDStr = string.sub(message, endIndex + 1, endIndex + 2);           --表情id
    expressionID = tonumber(expressionIDStr);                                    --转化成数字
    if (nil ~= expressionID) and (expressionID > 10) and (expressionID <= Configuration.MaxExpressionCount + 10) then --存在表情转义字符
      local armatureUI = uiSystem:CreateControl('ArmatureUI');
      if expressionID <= 20 then
        armatureUI:LoadArmature('biaoqing_' .. (expressionID - 10));
      else
        armatureUI:LoadArmature('liaotian_' .. (expressionID - 10));
      end
      armatureUI:SetAnimation('play');
      armatureUI.Size = Size(35, 20);
      armatureUI:SetScale(0.6, 0.6);
      tb:AppendUIControl(armatureUI);
      armatureUI.Translate = Vector2(15, 10);
    else    --不存在表情的转义字符
      tb:AppendText('\\c' .. expressionIDStr, color, font);
      -- expressionIDStr.Translate = Vector2(25, 10);
    end
    --截断message
    message = string.sub(message, endIndex + 3, -1);
    startIndex, endIndex = string.find(message, '\\c');
  end
  tb:AppendText(message, color, font);
end

--解析服务器发送的XML事件消息
function ChatPanel:ParseEventXML(eventXml)
  local underLine_font = uiSystem:FindFont('huakang_20_nobroad');
  local font = uiSystem:FindFont('huakang_20_nobroad');
  local vipFont = uiSystem:FindFont('huakang_20miaobian_R38G19B0')
  local defaultColor = nil;

  local xfile = xmlParseString( eventXml );
  local rootNode = xfile[1];
  local eventType = tonumber(rootNode.attr['Value']);
  local broadcastFlag = tonumber(rootNode.attr['CenterPush']);
  local broadcastText = '';
  local rtb2 = nil;
  local chatInfo  = customUserControl.new(wdRichTextMessage,  'SysChatTemplate');
  local rtb1 = chatInfo.ctrl:GetLogicChild('richText');
  if eventType == 1 then			--全部和系统
    local sysInfo = customUserControl.new(sysRichTextMessage, 'SysChatTemplate');
    rtb2 = sysInfo.ctrl:GetLogicChild('richText');
  elseif eventType == 2 then		--全部和公会
    local unionInfo = customUserControl.new(unRichTextMessage, 'SysChatTemplate');
    rtb2 = unionInfo.ctrl:GetLogicChild('richText');
  end
  if rootNode.n > 0 then
    for index = 1, rootNode.n do
      local nodeXml = rootNode[index];
      local attr = nodeXml.attr;

      --颜色
      local color = defaultColor;
      if attr['Color'] ~= nil then
	--			color = QualityColor[tonumber(attr['Color'])]
      end

      --文本
      local text = attr['Value'];
      if text == nil then						--文本为空
        if (attr['Mid'] ~= nil) then		--怪物名
          text = resTableManager:GetValue(ResTable.monster, attr['Mid'], 'name');
        elseif (attr['Cmid'] ~= nil) then
          text = resTableManager:GetValue(ResTable.invasion, attr['Cmid'], 'name');
        elseif (attr['Itid'] ~= nil) then	--物品
          item = resTableManager:GetValue(ResTable.item, attr['Itid'], {'name', 'quality'});
          text = item['name'];
          color = Configuration.BlackColor;
        elseif (attr['Pid'] ~= nil) then	--伙伴
          item = resTableManager:GetValue(ResTable.actor, attr['Pid'], {'name', 'rare'});
          text = item['name'];
          color = Configuration.BlackColor;
        else
          text = '';
        end
      end

      broadcastText = broadcastText .. text;

      if 'Text' == nodeXml.name then
        --普通文本
        color = Configuration.BlackColor
        rtb1:AppendText(text, color, font);
        rtb2:AppendText(text, color, font);
      elseif 'Link' == nodeXml.name then
        --可点击按钮
        --添加VIP等级
        if tonumber(attr['Vip']) > 0 then
          local element = uiSystem:CreateControl('TextElement');
          element.Font = vipFont;
          element.Text = ' V' .. attr['Vip'];
          element.TextColor = Configuration.VipColor;

          rtb1:AppendUIControl(element);
          rtb2:AppendUIControl(element:Clone());
        end

        element = uiSystem:CreateControl('TextElement');
        element.TextColor = Configuration.BlackColor;
        element.Font = underLine_font;
        element.Tag = tonumber(attr['UID']);
        element.TagExt = tonumber(attr['Level']);
        element.Text = text;
        element:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ChatPanel:onClickInfoPlayer');

        rtb1:AppendUIControl(element);
        rtb2:AppendUIControl(element:Clone());
      end
    end
  end

  if broadcastFlag == 1 then
    Broadcast:AddBroadcast(broadcastText);
  end
end

--添加服务器发送的事件公告信息
function ChatPanel:AddEventMessage(msg)
  if not MainUI.IsInitSuccess then
    return;
  end

  if msg.type == SystemEventType.gemSynthetise or msg.type == SystemEventType.rmb then			--1 合成宝石--5 关卡获得水晶
    self:AddAdvancedGemEvent(sysRichTextMessage, msg.name, msg.uid, msg.lv, msg.resid, msg.count, msg.type, false);
    ChatPanel:updateSys();
    self:AddAdvancedGemEvent(wdRichTextMessage, msg.name, msg.uid, msg.lv, msg.resid, msg.count, msg.type, false);
    ChatPanel:updateWorld();
  elseif msg.type == SystemEventType.zodiacSign or msg.type == SystemEventType.elite then 		--2 通关黄道十二宫--3 通关精英关卡
    self:AddCrossZodiacOrEliteEvent(sysRichTextMessage, msg.name, msg.uid, msg.lv, msg.resid, msg.type, false);
    ChatPanel:updateSys();
    self:AddAdvancedGemEvent(wdRichTextMessage, msg.name, msg.uid, msg.lv, msg.resid, msg.type, false);
    ChatPanel:updateWorld();
  elseif msg.type == SystemEventType.recruit then 						--4 招募伙伴
    self:AddGainPartnerEvent(sysRichTextMessage, msg.name, msg.uid, msg.lv, msg.resid, false);
    ChatPanel:updateSys();
    self:AddAdvancedGemEvent(wdRichTextMessage, msg.name, msg.uid, msg.lv, msg.resid, false);
    ChatPanel:updateWorld();
  elseif msg.type == SystemEventType.worldBossKilled then 						--6 世界boss被杀死
    if msg.flag == 1 then
      self:AddWorldBossKilledEvent(sysRichTextMessage, msg.resid, msg.gold, msg.btp, msg.item, msg.name, msg.uid, msg.lv, false, Configuration.BlackColor, Configuration.BlackColor, LANG_chatPanel_26);
      ChatPanel:updateSys();
      self:AddWorldBossKilledEvent(sysRichTextMessage, msg.resid, msg.gold, msg.btp, msg.item, msg.name, msg.uid, msg.lv, false, Configuration.BlackColor, Configuration.BlackColor, LANG_chatPanel_26);
      ChatPanel:updateWorld();
    else
      self:AddWorldBossKilledEvent(unRichTextMessage, msg.resid, msg.gold, msg.btp, msg.item, msg.name, msg.uid, msg.lv, false, Configuration.BlackColor, Configuration.BlackColor, LANG_chatPanel_29);
      ChatPanel:updateUnion();
      self:AddWorldBossKilledEvent(wdRichTextMessage, msg.resid, msg.gold, msg.btp, msg.item, msg.name, msg.uid, msg.lv, false, Configuration.BlackColor, Configuration.BlackColor, LANG_chatPanel_29);
      ChatPanel:updateWorld();
    end

  elseif msg.type == SystemEventType.firstOne then 								--7 竞技场获得第一
    self:AddFirstPersonChangeEvent(sysRichTextMessage, msg.name1, msg.uid1, msg.lv1, msg.name2, msg.uid2, msg.lv2, false);
    ChatPanel:updateSys();
    self:AddFirstPersonChangeEvent(wdRichTextMessage, msg.name1, msg.uid1, msg.lv1, msg.name2, msg.uid2, msg.lv2, false);
    ChatPanel:updateWorld();
  elseif msg.type == SystemEventType.worldBossEscape then 						--8 世界boss逃逸
    ToastMove:AddBossEscapeTip(msg.resid);
    if msg.flag == 1 then
      self:AddWorldBossEscapeEvent(sysRichTextMessage, msg.resid, false, Configuration.BlackColor, Configuration.BlackColor, LANG_chatPanel_32);
      ChatPanel:updateSys();
      self:AddWorldBossEscapeEvent(wdRichTextMessage, msg.resid, false, Configuration.BlackColor, Configuration.BlackColor, LANG_chatPanel_32);
      ChatPanel:updateWorld();
    else
      self:AddWorldBossEscapeEvent(unRichTextMessage, msg.resid, false, Configuration.BlackColor, Configuration.BlackColor, LANG_chatPanel_35);
      ChatPanel:updateUnion();
      self:AddWorldBossEscapeEvent(wdRichTextMessage, msg.resid, false, Configuration.BlackColor, Configuration.BlackColor, LANG_chatPanel_35);
      ChatPanel:updateWorld();
    end

  elseif msg.type == SystemEventType.firstOneOnLine then 						--9 竞技场第一名上线
    self:AddFirstPersonGetOnlineEvent(sysRichTextMessage, msg.name, msg.uid, msg.lv, msg.resid, false);
    ChatPanel:updateSys();
    self:AddFirstPersonGetOnlineEvent(wdRichTextMessage, msg.name, msg.uid, msg.lv, msg.resid, false);
    ChatPanel:updateWorld();
  elseif msg.type == SystemEventType.worldBoss10Hp then							--10 世界boss血量不足10%
    if msg.flag == 1 then
      self:AddWorldBoss10HPEvent(sysRichTextMessage, msg.resid, false, Configuration.BlackColor, Configuration.BlackColor, LANG_chatPanel_38);
      ChatPanel:updateSys();
      self:AddWorldBoss10HPEvent(wdRichTextMessage, msg.resid, false, Configuration.BlackColor, Configuration.BlackColor, LANG_chatPanel_38);
      ChatPanel:updateWorld();
    else
      self:AddWorldBoss10HPEvent(unRichTextMessage, msg.resid, false, Configuration.BlackColor, Configuration.BlackColor, LANG_chatPanel_41);
      ChatPanel:updateUnion();
      self:AddWorldBoss10HPEvent(wdRichTextMessage, msg.resid, false, Configuration.BlackColor, Configuration.BlackColor, LANG_chatPanel_41);
      ChatPanel:updateWorld();
    end

  elseif msg.type == SystemEventType.startWorldBoss then							--世界boss开始
    if msg.flag == 1 then
      self:AddStartWorldBossEvent(sysRichTextMessage, msg.time, false, Configuration.BlackColor, Configuration.BlackColor, LANG_chatPanel_45, LANG_chatPanel_46);
      ChatPanel:updateSys();
      self:AddStartWorldBossEvent(wdRichTextMessage, msg.time, false, Configuration.BlackColor, Configuration.BlackColor, LANG_chatPanel_45, LANG_chatPanel_46);
      ChatPanel:updateWorld();
    else
	  isUnionBoss = true;
      self:AddStartWorldBossEvent(unRichTextMessage, msg.time, false, Configuration.BlackColor, Configuration.BlackColor, LANG_chatPanel_51, LANG_chatPanel_52);
      ChatPanel:updateUnion();
      self:AddStartWorldBossEvent(wdRichTextMessage, msg.time, false, Configuration.BlackColor, Configuration.BlackColor, LANG_chatPanel_51, LANG_chatPanel_52);
      ChatPanel:updateWorld();
    end

  end
end

--显示玩家合成宝石事件
function ChatPanel:AddAdvancedGemEvent(panel, actorName, actorUID, actorLevel, gemResid, gemCount, eventType, isMainUI)
  --【世界】玩家名成功合成【7/8/9/10级宝石】
  local underLine_font = uiSystem:FindFont('huakang_20_nobroad');
  local font = uiSystem:FindFont('huakang_20_nobroad');


  local chatInfo  = customUserControl.new(panel, 'SysChatTemplate');
  local rtb = chatInfo.ctrl:GetLogicChild('richText');
  if isMainUI then
    rtb:RemoveAllChildren();
  end

  rtb:AddText(LANG_chatPanel_55, Configuration.BlackColor, font);
  local element = TextElement( uiSystem:CreateControl('TextElement') );
  element.TextColor = Configuration.BlackColor;
  element.Font = underLine_font;
  element.Tag = actorUID;
  element.TagExt = actorLevel;
  element.Text = actorName;
  element:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ChatPanel:onClickInfoPlayer');
  if isMainUI then
    rtb:AddUIControl(element);
    if 1 == eventType then			--宝石合成
      rtb:AddText(LANG_chatPanel_56 .. gemCount .. LANG_chatPanel_57, Configuration.BlackColor, font);

      local gemItem = resTableManager:GetValue(ResTable.item, tostring(gemResid), {'name', 'quality'});
      local emt = TextElement( uiSystem:CreateControl('TextElement') );
      emt.Text = gemItem['name'];
      emt.TextColor = Configuration.BlackColor;
      emt.Font = font;
      rtb:AddUIControl(emt);
      rtb:AddText('】', Configuration.BlackColor, font);

    else							--关卡获得水晶
      local roundName = resTableManager:GetValue(ResTable.barriers, tostring(gemResid), 'name');
      rtb:AddText(LANG_chatPanel_58 .. roundName .. LANG_chatPanel_59 .. gemCount .. LANG_chatPanel_60, Configuration.BlackColor, font);
    end

  else
    rtb:AppendUIControl(element);
    if 1 == eventType then
      rtb:AppendText(LANG_chatPanel_61 .. gemCount .. LANG_chatPanel_62, Configuration.BlackColor, font);

      local gemItem = resTableManager:GetValue(ResTable.item, tostring(gemResid), {'name', 'quality'});
      local emt = TextElement( uiSystem:CreateControl('TextElement') );
      emt.Text = gemItem['name'];
      emt.TextColor = Configuration.BlackColor;
      emt.Font = font;
      rtb:AppendUIControl(emt);
      rtb:AppendText('】', Configuration.BlackColor, font);

    else
      local roundName = resTableManager:GetValue(ResTable.barriers, tostring(gemResid), 'name');
      rtb:AppendText(LANG_chatPanel_63 .. roundName .. LANG_chatPanel_64 .. gemCount .. LANG_chatPanel_65, Configuration.BlackColor, font);
    end
  end
end

--显示玩家招募英雄事件
function ChatPanel:AddGainPartnerEvent(textPanels, actorName, actorUID, actorLevel, partnerResid, isMainUI)
  local chatInfo  = customUserControl.new(textPanel, 'SysChatTemplate');
  local rtb = chatInfo.ctrl:GetLogicChild('richText');
  local underLine_font = uiSystem:FindFont('huakang_20_nobroad');
  local font = uiSystem:FindFont('huakang_20_nobroad');

  if isMainUI then
    rtb:RemoveAllChildren();
  end

  rtb:AddText(LANG_chatPanel_66, Configuration.BlackColor, font);
  local element = TextElement( uiSystem:CreateControl('TextElement') );
  element.TextColor = Configuration.BlackColor;
  element.Font = underLine_font;
  element.Tag = actorUID;
  element.TagExt = actorLevel;
  element.Text = actorName;
  element:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ChatPanel:onClickInfoPlayer');
  if isMainUI then
    rtb:AddUIControl(element);
    rtb:AddText(LANG_chatPanel_67, Configuration.BlackColor, font);
  else
    rtb:AppendUIControl(element);
    rtb:AppendText(LANG_chatPanel_68, Configuration.BlackColor, font);
  end

  local partner = resTableManager:GetValue(ResTable.actor, tostring(partnerResid), {'name', 'rare'});
  local emt = TextElement( uiSystem:CreateControl('TextElement') );
  emt.Text = partner['name'];
  emt.TextColor = Configuration.BlackColor;
  emt.Font = font;
  if isMainUI then
    rtb:AddUIControl(emt);
    rtb:AddText('】',Configuration.BlackColor, font);
  else
    rtb:AppendUIControl(emt);
    rtb:AppendText('】', Configuration.BlackColor, font);
  end
end

--显示通关黄道十二宫事件和通关精英关卡事件
function ChatPanel:AddCrossZodiacOrEliteEvent(textPanel, actorName, actorUID, actorLevel, roundid, roundType, isMainUI)
  local chatInfo  = customUserControl.new(textPanel, 'SysChatTemplate');
  local rtb = chatInfo.ctrl:GetLogicChild('richText');
  local underLine_font = uiSystem:FindFont('huakang_20_nobroad');
  local font = uiSystem:FindFont('huakang_20_nobroad');

  if isMainUI then
    rtb:RemoveAllChildren();
  end

  local element = TextElement( uiSystem:CreateControl('TextElement') );
  element.TextColor = Configuration.BlackColor;
  element.Font = underLine_font;
  element.Tag = actorUID;
  element.TagExt = actorLevel;
  element.Text = actorName;
  element:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ChatPanel:onClickInfoPlayer');
  if isMainUI then
    rtb:AddUIControl(element);
    if 2 == roundType then
      rtb:AddText(LANG_chatPanel_70, Configuration.BlackColor, font);
    elseif 3 == roundType then
      rtb:AddText(LANG_chatPanel_71, Configuration.BlackColor, font);
    end
  else
    rtb:AppendUIControl(element);
    if 2 == roundType then
      rtb:AppendText(LANG_chatPanel_72, Configuration.BlackColor, font);
    elseif 3 == roundType then
      rtb:AppendText(LANG_chatPanel_73, Configuration.BlackColor, font);
    end
  end

  local roundName = resTableManager:GetValue(ResTable.barriers, tostring(roundid), 'name');
  if isMainUI then
    rtb:AddText(roundName .. '】', Configuration.BlackColor, font);
  else
    rtb:AppendText(roundName .. '】', Configuration.BlackColor, font);
  end
end

--竞技场第一名上线事件
function ChatPanel:AddFirstPersonGetOnlineEvent(textPanel, actorName, actorUID, actorLevel, actorResid, isMainUI)
  local chatInfo  = customUserControl.new(textPanel, 'SysChatTemplate');
  local rtb = chatInfo.ctrl:GetLogicChild('richText');
  if nil == rtb then
    return;
  end
  local underLine_font = uiSystem:FindFont('huakang_20_nobroad');
  local font = uiSystem:FindFont('huakang_20_nobroad');

  if isMainUI then
    rtb:RemoveAllChildren();
  end

  --rtb:AddText(LANG_chatPanel_74, Configuration.BlackColor, font);

  local element = TextElement( uiSystem:CreateControl('TextElement') );
  element.TextColor = Configuration.BlackColor;
  element.Font = underLine_font;
  element.Tag = actorUID;
  element.TagExt = actorLevel;
  element.Text = actorName;
  element:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ChatPanel:onClickInfoPlayer');
  if isMainUI then
    rtb:AddText(LANG_chatPanel_75, Configuration.BlackColor, font);
    rtb:AddUIControl(element);
    rtb:AddText(LANG_chatPanel_76, Configuration.BlackColor, font);
  else
    rtb:AppendText(LANG_chatPanel_77, Configuration.BlackColor, font);
    rtb:AppendUIControl(element);
    rtb:AppendText(LANG_chatPanel_78, Configuration.BlackColor, font);
  end
end

--竞技场第一名变化事件
function ChatPanel:AddFirstPersonChangeEvent(textPanel, firstName, firstUID, firstLevel, secondName, secondUID, secondLevel, isMainUI)
  local chatInfo  = customUserControl.new(textPanel, 'SysChatTemplate');
  local rtb = chatInfo.ctrl:GetLogicChild('richText');
  local underLine_font = uiSystem:FindFont('huakang_20_nobroad');
  local font = uiSystem:FindFont('huakang_20_nobroad');

  if isMainUI then
    rtb:RemoveAllChildren();
  end

  local element1 = TextElement( uiSystem:CreateControl('TextElement') );
  element1.TextColor = Configuration.BlackColor;
  element1.Font = underLine_font;
  element1.Tag = firstUID;
  element1.TagExt = firstLevel;
  element1.Text = firstName;
  element1:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ChatPanel:onClickInfoPlayer');

  local element2 = TextElement( uiSystem:CreateControl('TextElement') );
  element2.TextColor = Configuration.BlackColor;
  element2.Font = underLine_font;
  element2.Tag = secondUID;
  element2.TagExt = secondLevel;
  element2.Text = secondName;
  element2:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ChatPanel:onClickInfoPlayer');

  if isMainUI then
    rtb:AddUIControl(element1);
    rtb:AddText(LANG_chatPanel_80, Configuration.BlackColor, font);
    rtb:AddUIControl(element2);
    rtb:AddText(LANG_chatPanel_81, Configuration.BlackColor, font);
  else
    rtb:AppendUIControl(element1);
    rtb:AppendText(LANG_chatPanel_82, Configuration.BlackColor, font);
    rtb:AppendUIControl(element2);
    rtb:AppendText(LANG_chatPanel_83, Configuration.BlackColor, font);
  end
end

--世界boss开始
function ChatPanel:AddStartWorldBossEvent(textPanel, startTime, isMainUI, titleColor, textColor, title, bossName)
  local chatInfo  = customUserControl.new(textPanel, 'SysChatTemplate');
  local rtb = chatInfo.ctrl:GetLogicChild('richText');
  local underLine_font = uiSystem:FindFont('huakang_20_nobroad');
  local font = uiSystem:FindFont('huakang_20_nobroad');
  local strTime = Time2HMStr(startTime);

  if isMainUI then
    rtb:RemoveAllChildren();
  end

  if isMainUI then
    rtb:AddText(bossName, Configuration.BlackColor, font);
	if not isUnionBoss then
		rtb:AddText(LANG_chatPanel_84 .. strTime .. LANG_chatPanel_85, textColor, font);
	else
		rtb:AddText(LANG_chatPanel_85, textColor, font);
	end
  else
    rtb:AppendText(bossName, Configuration.BlackColor, font);
	if not isUnionBoss then
		rtb:AppendText(LANG_chatPanel_86 .. strTime .. LANG_chatPanel_87, textColor, font);
	else
		rtb:AppendText(LANG_chatPanel_87, textColor, font);
	end
  end
end

--世界boss被杀死
function ChatPanel:AddWorldBossKilledEvent(textPanel, bossResid, gold, zhanli, itemResid, actorName, actorUID, actorLevel, isMainUI, titleColor, textColor, title)
  local chatInfo  = customUserControl.new(textPanel, 'SysChatTemplate');
  local rtb = chatInfo.ctrl:GetLogicChild('richText');
  local underLine_font = uiSystem:FindFont('huakang_20_nobroad');
  local font = uiSystem:FindFont('huakang_20_nobroad');
  local bossName = resTableManager:GetValue(ResTable.monster, tostring(bossResid), 'name');
  local item = resTableManager:GetValue(ResTable.item, tostring(itemResid), {'name', 'quality'});

  if isMainUI then
    rtb:RemoveAllChildren();
  end

  local element = TextElement( uiSystem:CreateControl('TextElement') );
  element.TextColor = Configuration.BlackColor;
  element.Font = underLine_font;
  element.Tag = actorUID;
  element.TagExt = actorLevel;
  element.Text = actorName;
  element:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ChatPanel:onClickInfoPlayer');

  local element1 = TextElement( uiSystem:CreateControl('TextElement') );
  element1.TextColor = Configuration.BlackColor;
  element1.Text = item['name'];
  element1.Font = font;

  if isMainUI then
    rtb:AddText(bossName, Configuration.BlackColor, font);
    rtb:AddText(LANG_chatPanel_88, textColor, font);
    rtb:AddUIControl(element);
    rtb:AddText(LANG_chatPanel_89 .. gold .. LANG_chatPanel_90 .. zhanli .. LANG_chatPanel_91, textColor, font);
    rtb:AddUIControl(element1);
  else
    rtb:AppendText(bossName, Configuration.BlackColor, font);
    rtb:AppendText(LANG_chatPanel_92, textColor, font);
    rtb:AppendUIControl(element);
    rtb:AppendText(LANG_chatPanel_93 .. gold .. LANG_chatPanel_94 .. zhanli .. LANG_chatPanel_95, textColor, font);
    rtb:AppendUIControl(element1);
  end
end

--世界boss逃跑
function ChatPanel:AddWorldBossEscapeEvent(textPanel, bossResid, isMainUI, titleColor, textColor, title)
  local chatInfo  = customUserControl.new(textPanel, 'SysChatTemplate');
  local rtb = chatInfo.ctrl:GetLogicChild('richText');
  local underLine_font = uiSystem:FindFont('huakang_20_nobroad');
  local font = uiSystem:FindFont('huakang_20_nobroad');
  local bossName = resTableManager:GetValue(ResTable.monster, tostring(bossResid), 'name');

  if isMainUI then
    rtb:RemoveAllChildren();
  end

  if isMainUI then
    rtb:AddText(bossName, Configuration.BlackColor, font);
    rtb:AddText(LANG_chatPanel_96, Configuration.BlackColor, font);
  else
    rtb:AppendText(bossName, Configuration.BlackColor, font);
    rtb:AppendText(LANG_chatPanel_97, Configuration.BlackColor, font);
  end
end

--世界boss血量低于10%
function ChatPanel:AddWorldBoss10HPEvent(textPanel, bossResid, isMainUI, titleColor, textColor, title)
  local chatInfo  = customUserControl.new(textPanel, 'SysChatTemplate');
  local rtb = chatInfo.ctrl:GetLogicChild('richText');
  local underLine_font = uiSystem:FindFont('huakang_20_nobroad');
  local font = uiSystem:FindFont('huakang_20_nobroad');
  local bossName = resTableManager:GetValue(ResTable.monster, tostring(bossResid), 'name');

  if isMainUI then
    rtb:RemoveAllChildren();
  end

  if isMainUI then
    rtb:AddText(bossName, Configuration.BlackColor, font);
    rtb:AddText(LANG_chatPanel_98, textColor, font);
  else
    rtb:AppendText(bossName, Configuration.BlackColor, font);
    rtb:AppendText(LANG_chatPanel_99, textColor, font);
  end
end

--显示世界boss前十名的伤害
function ChatPanel:AddTenBossDamage(msg)
  if msg.flag == 1 then
    --世界boss
    self:showTenBossDamageTitle(sysRichTextMessage, msg.resid, false, Configuration.BlackColor, Configuration.BlackColor, LANG_chatPanel_101);

    for index, item in ipairs(msg.rank) do
      self:showTenBossDamage(wdRichTextMessage, index, item.nickname, item.uid, item.lv, item.damage, msg.reward[index], Configuration.BlackColor);
      self:showTenBossDamage(sysRichTextMessage, index, item.nickname, item.uid, item.lv, item.damage, msg.reward[index], Configuration.BlackColor);
    end
  else
    --公会boss
    self:showTenBossDamageTitle(unRichTextMessage, msg.resid, false, Configuration.BlackColor, Configuration.BlackColor, LANG_chatPanel_104);

    for index, item in ipairs(msg.rank) do
      self:showTenBossDamage(unRichTextMessage, index, item.nickname, item.uid, item.lv, item.damage, msg.reward[index], Configuration.BlackColor);
    end
  end
end

function ChatPanel:showTenBossDamage(textPanel, rankIndex, actorName, actorUID, actorLevel, damage, reward, textColor)
  local chatInfo  = customUserControl.new(textPanel, 'SysChatTemplate');
  local rtb = chatInfo.ctrl:GetLogicChild('richText');
  local underLine_font = uiSystem:FindFont('huakang_20_nobroad');
  local font = uiSystem:FindFont('huakang_20_nobroad');

  local element = TextElement( uiSystem:CreateControl('TextElement') );
  element.TextColor = Configuration.BlackColor;
  element.Font = underLine_font;
  element.Tag = actorUID;
  element.TagExt = actorLevel;
  element.Text = actorName;
  element:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ChatPanel:onClickInfoPlayer');

  rtb:AddText(LANG_chatPanel_106 .. NumToLevel[rankIndex] .. LANG_chatPanel_107, textColor, font);
  rtb:AppendUIControl(element);
  rtb:AppendText(LANG_chatPanel_108 .. damage, textColor, font);

  --显示奖励
  if reward ~= nil then
    rtb:AppendText(LANG_chatPanel_109, textColor, font);
    local item = resTableManager:GetValue(ResTable.item, tostring(reward.item), {'quality', 'name'});
    rtb:AppendText(item['name'], Configuration.BlackColor, font);
    rtb:AppendText(LANG_chatPanel_110 .. reward.gold, textColor, font);
  end
end

function ChatPanel:showTenBossDamageTitle(textPanel, bossResid, isMainUI, titleColor, textColor, title)
  local chatInfo  = customUserControl.new(textPanel, 'SysChatTemplate');
  local rtb = chatInfo.ctrl:GetLogicChild('richText');
  local underLine_font = uiSystem:FindFont('huakang_20_nobroad');
  local font = uiSystem:FindFont('huakang_20_nobroad');
  local bossName = resTableManager:GetValue(ResTable.monster, tostring(bossResid), 'name');

  if isMainUI then
    rtb:RemoveAllChildren();
    rtb:AddText(LANG_chatPanel_112, textColor, font);
    rtb:AddText(bossName, Configuration.BlackColor, font);
    rtb:AddText(LANG_chatPanel_113, textColor, font);
  else
    rtb:AppendText(LANG_chatPanel_114, textColor, font);
    rtb:AppendText(bossName, Configuration.BlackColor, font);
    rtb:AppendText(LANG_chatPanel_115, textColor, font);
  end

end

--获取系统频道聊天界面富文本
function ChatPanel:GetSystemRichTextBox()
  return sysRichTextMessage;
end

--获取主城聊天界面富文本
function ChatPanel:GetMainRichTextBox()
  return labelInMainDesktop;
end

--获取全部频道聊天界面富文本
function ChatPanel:GetAllRichTextBox()
  return allRichTextMessage;
end

--更新未读消息显示
function ChatPanel:updateUnReadMsg()
  local unReadCount;
  if unReadMsgCount > 0 then
    --如果公会频道未开启,调整私聊未读lable位置
    if tabUnion.Visibility == Visibility.Hidden then
      msgWipLabel.Margin = Rect(81,159,0,0);
    end
    msgWipLabel.Visibility = Visibility.Visible;
  else
    msgWipLabel.Visibility = Visibility.Hidden;
  end
  if unReadUnMsgCount > 0 then
    --无未读消息
    msgUnLabel.Visibility = Visibility.Visible;
  else
    msgUnLabel.Visibility = Visibility.Hidden;
  end
  if unReadMsgCount == 0 and unReadMsgCount == 0 then
    unReadCount = 0;
  else
    unReadCount = 1;
  end
  msgWipLabel.Visibility = Visibility.Hidden;
  msgUnLabel.Visibility = Visibility.Hidden;
end
--=======================================================================================
--事件

--关闭
function ChatPanel:onClose()
  MainUI:Pop();
end

--发送
function ChatPanel:Send(Args)

  local level  = ActorManager.hero:GetLevel();

  if level < 12 and curPageIndex ~= 5 then
    MessageBox:ShowDialog(MessageBoxType.Ok, "レベル12で開放");
    return;
  end


  local args = UIControlEventArgs(Args);
  local msg = {};

  -- showmethemoney!
  ---[[
  local text = sendText.Text
  if text == "/debug" then
    debugmode = not debugmode
    sendText.Text = ""
    ToastMove:CreateToast("debug mode switch " .. tostring(debugmode));
  end
  if text == "/debugtrace" then
    debugtracemode = not debugtracemode
    sendText.Text = ""
    ToastMove:CreateToast("trace effect mode switch" .. tostring(debugtracemode));
    return
  end
  if text == "/debugnodie" then
    debugnodiemode = not debugnodiemode
    sendText.Text = ""
    ToastMove:CreateToast("nodie mode switch " .. tostring(debugnodiemode));
    return
  end
  if text == "/debuginfo" then
    debuginfomode = not debuginfomode
    sendText.Text = ""
    ToastMove:CreateToast("info mode swtich " .. tostring(debuginfomode));
    return
  end


  --]]

  --判空
  if text == "" then
    --limitTimer = timerManager:CreateTimer(Configuration.WorldTalkColdTime, 'ChatPanel:onTimerUpdate', 0);
    --清空发送信息
    sendText.Text = '';
    Toast:MakeToast(Toast.TimeLength_Long, '内容を入力してください!');
    return;
  end
  if (1 == curPageIndex) then			--世界
    if Configuration.WorldChatLevel > ActorManager.hero:GetLevel() then
      ToastMove:CreateToast(LANG__11);
      return;
    end
    msg.type = 1;
    msg.id = 0;
    msg.msg = sendText.Text;
  elseif (2 == curPageIndex) then			--工会
    msg.type = 2;
    msg.id = ActorManager.user_data.ggid;
    msg.msg = sendText.Text;
    sendText.Text = '';
  elseif (3 == curPageIndex) then			--私聊
    if nil == wispIndex then
      MessageBox:ShowDialog(MessageBoxType.Ok, LANG_chatPanel_116);
    else
      msg.type = 3;
      msg.id = wispList[wispIndex].uid;
      --	msg.msg = wispTextInput.Text;
      msg.msg = sendText.Text;
      msg.name = ActorManager.user_data.name;
      msg.vipLevel = ActorManager.user_data.viplevel;
      self:addWisperOfSelf(wispRichTextMessage, msg, LANG_chatPanel_117, Configuration.BlackColor, false);
      --	wispTextInput.Text = '';
      sendText.Text = '';
    end
  elseif (5 == curPageIndex) then --反馈消息
    msg.type = 1;
    msg.id = 1;
    msg.msg = sendText.Text;
    msg.name = ActorManager.user_data.name;
    msg.vipLevel = ActorManager.user_data.viplevel;
    self:addFeedbackOfSelf(feedRichTextMessage,msg, LANG_chatPanel_135, Configuration.BlackColor, false)
    sendText.Text = ''
  end

  --判断发言的时间间隔
  if 0 == msg.id then
    if nil == limitTimer then
      Network:Send(NetworkCmdType.nt_chart, msg, true);
      limitTimer = timerManager:CreateTimer(Configuration.WorldTalkColdTime, 'ChatPanel:onTimerUpdate', 0);
      --清空发送信息
      if 1 == curPageIndex then
        sendText.Text = '';
      else
        sendText.Text = '';
      end
    else
      Toast:MakeToast(Toast.TimeLength_Long, LANG_chatPanel_120 .. Configuration.WorldTalkColdTime .. LANG_chatPanel_121);
    end
  else
    Network:Send(NetworkCmdType.nt_chart, msg, true);
  end

end

--表情按钮点击事件
function ChatPanel:onBtnExpressionClick()
  iconGridExpression.Visibility = Visibility.Visible;
  mainDesktop.FocusControl = iconGridExpression;

  if textBox.Text == LANG_chatPanel_130 then
    textBox.Text = '';
  end

  --创建表情
  for index = 1, Configuration.MaxExpressionCount do
    local armatureUI = uiSystem:CreateControl('ArmatureUI');
    if index <= 10 then
      armatureUI:LoadArmature('biaoqing_' .. index);
    else
      armatureUI:LoadArmature('liaotian_' .. index);
    end
    armatureUI:SetAnimation('play');
    armatureUI.Translate = Vector2(26, 24);
    armatureUI.Pick = false;
    expressionPanelList[index]:AddChild(armatureUI);
  end
end

--表情面板关闭事件
function ChatPanel:onCloseExpression()
  iconGridExpression.Visibility = Visibility.Hidden;

  for _,expressionPanel in ipairs(expressionPanelList) do
    expressionPanel:RemoveAllChildren();
  end
end

--表情面板中的表情的点击事件
function ChatPanel:onExpressionClick(Args)
  local args = UIControlEventArgs(Args);
  local inputControl = sendText;
  --添加表情转义字符
  inputControl.Text = inputControl.Text .. '\\c' .. args.m_pControl.Tag;
  if appFramework:GetStringLengthOfUtf8(inputControl.Text, Configuration.CharToChineseRatio) > Configuration.ChatStrCount and curPageIndex ~= 5 then
    --超过最大字符限制
    inputControl.Text = message;
  else
    --没有超过最大字符限制
    message = inputControl.Text;
  end

  self:onCloseExpression();
end

--表情面板丢失焦点事件
function ChatPanel:onExpressionLoseFocus()
  self:onCloseExpression();
end

--信息弹窗界面失去焦点事件
function ChatPanel:onInfoPopupMenuLoseFocus()
  infoPopupMenu.Visibility = Visibility.Hidden;
end

--字符内容改变事件
function ChatPanel:onTextChange(Args)
  local args = UIControlEventArgs(Args);
  if appFramework:GetStringLengthOfUtf8(args.m_pControl.Text, Configuration.CharToChineseRatio) > Configuration.ChatStrCount and curPageIndex ~= 5 then
    --超过最大字符限制
    args.m_pControl.Text = message;
  else
    --没有超过最大字符限制
    message = args.m_pControl.Text;
  end
end

--标签页切换事件
function ChatPanel:onTabPageChange(Args)
  local args = UITabControlPageChangeEventArgs(Args);
  if args.m_pNewPage == nil then
    return;
  end

  curPageIndex = args.m_pNewPage.Tag;

  if 3 == curPageIndex then
    unReadMsgCount = 0;
    self:updateUnReadMsg();
  end

  if 2 == curPageIndex then
    unReadUnMsgCount = 0;
    self:updateUnReadMsg();
  end

  --清空未读消息
  if 4 == curPageIndex then
    sendText.Visibility = Visibility.Hidden;
    textBox.Visibility = Visibility.Hidden;
    sysTipLable.Visibility = Visibility.Visible;
    sendBtn.Visibility = Visibility.Hidden;
    expBtn.Visibility = Visibility.Hidden;
  else
    sendText.Visibility = Visibility.Visible;
    textBox.Visibility = Visibility.Visible;
    sysTipLable.Visibility = Visibility.Hidden;
    sendBtn.Visibility = Visibility.Visible;
    expBtn.Visibility = Visibility.Visible;
  end
end

--显示聊天
function ChatPanel:onChat(pageIndex, defaultContent)
  if nil == pageIndex then
    pageIndex = 0;
  end
  if pageIndex == 2  and nil ~= defaultContent then
    wdTextInput.Text = defaultContent;
  end
  tabControl.ActiveTabPageIndex = pageIndex;
  curPageIndex = pageIndex + 1;
  MainUI:Push(self);
end

--进入私聊
function ChatPanel:onWisper(uid, name, level)
  --MessageBox:ShowDialog(MessageBoxType.Ok, '未開放');
  ---[[
  self:addTalker(uid, name, level);
  self:Show();
  tabControl.ActiveTabPageIndex = 2;
  curPageIndex = 3;
  --]]
end

--选择聊天者
function ChatPanel:onChooseTalker(Args)
  local args = UIComboboxSelectChangedEventArgs(Args);
  wispIndex = args.m_NewValue + 1;
  wipsText.Text = wispList[wispIndex].name;
  wipsText.TextColor = Configuration.BlackColor;
end

--聊天时间间隔更新
function ChatPanel:onTimerUpdate()
  timerManager:DestroyTimer(limitTimer);
  limitTimer = nil;
end

--显示乱斗场获得积分最高的10名玩家
function ChatPanel:AddScuffleTenPlayer(msg)
  local isLow = true;		--是否是低于25级乱斗场
  if msg.top[1].lv > 25 then
    isLow = false;
  end

  self:showScuffleTenPlayerTitle(wdRichTextMessage, false, Configuration.BlackColor, Configuration.BlackColor, isLow);
  self:showScuffleTenPlayerTitle(sysRichTextMessage, false, Configuration.BlackColor, Configuration.BlackColor, isLow);
  for index, item in ipairs(msg.top) do
    self:AddScuffleOnePlayer(index, item, wdRichTextMessage);
    self:AddScuffleOnePlayer(index, item, sysRichTextMessage);
  end
end

function ChatPanel:AddScuffleOnePlayer(index, item, rtb)
  local underLine_font = uiSystem:FindFont('huakang_20_nobroad');
  local font = uiSystem:FindFont('huakang_20_nobroad');

  local element = TextElement( uiSystem:CreateControl('TextElement') );
  element.TextColor = Configuration.BlackColor;
  element.Font = underLine_font;
  element.Tag = item.uid;
  element.TagExt = item.lv;
  element.Text = item.nickname;
  element:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ChatPanel:onClickInfoPlayer');

  rtb:AddText(LANG_chatPanel_129 .. NumToLevel[index] .. LANG_chatPanel_122, Configuration.BlackColor, font);
  rtb:AppendUIControl(element);
  rtb:AppendText(LANG_chatPanel_123 .. item.score .. LANG_chatPanel_124, Configuration.BlackColor, font);
end

function ChatPanel:showScuffleTenPlayerTitle(rtb, isMainUI, titleColor, textColor, isLow)
  local font = uiSystem:FindFont('huakang_20_nobroad');

  if isMainUI then
    rtb:RemoveAllChildren();
    local level = ActorManager.user_data.role.lvl.level;
    if isLow then
      rtb:AddText(LANG_chatPanel_125, titleColor, font);
      rtb:AddText(LANG_chatPanel_126, textColor, font);
    else
      rtb:AddText(LANG_chatPanel_125, titleColor, font);
      rtb:AddText(LANG_chatPanel_128, textColor, font);
    end
  else
    local level = ActorManager.user_data.role.lvl.level;
    if isLow then
      rtb:AddText(LANG_chatPanel_127, titleColor, font);
      rtb:AppendText(LANG_chatPanel_126, textColor, font);
    else
      rtb:AddText(LANG_chatPanel_127, titleColor, font);
      rtb:AppendText(LANG_chatPanel_128, textColor, font);
    end
  end
end

--更新系统显示
function ChatPanel:updateSys()
  local vscroll = sysPanel:GetLogicChild('ListClip');
  vscroll:VScrollEnd();
  vscroll.VScrollPos = vscroll.VScrollPos + 150;
end

--更新世界频道显示
function ChatPanel:updateWorld()
  local vscroll = tabWorld:GetLogicChild('ListClip');
  vscroll:VScrollEnd();
  vscroll.VScrollPos = vscroll.VScrollPos + 150;
end

--更新公会频道显示
function ChatPanel:updateUnion()
  local vscroll = tabUnion:GetLogicChild('ListClip');
  vscroll:VScrollEnd();
  vscroll.VScrollPos = vscroll.VScrollPos + 150;
end
--更新反馈显示
function ChatPanel:updateFeedback()
  local vscroll = feedbackPanel:GetLogicChild('ListClip');
  vscroll:VScrollEnd();
  vscroll.VScrollPos = vscroll.VScrollPos + 150;
end

--输入文本点击事件
function ChatPanel:ClickText()
  if textBox.Text == LANG_chatPanel_130 then
    textBox.Text = '';
  end
end

function ChatPanel:onchatinfo(msg)
  for index = #msg.infos, 1, -1 do
    ChatPanel:ReceiveMessage(msg.infos[index])
    if msg.infos[index].uid ~= 1 then
      ChatPanel.chatinfo = msg.infos[index];
    end
  end
  timerManager:CreateTimer(1, 'ChatPanel:showchatinfoinmain', 0, true);

end

function ChatPanel:showchatinfoinmain()
  local font = uiSystem:FindFont('huakang_23_nobroad');
  if ChatPanel.chatinfo then
    ChatPanel:infoinmainPanel(labelInMainDesktop, ChatPanel.chatinfo.msg, Configuration.BlackColor, font, ChatPanel.chatinfo.name);
  end
end

function ChatPanel:reqchatinfo()
  Network:Send(NetworkCmdType.req_chat_info, {});
end
