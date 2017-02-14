--newchatPanel.lua
--=============================================================================================
--聊天界面

NewChatPanel =
  {
      roleChatList = {};
      curRoleUid = 0;
      roleSelectedFlag = false;
      msgNum = 100;
      roleItmeNum = 20;
      curTable = {};
      isInit = false;
  };

--变量
local message;										--输入的消息内容
local limitTimer = nil;							--世界聊天的时间间隔触发器
local expressionPanelList = {};
local isShow;

--控件
local labelInMainDesktop;
local mainDesktop;
local panel;

local btnClose;
local sendText;
local sendBtn;
local textBox;
local expBtn;
local roleName;           
local contentScrollPanel; 
local contentStackPanel;  
local roleListScrollPanel;
local roleListStackPanel; 
local contentBg;          

--初始化
function NewChatPanel:InitPanel(desktop)
  --变量初始化
  self.roleChatList = {};
  self.curTable = {};
  self.curRoleUid = 0;
  self.roleSelectedFlag = false;
  self.isInit = false;
  self.msgNum = 100;
  self.roleItmeNum = 20;
  --控件初始化
  mainDesktop = desktop;
  panel = Panel(desktop:GetLogicChild('ChatPanel'));
  panel:IncRefCount();
  panel.ZOrder = PanelZOrder.chatPanelZOrder;
  panel.Visibility = Visibility.Visible;
  panel:SetUIStoryBoard("storyboard.newChatPanelOut");
  btnClose = Button(panel:GetLogicChild('arrow'));
  btnClose:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'NewChatPanel:Hide');
  sendText = panel:GetLogicChild('TextBox'):GetLogicChild('findLabel');
  textBox = panel:GetLogicChild('TextBox')
  sendBtn = panel:GetLogicChild('SendButton');
  sendBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'NewChatPanel:Send');
  expBtn = panel:GetLogicChild('expression');

  windowPanel = panel:GetLogicChild('windowPanel')
  windowPanel:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'NewChatPanel:onwindowPanelLoseFocus');
  windowPanel.Visibility = Visibility.Hidden

  iconGridExpression = panel:GetLogicChild('expression1');
  iconGridExpression.Visibility = Visibility.Hidden;
  for index = 1, Configuration.MaxExpressionCount do
    local expressionPanel = iconGridExpression:GetLogicChild(tostring(index));
    expressionPanel.Tag = index + 10;
    expressionPanel:SubscribeScriptedEvent('UIControl::MouseDownEvent', 'NewChatPanel:onExpressionClick');
    table.insert(expressionPanelList, expressionPanel);
  end
    roleName            = panel:GetLogicChild('roleName');
    roleName.Text = '';
    contentScrollPanel  = panel:GetLogicChild('contentScrollPanel');
    contentStackPanel   = contentScrollPanel:GetLogicChild('contentStackPanel');
    roleListScrollPanel = panel:GetLogicChild('roleListScrollPanel');
    roleListStackPanel  = roleListScrollPanel:GetLogicChild('roleListStackPanel');
    contentBg           = panel:GetLogicChild('contentBg');
    addFriendButton     = panel:GetLogicChild('addFriendButton');
    addFriendButton:SubscribeScriptedEvent('Button::ClickEvent','NewChatPanel:addFriendButtonClick');

    panel.Background = CreateTextureBrush('chat/chat_bg_img.ccz','godsSenki');
    textBox.Background = CreateTextureBrush('chat/chat_bg_img_2.ccz','godsSenki');
    contentBg.Background = CreateTextureBrush('chat/chat_bg_img_1.ccz','godsSenki');
    iconGridExpression.Background = CreateTextureBrush('chat/chat_bg_img_1.ccz','godsSenki');
    self:initChatInfo();
end
function NewChatPanel:initChatInfo()
    local roleDate = ActorManager.user_data.extra_data.last_chat_info;
    --print();
    if roleDate then
        if #roleDate > 0 then
            for _,date in pairs(roleDate) do
                self:addTalker(date.uid, date.name, date.grade,date.resid,date.stmp,false,true);
            end
            self:updateRoleList();
            local curDate = self.curTable[1];
            print('initChatInfo-uid->'..type(curDate.uid));
            self.isInit = true;
            self:onWisper(tonumber(curDate.uid));
        end
    end
end
function NewChatPanel:onwindowPanelLoseFocus()
  windowPanel.Visibility = Visibility.Hidden
end

--销毁
function NewChatPanel:Destroy()
  panel:DecRefCount();
  panel = nil;
end

--显示
function NewChatPanel:Show()
  StoryBoard:OnPopPlayingUI();
  mainDesktop:DoModal(panel);
  panel:SetUIStoryBoard("storyboard.newChatPanelIn");
  isShow = true;
  self:updateNewMsgTip();
