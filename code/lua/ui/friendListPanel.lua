--friendListPanel.lua
--好友列表

FriendListPanel = 
	{
	};

--变量
local isVisible;
local btnGetFlower = {};
local btnApplyList = {};
local selectFriendId;
local selectFriendLv;
local selectFriendName;
local selectFriendResid;
local currentSelectFriend;
local friendItemList = {};
local currentSelectIndex;
local s_state;      --控制点击好友列表显示与不显示
local mainCircle;   --就是申请列表上面的红色圆圈
local s_worlds;     --文本框内容
local timer;        --定时器
local flowerTimer;

--控件
local mainDesktop;
local panel;
local listFriend;
local btnFind;
local numFlower;
local btnDetail;
local btnTalk;
local btnDelFriend;
local panelDetail;
local textboxName;
local textboxNameBox;
local clipList;
local friendItem;
local numLabel;
local friendScrollBar;
local restartTime;
--初始化
function FriendListPanel:InitPanel(desktop)
	--变量
	isVisible = false;
	currentSelectFriend = nil;
	currentSelectIndex = nil;
	flowerTimer = nil;
	restartTime = true;
	--控件
	mainDesktop = desktop;
	panel = mainDesktop:GetLogicChild('FriendListPanel');
	panel:IncRefCount();
	panel.ZOrder = PanelZOrder.friendList;
	panel.Visibility = Visibility.Hidden;
	listFriend = panel:GetLogicChild('ListClip'):GetLogicChild('List');
	clipList = panel:GetLogicChild('ListClip');
	numFlower = panel:GetLogicChild('numFlower');
	textboxNameBox = panel:GetLogicChild('findLabelBox');
	textboxName = textboxNameBox:GetLogicChild('findLabel');
	local maincircle1 = panel:GetLogicChild('friendCircle1');
	local maincircle2 = panel:GetLogicChild('friendCircle2');
	numLabel = panel:GetLogicChild('numLabel');
	mainCircle = {maincircle1, maincircle2};
	textboxName:SubscribeScriptedEvent('Label::TextChangedEvent', 'FriendListPanel:onTextChange');
    textboxName:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'FriendListPanel:onResumeInput'); 
    --textboxName.Text = '输入玩家ID';
	btnFind = panel:GetLogicChild('addButton');
	btnFind:SubscribeScriptedEvent('Button::ClickEvent', 'FriendListPanel:findFriend');
	friendScrollBar = clipList:GetInnerVScrollBar();
	friendScrollBar:SubscribeScriptedEvent('ScrollBar::ScrolledEvent', 'FriendListPanel:onFriendListScroll');

	btnGetFlower = 
	{
		init = function(self)
			panel:GetLogicChild('acceptButton'):SubscribeScriptedEvent('Button::ClickEvent', 'FriendListPanel:onClickGetFlower');
			self.setHaveFlower(false);
		end,
		setHaveFlower = function(self, flag)
			panel:GetLogicChild('acceptButton'):GetLogicChild('cricle').Visibility = flag and Visibility.Visible or Visibility.Hidden;
		end,
	}
	btnGetFlower:init();

	btnApplyList = 
	{
		init = function(self)
			panel:GetLogicChild('applyButton'):SubscribeScriptedEvent('Button::ClickEvent', 'FriendListPanel:onClickApplyList');
			self.setHaveApply(false);
		end,
		setHaveApply = function(self, flag)
			panel:GetLogicChild('applyButton'):GetLogicChild('cricle').Visibility = flag and Visibility.Visible or Visibility.Hidden;
		end,
	}
	btnApplyList:init();
	panelDetail = panel:GetLogicChild('windowPanel');
	panelDetail.Visibility = Visibility.Hidden;
	btnDetail = panelDetail:GetLogicChild('checkButton');
	btnDetail:SubscribeScriptedEvent('Button::ClickEvent', 'FriendListPanel:onDetailFriend');
	btnTalk = panelDetail:GetLogicChild('chatButton');
	btnTalk:SubscribeScriptedEvent('Button::ClickEvent', 'FriendListPanel:onChat');
	btnDelFriend = panelDetail:GetLogicChild('breakButton');
	btnDelFriend:SubscribeScriptedEvent('Button::ClickEvent', 'FriendListPanel:onDelFriend');
	panel:GetLogicChild('close'):SubscribeScriptedEvent('Button::ClickEvent', 'FriendListPanel:onClose');
end

function FriendListPanel:getUserGuideApplyBtn()
	return panel:GetLogicChild('applyButton');
end

function FriendListPanel:getUserGuideReceiveBtn()
	return panel:GetLogicChild('acceptButton');
end
--销毁
function FriendListPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

function FriendListPanel:VisibleMainCircle()
    return mainCircle;
end


