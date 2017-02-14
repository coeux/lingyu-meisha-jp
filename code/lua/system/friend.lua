--friend.lua

--========================================================================
--好友类

Friend =
	{
		hasFetchFriend = false;	--好友列表是否申请过
		friendList = {};        	--好友列表
		page = 0;                  	--好友请求页数
		numberOnline = 0;          	--好友在线数
		numberAll = 0;             	--总好友数
		isRemain = true;           	--是否还有更多好友
		MaxPageNum = 10;           	--每页好友数
		FriendOnline = 1;          	--好友在线
		FriendOffline = 0;         	--好友不在线
		isHelpApply = false;		--判断是否为助战时申请
		helpFriend;					--当前关卡的助战好友
		assistPid;					--助战英雄pid
		numFlower = 0;				--当前拥有的鲜花数量
		useFlower = 0;				--当前兑换一体的鲜花数量
		flowerStamp = 0;			--距离下次鲜花可以送出时间倒计时
	};

--获取好友列表
function Friend:FetchFriendList(msg)
	if nil == msg then
		return;
	end
	if 1 == msg.remain then
		self.isRemain = true;
	else
		self.isRemain = false;
	end

	--鲜花数量
	-- if msg.numFlower == 0 then
	-- 	if msg.resetFlowerStamp ~= nil then
	-- 		self.flowerStamp = msg.resetFlowerStamp;
	-- 	end
	-- end
	
	self.numFlower = msg.numFlower;
	self.useFlower = msg.useFlower;
	--if 0 == self.page then
		self.numberOnline = msg.n_online;
		self.numberAll = msg.n_all;
		self.page = math.ceil(CheckDiv(#(msg.frds) / self.MaxPageNum));
		self:addFriendList(msg.frds);
		self.hasFetchFriend = true;
		--判断是否为助战时申请
		if self.isHelpApply then
			if #PveBarrierInfoPanel.friendList == Configuration.ShowAssistFriendCount then
				self.isHelpApply  = false;
				if PveBarrierInfoPanel:IsVisible() then
					PveBarrierInfoPanel:showAssistHero();
				else
					RoleMiKuInfoPanel:showAssistHero();
				end
			elseif self.isRemain then
				--如果助战好友人数不足，继续向服务器拉数据
				local msg = {};
				msg.page = Friend.page;
				Network:Send(NetworkCmdType.req_friend_list, msg, true);
			else
				--好友已经遍历结束，向服务器申请陌生人信息
				local msg = {};
				msg.count = Configuration.ShowAssistFriendCount - #PveBarrierInfoPanel.friendList;
				Network:Send(NetworkCmdType.req_helphero_stranger, msg, true);
				self.isHelpApply  = false;
			end
		else
			FriendListPanel:refreshFriendList();
			--FriendPanel:ShowFriend();
		end
	--[[
	else
		self.page = self.page + 1;
		self:addFriendList(msg.frds);

		--判断是否为助战时申请
		if self.isHelpApply then
			if #PveBarrierInfoPanel.friendList == Configuration.ShowAssistFriendCount then
				self.isHelpApply  = false;
				PveBarrierInfoPanel:showAssistHero();
			elseif self.isRemain then
				--如果助战好友人数不足，继续向服务器拉数据
				local msg = {};
				msg.page = Friend.page;
				Network:Send(NetworkCmdType.req_friend_list, msg, true);
			else
				--好友已经遍历结束，向服务器申请陌生人信息
				local msg = {};
				msg.count = Configuration.ShowAssistFriendCount - #PveBarrierInfoPanel.friendList;
				Network:Send(NetworkCmdType.req_helphero_stranger, msg, true);
				self.isHelpApply  = false;
			end
		else
			FriendPanel:refreshFriendList();
		end
	end
	--]]
end

--好友在线变化
function Friend:ChangeFriendOnline(msg)
	if not MainUI.IsInitSuccess then
		return;
	end

	if nil ~= msg then
		local friend = self.friendList[msg.uid];
		if nil ~= friend then
			if friend.online == self.FriendOffline and msg.online == self.FriendOnline then
				self.numberOnline = self.numberOnline + 1;
			elseif friend.online == self.FriendOnline and msg.online == self.FriendOffline then
				self.numberOnline = self.numberOnline - 1;
			end
			friend.online = msg.online;
		end
	end
	FriendListPanel:refreshFriendList();
	--FriendPanel:refreshFriendList();
end

--好友助战英雄变化
function Friend:ChangeFriendAssist(msg)
	if nil ~= msg then
		local friend = self.friendList[msg.uid];
		if nil ~= friend then
			friend.resid = msg.resid;
		end
	end
	FriendPanel:refreshFriendList();
end

--好友添加
function Friend:FriendAdd(msg)
	if nil ~= msg and nil ~= msg.frd and nil ~= msg.frd.uid then
		self.friendList[msg.frd.uid] = msg.frd;
		if msg.frd.online == 1 then
			self.numberOnline = self.numberOnline + 1;
		end
		self.numberAll = self.numberAll + 1;
	end
	FriendPanel:refreshFriendList();
end

--更换助战英雄
function Friend:ChangeAssist(msg)
	ActorManager.user_data.helphero = self.assistPid;
	FriendPanel:ChangeAssist(msg);
end

--保存更换的助战英雄ID
function Friend:setAssistId(pid)
	self.assistPid = pid;
end

--好友删除
function Friend:FriendDelete(msg)
	if nil ~= msg and nil ~= msg.uid then
		if nil ~= self.friendList[msg.uid] and self.FriendOnline == self.friendList[msg.uid].online then
			self.numberOnline = self.numberOnline - 1;
		end
		self.friendList[msg.uid] = nil;
		self.numberAll = self.numberAll - 1;
	end
	FriendListPanel:refreshFriendList();
end

--好友请求列表，好友请求个数更新为列表数
function Friend:FetchFriendRequestList(msg)
	if nil == msg then
		return;
	end
	ActorManager.user_data.counts.n_friend = #(msg.list);
	--表示是否有好友申请
	FriendListPanel:setHaveApplyStatus(#msg.list > 0);
	self:UpdateFetchFriendTip()
	--刷新好友申请列表的次数
	FriendApplyPanel:refresh(msg);
	--[[
	--刷机界面个数
	FriendPanel:RefreshRequestNum();
	FriendRequestPanel:onShowFriendRequest(msg);
	--]]
end

--新的好友请求，要更新好友请求个数
function Friend:NewFriendRequest(msg)
	ActorManager.user_data.counts.n_friend = ActorManager.user_data.counts.n_friend + 1;
	self:UpdateFetchFriendTip()
	FriendPanel:RefreshRequestNum();
end

--好友请求同意或拒绝
function Friend:onAcceptOrReject(msg)
	FriendApplyPanel:onAcceptOrReject(msg);
end

--增加好友列表
function Friend:addFriendList(list)
     --self.list = list;                                           --董恩来测试
	for _,friend in ipairs(list) do
		self.friendList[friend.uid] = friend;
		if self.isHelpApply and (#PveBarrierInfoPanel.friendList < Configuration.ShowAssistFriendCount) and (0 == friend.ishelped) then --助战好友个数不足,没有被邀请过
			local flag = true;
			for _,f in pairs(PveBarrierInfoPanel.friendList) do
				if f.uid == friend.uid then
					flag = false;
				end
			end
			if flag then
				friend.isFriend = true;
				table.insert(PveBarrierInfoPanel.friendList, friend);
			end
		end
	end
end

--获取排好序的好友列表
function Friend:getSortFriendList()
	local sortFriendList = {};
	if nil == self.friendList then
		return sortFriendList;
	end
	for _,friend in pairs(self.friendList) do
		table.insert(sortFriendList, friend);
	end
	table.sort(sortFriendList, CompareAscendingFriend);
	return sortFriendList;
end

--根据好友的在线和等级排序
function CompareAscendingFriend(friend1, friend2)
	if friend1.online > friend2.online then
		return true;
	else
		if friend1.online == friend2.online and friend1.lv > friend2.lv then
			return true;
		end
	end
	return false;
end

--根据pid查找助战英雄对象
function Friend:FindAssistHero(pid)
	local  actor = nil;
	if 0 == pid then
		--主角
		actor = ActorManager.user_data.role;
	else
		--伙伴
		for _,partner in pairs(ActorManager.user_data.partners) do
			if pid == partner.pid then
				return partner;
			end
		end
	end
	return actor;
end

--根据助战英雄pid查找其他可更换的英雄
function Friend:FindOtherHero(pid)
	local actorList = {}
	if 0 ~= pid then
		--主角
		 table.insert(actorList, ActorManager.user_data.role);
	end
	for _,partner in pairs(ActorManager.user_data.partners) do
		if pid ~= partner.pid then
	     table.insert(actorList, partner);
		end
	end
	return actorList;
end

--申请成为好友
function Friend:onAddFriend(uid)
	local msg = {};
	msg.uid = uid;
	msg.fp = MutipleTeam:GetDefaultTeamFp();
	Network:Send(NetworkCmdType.req_friend_add, msg, true);
end

--送花返回
function Friend:onRetSendFlower(msg)
    self.numFlower = self.numFlower - 1;
	FriendListPanel:onRetSendFlower(msg.code);
end

function Friend:onRetSendFlowerError(msg)
	MessageBox:ShowDialog(MessageBoxType.Ok, '工事中');
	--[[
	if msg.code == 608 then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_ERROR_CODE_0608);
	end
	--]]
end

function Friend:onRetReceiveFlower(msg)
	MessageBox:ShowDialog(MessageBoxType.Ok, '工事中');
	--[[
	if msg.code == 609 then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_ERROR_CODE_0609);
	end
	--]]
end

function Friend:UpdateSendFlowerTip()

	local isSend = false
	local tempFriend = self:getSortFriendList()
	for id, friend in pairs(tempFriend) do

		if friend.checkGiveState ~= 1 then
			isSend = true
			break;
		end

	end
	if self.numFlower >= 1 and isSend then
		MenuPanel.isCanSendFlower = true
	else
		MenuPanel.isCanSendFlower = false
	end

	MenuPanel:UpdateFriendTip()
end
function Friend:UpdateFetchFriendTip()

	if ActorManager.user_data.counts.n_friend == 0 then
		MenuPanel.isHaveFriend = false
	else
		MenuPanel.isHaveFriend = true
	end
	MenuPanel:UpdateFriendTip()
end
function Friend:isMyFriend(uid)
	return self.friendList[uid] ~= nil;
end