end

--隐藏
function NewChatPanel:Hide()
  panel:SetUIStoryBoard("storyboard.newChatPanelOut");
  isShow = false;
  mainDesktop:UndoModal();
  self:updateNewMsgTip();
end

--聊天界面是否显示
function NewChatPanel:IsShow()
  return isShow;
end
--=======================================================================================
--功能函数
function NewChatPanel:addFriendButtonClick()
    if self.curRoleUid == 0 then
        return;
    end
    if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.friendlist then
        Toast:MakeToast(Toast.TimeLength_Long, LANG_CityPerson_2);
        return;
    end
    Friend:onAddFriend(self.curRoleUid);
end
function NewChatPanel:addRoleMsg(uid,msg)
    if self.roleChatList[tostring(uid)] then 
        local curRole = self.roleChatList[tostring(uid)];
        if #curRole.msgList > self.msgNum then
            table.remove(curRole.msgList,1);
        end
        table.insert(curRole.msgList,msg);
    end
end
--进入私聊
function NewChatPanel:onWisper(uid)
  local curRole = self.roleChatList[tostring(uid)];
  if curRole and not curRole.isGetMsg then
      curRole.info.curIsFirst = 1;
      self:updateRoleList();
      curRole.info.curIsFirst = 0;
      self:setRoleSelected(uid,true);
      self.curRoleUid = uid;
      self:refreshAllMsg(self.curRoleUid);
      if not isShow then
          self:Show();
      end
      return;
  end
  local msg = {};
  msg.player_uid = uid;
  Network:Send(NetworkCmdType.req_private_chat_info_t,msg);
end 
function NewChatPanel:onGetPlayerMessage(msg)
    contentStackPanel:RemoveAllChildren();
    
    self:addTalker(msg.player_uid,msg.name,msg.level,msg.resid,msg.stamp,false,false);
    local curRole = self.roleChatList[tostring(msg.player_uid)];
    for _,curMsg in pairs (msg.private_chat_infos) do
      if curRole and curMsg then
        self:addRoleMsg(msg.player_uid,curMsg);
      end 
    end
    if not self.roleSelectedFlag then
        self:updateRoleList();
        self:setRoleSelected(msg.player_uid,true);
    end
    self.roleSelectedFlag = false;
    self.curRoleUid = msg.player_uid;
    self:refreshAllMsg(self.curRoleUid);
    if not isShow and not self.isInit then
      self:Show();
    end
    self.isInit = false;
    self:updateNewMsgTip();
end
function NewChatPanel:setRoleSelected(uid,isSelected)
    local curRole = self.roleChatList[tostring(uid)];
    if curRole then
        curRole.roleControl.setSelected(isSelected);
    end
end
--添加私聊玩家
function NewChatPanel:addTalker(uid, name, level,resid,stamp,isNewMsg,isGetMsg)
    --print('addTalker-uid->'..tostring(uid)..' name->'..tostring(name)..' level->'..tostring(level)..' resid->'..tostring(resid)..' stamp->'..tostring(stamp));
    local curRole = self.roleChatList[tostring(uid)];
    roleListScrollPanel:VScrollBegin();
    if not curRole then
        self.roleChatList[tostring(uid)] = {};
        curRole = self.roleChatList[tostring(uid)];
        curRole.msgList = {};
    end
    curRole.info = {curUid = uid, curName = name, curLevel = level,curResid = resid, curStamp = stamp,curIsFirst = 0};
    curRole.isNewMsg = (isNewMsg == nil and false) or isNewMsg;
    curRole.isGetMsg = (isGetMsg == nil and false) or isGetMsg;
end

function NewChatPanel:updateRoleList()
    self.curTable = {};
    for curUid,curRoleInfo in pairs(self.roleChatList) do
        --print('isNewMsg->'..tostring(curRoleInfo.isNewMsg));
        --print('curUid->'..tostring(curUid)..' -stamp->'..tostring(curRoleInfo.info.curStamp));
        table.insert(self.curTable,{uid = tonumber(curUid),stamp = curRoleInfo.info.curStamp,first = curRoleInfo.info.curIsFirst});
    end
    local function sort_(role1,role2)
        if role1.first ~= role2.first then
            return role1.first > role2.first;
        else
            return role1.stamp > role2.stamp;
        end
    end
    if #self.curTable > 1 then
      table.sort(self.curTable,sort_);
    end
    roleListStackPanel:RemoveAllChildren();
    local totleNum = #self.curTable;
    if totleNum > self.roleItmeNum then
        totleNum = self.roleItmeNum;
    end
    for i = 1, totleNum do
      local curInfo = self.curTable[i];
      if self.roleChatList[tostring(curInfo.uid)] then
          local curRole = self.roleChatList[tostring(curInfo.uid)];
          --print('for-uid->'..tostring(curInfo.uid)..' isNewMsg->'..tostring(curRole.isNewMsg));
          curRole.roleControl = nil;
          curRole.roleControl = customUserControl.new(roleListStackPanel,'chatRoleItemTemplate');
          curRole.roleControl.initWithInfo(curRole.info.curUid, curRole.info.curName, curRole.info.curLevel,curRole.info.curResid);
          curRole.roleControl.setTipShow(curRole.isNewMsg);
      end
    end
    self:updateNewMsgTip();