--显示
function FriendListPanel:Show()  
	if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.friendlist then
		Toast:MakeToast(Toast.TimeLength_Long, '友達機能はレベル18で開放されます');
		return;
	end
    s_state = true;
	panel.Visibility = Visibility.Visible;
	panelDetail.Visibility = Visibility.Hidden;
	if(friendItem) then
        friendItem.ctrlHide();
	end
	isVisible = true;
    numLabel.Text = string.format(LANG_FRIEND_UIDWORLD, tonumber(ActorManager.user_data.uid));
	FriendFlowerPanel.newFlower = false
	self:requireFriendList();
	self:requireFlowerList();
    if(#textboxNameBox.Text == 0) then
       textboxName.Text = '';
       textboxNameBox.Text = '  IDを入力してください';
    end
	
	timer = timerManager:CreateTimer(6, 'FriendListPanel:refreshControl', 0);
	self:requireFriendApplyList();

end

function FriendListPanel:guideReceiveHeart()
	if UserGuidePanel:IsInGuidence(UserGuideIndex.heart, 1) then
		panel:GetLogicChild('friendCircle1').Visibility = Visibility.Visible;
		UserGuidePanel:ShowGuideShade( FriendListPanel:getUserGuideReceiveBtn(),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
		listFriend:RemoveAllChildren();
		local friend = {
			name = '麻麻';
			lv = 1;
			fp = 0;
			uid = 1;
		}
		local item = customUserControl.new(listFriend, 'FriendFlowerTemplate');
		item.initWithRole(friend);			
	end

end
--隐藏
function FriendListPanel:Hide()
	panel.Visibility = Visibility.Hidden;
	isVisible = false;
end

--请求好友列表
function FriendListPanel:requireFriendList()
	local msg = {};
	msg.page = 0;
	Network:Send(NetworkCmdType.req_friend_list, msg);
end

--滑动
function FriendListPanel:onFriendListScroll()
	if friendScrollBar.Value == friendScrollBar.Maximum  and Friend.isRemain then
		local msg = {};
		msg.page = Friend.page;
		Network:Send(NetworkCmdType.req_friend_list, msg, true);
	end
end

--请求鲜花列表
function FriendListPanel:requireFlowerList()
	--flowerfix
	return;
	--[[
	local msg = {};
	msg.uid = 1; --完全没用的数据
	Network:Send(NetworkCmdType.req_flower_list, msg);
	--]]
end

--请求好友申请列表
function FriendListPanel:requireFriendApplyList()
	local msg = {};
	Network:Send(NetworkCmdType.req_friend_addlist, {});
end

--刷新好友列表
function FriendListPanel:refreshFriendList()
    s_state = true;
	local friendList = Friend:getSortFriendList();
	listFriend:RemoveAllChildren();
	friendItemList = {};
	--friendList = {{lv = 3},{lv = 3},{lv = 3},{lv = 3},{lv = 3}};
	for id, friend in pairs(friendList) do	 
		friendItem = customUserControl.new(listFriend, 'FriendFlowerTemplate');
		friendItem.initWithRole(friend);			
		friendItem.setTag(id);
		friendItemList[id] = friendItem;
	end
	if #friendList == 0 then
		friendItem = nil;
	end
	-- if Friend.numFlower == 0 then
	-- 	if flowerTimer == nil then
	-- 		flowerTimer = timerManager:CreateTimer(1, 'FriendListPanel:refreshFlower', 0);
	-- 	end
	-- end
	
	numFlower.Text = tostring(Friend.numFlower);
	
	Friend:UpdateSendFlowerTip()

	

end


function FriendListPanel:refreshFlower()
	local timestamp = Friend.flowerStamp;
	if timestamp <= 0 then
		Friend.numFlower = 1;
		numFlower.Text = tostring(1);
		Friend:UpdateSendFlowerTip()
		timerManager:DestroyTimer(flowerTimer);
		return;
	end
	local one_minute = 60;
	local minute,_ = math.modf(Friend.flowerStamp/60);
	local second = Friend.flowerStamp % 60;
	if minute < 10 then
		minute = '0'..tostring(minute);
	end
	if second < 10 then
		second = '0'..tostring(second);
	end
	
	numFlower.Text = '  '..tostring(minute)..':'..tostring(second);
	Friend.flowerStamp = Friend.flowerStamp - 1;
end

--========================================================
--功能函数
--关闭
function FriendListPanel:onClose()
	 self:Hide();
	 if timer then
		 timerManager:DestroyTimer(timer);                    --此时应该关掉定时器
	 end
	 if flowerTimer ~= nil then
		 timerManager:DestroyTimer(flowerTimer);
		 flowerTimer = nil
	 end
	 timer = 0;
end

--是否可见
function FriendListPanel:IsVisible()
	return isVisible;
end

function FriendListPanel:refreshControl()                 --刷新当时是否有好友申请和送花
    if(FriendListPanel:IsVisible() ) then
		--self:requireFlowerList();
		self:requireFriendApplyList();
    end
end

--点击接受鲜花按钮
function FriendListPanel:onClickGetFlower()
	FriendFlowerPanel:Show();
end

--点击申请列表
function FriendListPanel:onClickApplyList()
	FriendApplyPanel:Show();
	--self:requireFriendList();
end

--选择好友
local index;
function FriendListPanel:onSelectFriend(Args)
	local args = UIControlEventArgs(Args);
	index = args.m_pControl.Tag;
	currentSelectFriend = friendItemList[index];
	currentSelectFriend.setSelected(true);
	selectFriendId = currentSelectFriend.getUid();
	selectFriendName = currentSelectFriend.getName();
	selectFriendLv= currentSelectFriend.getLv();
	selectFriendResid = currentSelectFriend.getResid();
	if(s_state or self.tag ~= index ) then	     --s_state 记录点击好友详情的时候是隐藏还是不隐藏
	  if(self.stateRecord) then
	  	self.stateRecord = false;
	  	self:keepQuote(index);
        panelDetail.Visibility = Visibility.Hidden;
      else
      	s_state = false;
      	panelDetail.Visibility = Visibility.Visible;
      	self:keepQuote(index);
      end    
    else
      s_state = true;
      panelDetail.Visibility = Visibility.Hidden;
	end
end

function FriendListPanel:keepQuote(tag)   --保留一份变量的引用
	self.tag = tag ;  
end

--查看好友
function FriendListPanel:onDetailFriend()
    if(selectFriendId) then
        PersonInfoPanel:ReqOtherInfos(selectFriendId);
    end 
end

--与好友私聊
function FriendListPanel:onChat()
    if(index) then
       NewChatPanel:onWisper(selectFriendId);
    end
end

function FriendListPanel:onTextChange(Args)
	local args = UIControlEventArgs(Args);
	s_worlds = args.m_pControl.Text;
end

function FriendListPanel:onResumeInput()	
	textboxNameBox.Text ='';
	textboxName.Text = '   ';
end

--查找好友
function FriendListPanel:findFriend()
  local s_type = tonumber(s_worlds);
  if(s_type) then
     Friend:onAddFriend(s_type);
  else
     Toast:MakeToast(Toast.TimeLength_Long, 'IDを入力してください');
  end
end
--点击与好友绝交
function FriendListPanel:onDelFriend(Args)
	local okDelegate = Delegate.new(FriendPanel, FriendListPanel.deleteFriend);
	MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_friendPanel_2, okDelegate);
end

function FriendListPanel:deleteFriend()
	local msg = {};
	msg.uid = selectFriendId;
	Network:Send(NetworkCmdType.req_friend_del, msg, true);
	panelDetail.Visibility = Visibility.Hidden;
end


--移动详情界面
function moveDetailPanel(y)
	panelDetail.Margin = Rect(300,y + 147, 0, 0);
end

function FriendListPanel:setHaveFlowerStatus(flag)
	btnGetFlower.setHaveFlower(flag);
end

function FriendListPanel:setHaveApplyStatus(flag)
	btnApplyList.setHaveApply(flag);
end

--送花
local currentSelectIndex; 
function FriendListPanel:sendFlower(Args)
    self.stateRecord = true;                            --状态是限制详情地板是否隐藏的
	local args = UIControlEventArgs(Args);
	currentSelectIndex = args.m_pControl.Tag;

	-- 检测鲜花数量是否足够
	if Friend.numFlower <= 0 then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_NO_HEART_TO_SENT);
		return;
	end
	local msg = {};
	msg.uid = friendItemList[currentSelectIndex].getUid();
	msg.name = ActorManager.user_data.name;
	Network:Send(NetworkCmdType.req_send_flower, msg, true);
end

function FriendListPanel:haveGiveFlower(msg)
	ToastMove:CreateToast('该玩家已经送过花了哦', Configuration.GreenColor);
end

function FriendListPanel:onRetSendFlower(msg)
	friendItemList[currentSelectIndex].setHasSendFlower();
    Toast:MakeToast(Toast.TimeLength_Long, string.format(LANG_FRIEND_FLOWER_SENDHEARD_WORLD, friendItemList[currentSelectIndex].getName()));
    if(tonumber(Friend.numFlower) <= 0 ) then
		--numFlower.TextColor = Configuration.RedColor;
    end
    numFlower.Text = tostring(Friend.numFlower);
    --朋友送花状态改变
    local tempFriend = Friend:getSortFriendList()
	for id, friend in pairs(tempFriend) do
		if id == currentSelectIndex then
			friend.checkGiveState = 1;
			break;
		end
	end

	Friend:UpdateSendFlowerTip()
	--FriendListPanel:refreshFriendList()
end
