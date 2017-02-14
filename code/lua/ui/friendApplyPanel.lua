--friendApplyPanel.lua
FriendApplyPanel = 
{
}

--常量？
local RequestAccept = 0;               --同意好友请求
local RequestReject = 1;               --拒绝好友请求


--变量
local applyList;
local requestUid;
local requestType;
local onIsApply;
local maincircle;
--控件
local maindesktop;
local panel;
local listApply;
local btnClose;
local btnAgreeAll;
local btnIgnoreAll;

--初始化
function FriendApplyPanel:InitPanel(desktop)
	--变量
	requestUid = nil;					   --好友id
	onIsApply = false;
	requestType = nil;					   --接受或拒绝

	--控件
	maindesktop = desktop;
	panel = maindesktop:GetLogicChild('FriendRequirePanel');
	panel:IncRefCount();
	panel.Visibility = Visibility.Hidden;
	panel.ZOrder = PanelZOrder.friendApply;

	btnAgreeAll = panel:GetLogicChild('requirePanel'):GetLogicChild('agreeButton');
	btnAgreeAll.Text = '全部拒否';
	btnAgreeAll:SubscribeScriptedEvent('Button::ClickEvent', 'FriendApplyPanel:onIgnoreAll');
	btnIgnoreAll = panel:GetLogicChild('requirePanel'):GetLogicChild('ignoreButton');
	local title = panel:GetLogicChild('requirePanel'):GetLogicChild('title');
    title.TextColor = QualityColor[6];
	btnIgnoreAll.Visibility = Visibility.Hidden;
	btnClose = panel:GetLogicChild('requirePanel'):GetLogicChild('close');
	btnClose:SubscribeScriptedEvent('Button::ClickEvent', 'FriendApplyPanel:onClose');
    local title = panel:GetLogicChild('requirePanel'):GetLogicChild('title');
    title.TextColor = QualityColor[6];
	listApply = panel:GetLogicChild('requirePanel'):GetLogicChild('ListClip'):GetLogicChild('List');
	maincircle = FriendListPanel:VisibleMainCircle();
end

--销毁
function FriendApplyPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--展现
function FriendApplyPanel:Show()	  
	 if(onIsApply) then
        panel.Visibility = Visibility.Visible;    
     else
     	Toast:MakeToast(Toast.TimeLength_Long, '申請リストはありません');
     end
end

--隐藏
function FriendApplyPanel:Hide()
	panel.Visibility = Visibility.Hidden;
end

--刷新
local s_allUid = {};
function FriendApplyPanel:refresh(msg)
	applyList = {};
		if(msg.list and #msg.list > 0) then
			maincircle[2].Visibility = Visibility.Visible;
		else
			maincircle[2].Visibility = Visibility.Hidden;
		end
		listApply:RemoveAllChildren();
		--msg.list = {{uid = 125582, name = 123}, {uid = 125541 , name = 456}, {uid = 125542, name = 567}};                  --测试假数据数据
		for _, apply in pairs(msg.list) do
			onIsApply = true;
			local applyItem = customUserControl.new(listApply, 'FriendInfoTemplate');
			applyItem.initWithInfo(apply, apply.uid);
			table.insert(s_allUid, apply.uid);
			applyList[apply.uid] = applyItem;
		end
end
--============================================================
--功能函数
--关闭
function FriendApplyPanel:onClose()
	self:Hide();
end

--全部同意   
--[[function FriendApplyPanel:onAgreeAll()
  local msg = {};
  onIgnorestate = true;
  for i = 1, #s_allUid do
    msg.uid = s_allUid[i];
    msg.reject = RequestAccept;	
    Network:Send(NetworkCmdType.req_friend_add_res, msg);
  end
   FriendListPanel:requireFriendList();
end--]]

--全部忽略
function FriendApplyPanel:onIgnoreAll()
	local msg = {};
    if(#s_allUid > 0 ) then
    maincircle[2].Visibility = Visibility.Hidden;
	for i = 1 ,#s_allUid do	
	     msg.uid = s_allUid[i];
	     msg.reject = RequestReject;	
	     Network:Send(NetworkCmdType.req_friend_add_res, msg); 
	     if(applyList[s_allUid[i]]) then
            applyList[s_allUid[i]]:BeRemoved();
	        applyList[s_allUid[i]] = nil;
	        ActorManager.user_data.counts.n_friend = ActorManager.user_data.counts.n_friend - 1;
	     end          
    end
   end
   Friend:UpdateFetchFriendTip()
end


function FriendApplyPanel:onAgree(Args)       --忽略   --改过UI编辑器 这个按钮调换位置了
	local args = UIControlEventArgs(Args);
	local uid = args.m_pControl.Tag;
	local msg = {};
	msg.uid = uid;
	msg.reject = RequestReject;	
	Network:Send(NetworkCmdType.req_friend_add_res, msg);
	requestUid = msg.uid;
	requestType = RequestAccept;
end

function FriendApplyPanel:onIgnore(Args)       --同意
		onIsApply = false;
		local args = UIControlEventArgs(Args);
		local uid = args.m_pControl.Tag;
		local msg = {};
		msg.uid = uid;
		msg.reject = RequestAccept;	
		Network:Send(NetworkCmdType.req_friend_add_res, msg);
		requestUid = msg.uid;
		requestType = RequestAccept;
		FriendListPanel:requireFriendList();       --添加到好友列表里面去
end

function FriendApplyPanel:IsShow()
	return panel.Visibility == Visibility.Visible;
end

--返回处理请求结果
function FriendApplyPanel:onAcceptOrReject(msg)
	if requestUid ~= msg.uid then
		return;
	end 
	if applyList[msg.uid] then
		applyList[msg.uid]:BeRemoved();
		applyList[msg.uid] = nil;
		ActorManager.user_data.counts.n_friend = ActorManager.user_data.counts.n_friend - 1;
	end
	Friend:UpdateFetchFriendTip()
end