end
--推送消息
function NewChatPanel:getPushMessage(msg)
    --print('msg.uid->'..tostring(msg.uid)..' self.curUid->'..tostring(self.curRoleUid));
    local curRole = self.roleChatList[tostring(msg.uid)];
    if not curRole or (curRole and curRole.isGetMsg) then
        self:addTalker(msg.uid, msg.name, msg.lv,msg.resid,msg.stmp,true,true);
    else
        local isNewMsg = true;
        if msg.uid == self.curRoleUid and (curRole and not curRole.isGetMsg) then
            isNewMsg = false;
            if not isShow then
                MenuPanel:ChatTip(true);
            end
        end
        --print('getPushMessage-isNewMsg-1->'..tostring(isNewMsg));
        self:addRoleMsg(msg.uid,msg);
        --table.insert(curRole.msgList,msg);
        curRole.info.curStamp = msg.stmp;
        curRole.isNewMsg = isNewMsg;
        curRole.isGetMsg = false;
    end
    
    if msg.uid == self.curRoleUid and (curRole and not curRole.isGetMsg) then
        self:ReceiveMessage(msg);
        curRole.isNewMsg = false;
        --print('getPushMessage-isNewMsg-2->'..tostring(curRole.isNewMsg));
    else
        self:updateRoleList();
        if self.curRoleUid ~= 0 then
            self:setRoleSelected(self.curRoleUid,true);
        end
    end
end
--选择玩家
function NewChatPanel:roleSelectedEvent(Args)
    --print('roleSelectedEvent--->');
    local args = UIControlEventArgs(Args);
    local curUid = args.m_pControl.Tag;
    self:setRoleSelected(curUid,true);
    self.curRoleUid = curUid;
    if self.roleChatList[tostring(curUid)] then
        local curRole = self.roleChatList[tostring(curUid)];
        if curRole.isGetMsg then
            self.roleSelectedFlag = true;
            self:onWisper(curUid);
        else
            self:refreshAllMsg(self.curRoleUid);
        end
    end
end 
function NewChatPanel:updateNewMsgTip()
    for _,curRole in pairs(self.roleChatList) do
        if curRole.isNewMsg then
            MenuPanel:ChatTip(true);
            return;
        end
    end
    MenuPanel:ChatTip(false);
end
function NewChatPanel:refreshAllMsg(uid)
  local curUid = uid;
  if self.roleChatList[tostring(curUid)] then
      local curRole = self.roleChatList[tostring(curUid)];
      contentStackPanel:RemoveAllChildren();
      for _,msg in pairs(curRole.msgList) do
          self:ReceiveMessage(msg);
      end
      curRole.isNewMsg = false;
      curRole.roleControl.setTipShow(curRole.isNewMsg);
      if Friend:isMyFriend(uid) then
          addFriendButton.Visibility = Visibility.Hidden;
      else
          addFriendButton.Visibility = Visibility.Visible;
      end
      roleName.Text = tostring(curRole.info.curName);
    end
end
--添加聊天信息
function NewChatPanel:ReceiveMessage(msg)
  --替换屏蔽字
    msg.msg = LimitedWord:replaceLimited(msg.msg);
    self:AddMsgToRTB(contentStackPanel, msg, LANG_chatPanel_8, Configuration.BlackColor, false);
    contentScrollPanel:VScrollEnd();
    contentScrollPanel.VScrollPos = contentScrollPanel.VScrollPos + 150;
end

--显示自己发送的私聊信息
function NewChatPanel:addWisperOfSelf(rtb, message, title, color, isMainUI)
  ChatPanel.feedbackSize = true;
  color = Configuration.BlackColor;
  local underLine_font = uiSystem:FindFont('huakang_20_nobroad');
  local font = uiSystem:FindFont('huakang_20_nobroad');

  local chatInfo  = customUserControl.new(rtb, 'rightChatTemplate');
  chatInfo.initInfo(rtb, message, title, color, font, isMainUI);
  contentScrollPanel:VScrollEnd();
  contentScrollPanel.VScrollPos = contentScrollPanel.VScrollPos + 150;
  ChatPanel.feedbackSize = false;
end

--显示服务器发送的聊天信息
function NewChatPanel:AddMsgToRTB(rtb, msg, title, color, isMainUI)
  color = Configuration.BlackColor
  local underLine_font = uiSystem:FindFont('huakang_20_nobroad');
  local font = uiSystem:FindFont('huakang_20_nobroad');
  if (msg.uid == ActorManager.user_data.uid) then		--主城和公会界面添加自己的消息
    local chatInfo  = customUserControl.new(rtb, 'rightChatTemplate');
    chatInfo.initInfo(rtb, msg, title, color, font, isMainUI);
  elseif msg.uid == Configuration.SystemUID then		--系统消息
  else
    local chatInfo  = customUserControl.new(rtb, 'leftChatTemplate');
    chatInfo.initInfo(rtb, msg, title, color, font, isMainUI);
    chatInfo.setIconClickEvent('NewChatPanel:iconClickEvent')
  end
end

function NewChatPanel:iconClickEvent(Args)
  local args = UIControlEventArgs(Args);
  otherUid = args.m_pControl.Tag;

  PersonInfoPanel:ReqOtherInfosClick(otherUid)

end

function NewChatPanel:checkBtnClickEvent()
  PersonInfoPanel:ReqOtherInfosClick(otherUid)
  windowPanel.Visibility = Visibility.Hidden
end

--=======================================================================================
--事件

--关闭
function NewChatPanel:onClose()
  MainUI:Pop();
end

--发送
function NewChatPanel:Send(Args)

    local level  = ActorManager.hero:GetLevel();
  
    if level < 12 then
      MessageBox:ShowDialog(MessageBoxType.Ok, "レベル12で開放");
      return;
    end
    if self.curRoleUid == 0 then
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
      --limitTimer = timerManager:CreateTimer(Configuration.WorldTalkColdTime, 'NewChatPanel:onTimerUpdate', 0);
      --清空发送信息
      sendText.Text = '';
      Toast:MakeToast(Toast.TimeLength_Long, '内容を入力してください!');
      return;
    end			--私聊
    msg.type = 3;
    msg.id = self.curRoleUid;
    msg.msg = sendText.Text;
    msg.name = ActorManager.user_data.name;
    msg.vipLevel = ActorManager.user_data.viplevel;
    self:addWisperOfSelf(contentStackPanel, msg, LANG_chatPanel_117, Configuration.BlackColor, false);
    sendText.Text = '';
    local curRole = self.roleChatList[tostring(self.curRoleUid)];
    if curRole then
        local m = {};
        m.type = 3;
        m.resid = ActorManager.user_data.role.resid;
        m.quality = ActorManager.user_data.role.quality;
        m.msg = msg.msg;
        m.uid = ActorManager.user_data.uid;
        m.vipLevel = ActorManager.user_data.viplevel;
        m.lv = ActorManager.user_data.role.lvl.level;
        m.name = ActorManager.user_data.role.name;
        m.stmp = 0;
        m.lovelevel = ActorManager.user_data.role.lvl.lovelevel;
        self:addRoleMsg(self.curRoleUid,m);
    end
    Network:Send(NetworkCmdType.nt_chart, msg, true);
end

--表情按钮点击事件
function NewChatPanel:onBtnExpressionClick()
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
function NewChatPanel:onCloseExpression()
  iconGridExpression.Visibility = Visibility.Hidden;

  for _,expressionPanel in ipairs(expressionPanelList) do
    expressionPanel:RemoveAllChildren();
  end
end

--表情面板中的表情的点击事件
function NewChatPanel:onExpressionClick(Args)
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
function NewChatPanel:onExpressionLoseFocus()
  self:onCloseExpression();
end

--信息弹窗界面失去焦点事件
function NewChatPanel:onInfoPopupMenuLoseFocus()
  infoPopupMenu.Visibility = Visibility.Hidden;
end

--字符内容改变事件
function NewChatPanel:onTextChange(Args)
  local args = UIControlEventArgs(Args);
  if appFramework:GetStringLengthOfUtf8(args.m_pControl.Text, Configuration.CharToChineseRatio) > Configuration.ChatStrCount and curPageIndex ~= 5 then
    --超过最大字符限制
    args.m_pControl.Text = message;
  else
    --没有超过最大字符限制
    message = args.m_pControl.Text;
  end
end

--输入文本点击事件
function NewChatPanel:ClickText()
  if textBox.Text == LANG_chatPanel_130 then
    textBox.Text = '';
  end
end