--networkMsg_Union.lua

--======================================================================
--公会

NetworkMsg_Union = 
	{
		handlerList = {};
	};


function NetworkMsg_Union:RegisterEvent(id, obj, func)
	if nil == self.handlerList[id] then
		self.handlerList[id] = {};		
	end	
	
	table.insert(self.handlerList[id], Delegate.new(obj, func));
end

--公会创建成功
function NetworkMsg_Union:onCreateUnionSuccess(msg)
	ActorManager.user_data.ggid = msg.ggid;
	MainUI:PopAll();			--关闭创建公会界面
	local okDelegate = Delegate.new(MainUI, MainUI.onShowUnion);	
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_networkMsg_Union_1 .. UnionCreatePanel:GetUnionName() .. '】', okDelegate);
end	

--接受申请结果
function NetworkMsg_Union:onReceiveApplyRes(msg)
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_networkMsg_Union_2);
end

--公会人数已满，申请失败
function NetworkMsg_Union:ononApplyFailed(msg)
	if UnionListPanel:IsVisible() then
		UnionListPanel:onApplyReturnFull(msg);
	else
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_networkMsg_Union_3);
	end
end

--捐献成功
local dalterDonate = 0;
function NetworkMsg_Union:onUnionDonate(msg)
	--ToastMove:CreateToast(LANG_networkMsg_Union_4 .. dalterDonate .. LANG_networkMsg_Union_5);
	ToastMove:CreateToast(LANG_networkMsg_Union_4);
end

--公会个人贡献改变
function NetworkMsg_Union:onDonateChange(msg)
	dalterDonate = msg.gm - ActorManager.user_data.curDonate;			--保存贡献变化值
	ActorManager.user_data.curDonate = msg.gm;
	ActorManager.user_data.totalDonate = msg.totalgm;
	
	if nil ~= self.handlerList[NetworkCmdType.nt_gang_pay_change] then
		for _,delegete in ipairs(self.handlerList[NetworkCmdType.nt_gang_pay_change]) do
			if nil ~= delegete then
				delegete:Callback(msg);
			end
		end
	end	
end

--公会贡献改变
function NetworkMsg_Union:onUnionExpChange(msg)
	if nil ~= self.handlerList[NetworkCmdType.nt_gang_exp_change] then
		for _,delegete in ipairs(self.handlerList[NetworkCmdType.nt_gang_exp_change]) do
			if nil ~= delegete then
				delegete:Callback(msg);
			end
		end
	end	
end

--公会等级改变
function NetworkMsg_Union:onUnionLevelChange(msg)
	if nil ~= self.handlerList[NetworkCmdType.nt_gang_level_change] then
		for _,delegete in ipairs(self.handlerList[NetworkCmdType.nt_gang_level_change]) do
			if nil ~= delegete then
				delegete:Callback(msg);
			end
		end
	end	
end

--解散公会成功
function NetworkMsg_Union:onCloseUnion(msg)
	ActorManager.user_data.ggid = 0;				--公会id重置
	ActorManager.user_data.totalDonate = 0;			--公会贡献重置
	ActorManager.user_data.curDonate = 0;			--公会贡献重置
	ActorManager.hero:setUnionName(nil);
	MainUI:ReturnToMainCity();						--退出公会场景
	MainUI:PopAll();
	self:resetUnionCount();

	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_networkMsg_Union_6);
end

--收到被踢出公会的通知
function NetworkMsg_Union:onKickOutofUnion(msg)
	
	ActorManager.user_data.ggid = 0;				--公会id重置
	ActorManager.user_data.totalDonate = 0;			--公会贡献重置
	ActorManager.user_data.curDonate = 0;			--公会贡献重置
	ActorManager.hero:setUnionName(nil);
	self:resetUnionCount();
	if MainUI:GetSceneType() == SceneType.Union then
		MainUI:ReturnToMainCity();						--退出公会场景
		MainUI:PopAll();
	end
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_networkMsg_Union_7);
end

--同意角色加入公会
function NetworkMsg_Union:onAcceptNewPlayer(msg)
	if 1 == msg.flag then
		UnionPanel:SetCurMemberCount(UnionPanel:GetCurMemberCount() + 1);
		if nil ~= self.handlerList[NetworkCmdType.ret_deal_gang_req] then
			for _,delegete in ipairs(self.handlerList[NetworkCmdType.ret_deal_gang_req]) do
				if nil ~= delegete then
					delegete:Callback(msg);
				end
			end
		end	
	end	
end

--显示公会列表
function NetworkMsg_Union:onShowUnionList( msg )
	if RankPanel:IsRankUIShow() then
		RankPanel:GotUnionRankMsg(msg);
	else
		UnionListPanel:onShowUnionListPanel(msg);
	end
	 
end

--通知加入公会
function NetworkMsg_Union:onNoticeJoinInUnion(msg)
	ActorManager.user_data.ggid = msg.ggid;			--公会id重置
	ActorManager.user_data.totalDonate = 0;			--公会贡献重置
	ActorManager.user_data.curDonate = 0;			--公会贡献重置

	--请求boss是否存活
	WOUBossPanel:RequestBossAlive(2);
end	

--返回职位调整结果
function NetworkMsg_Union:onOptPositionResult(msg)
	UnionAdjustPosition:onClose();				--关闭职位调整界面

	local okDelegate = Delegate.new(UnionPanel, UnionPanel.onMemberList);
	if msg.isadm then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_networkMsg_Union_8, okDelegate);
	else
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_networkMsg_Union_9, okDelegate);
	end	
end

--返回转让会长结果
function NetworkMsg_Union:onChangeMaster(msg)
	ActorManager.user_data.unionPos = 0;
	UnionAdjustPosition:onClose();				--关闭职位调整界面
	UnionPanel:refreshMaster(UnionAdjustPosition:GetNewMasterName());		--刷新公会主界面会长名称
	UnionApplyPanel:SetApplyCount(0);		--设置申请人数为0
	UnionPanel:RefreshApplyCountLabel(0);
	local okDelegate = Delegate.new(UnionPanel, UnionPanel.onMemberList);
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_networkMsg_Union_10, okDelegate);
end

--处理踢出公会结果
function NetworkMsg_Union:onKickResult()
	UnionMemberPanel:Reset();
	UnionPanel:SetCurMemberCount(UnionPanel:GetCurMemberCount() - 1);
	UnionMemberPanel:setScrollListTop();
	
	local msg = {};
	msg.page = 1;
	Network:Send(NetworkCmdType.req_gang_mem, msg);
	
	if nil ~= self.handlerList[NetworkCmdType.ret_kick_mem] then
		for _,delegete in ipairs(self.handlerList[NetworkCmdType.ret_kick_mem]) do
			if nil ~= delegete then
				delegete:Callback(msg);
			end
		end
	end	
end

--退出公会结果
function NetworkMsg_Union:onLeaveUnion(msg)
	MainUI:Pop();
	
	ActorManager.user_data.ggid = 0;				--公会id重置
	ActorManager.user_data.totalDonate = 0;			--公会贡献重置
	ActorManager.user_data.curDonate = 0;			--公会贡献重置
	ActorManager.hero:setUnionName(nil);
	self:resetUnionCount();
	
	MainUI:ReturnToMainCity();						--返回主城
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_networkMsg_Union_11 .. UnionPanel:GetUnionName() .. '】!');
end

--获取公会信息
function NetworkMsg_Union:GetUnionInfo( msg )
	--设置公会属性
	UnionPanel:SetUnionProperty(msg);
	if GlobalData.NeedShowUnion then
		--公会里显示公会信息
		if MainUI:GetSceneType() == SceneType.Union then
			UnionPanel:onShowUnionPanel();
			return;
		end
		
		--请求进入公会
		local newmsg = {};
		newmsg.resid = GlobalData.UnionSceneId;
		newmsg.show_player_num = GlobalData.MaxSceneRoleNum;	
		Network:Send(NetworkCmdType.req_enter_city, newmsg);
	else
		GlobalData.NeedShowUnion = true;
	end
end

--公会祭祀
function NetworkMsg_Union:onAlter( msg )
	UnionAlterPanel:onShowAlterPanel(msg);
end

--收到服务器发送的公会boss时间改变消息
function NetworkMsg_Union:onUnionBossTimeChange( msg )
	ActorManager.user_data.unionBossDay = msg.day;
end

--重置角色公会的剩余祭祀次数和公会申请个数
function NetworkMsg_Union:resetUnionCount()
	UnionAlterPanel:SetLeftTime(0);
	UnionPanel:RefreshAlterCountLabel(0);
	UnionApplyPanel:SetApplyCount(0);
	UnionPanel:RefreshApplyCountLabel(0);
end

--公会红包返回
function NetworkMsg_Union:onHongBao( msg )

	local removed = false;
	if msg.uid == ActorManager.user_data.uid then
		--自己收到红包领取消息，弹框、并发送一条公会公告
		removed = true;
		
		local sendmsg = {};
		sendmsg.type = UnionInputType.hongbao;
		sendmsg.msg = LANG__32 .. msg.yb .. LANG__33;
		Network:Send(NetworkCmdType.nt_gang_msg, sendmsg, true);
		
		local contents = {};
		table.insert(contents, {cType = MessageContentType.Text; text = LANG__34, color = Configuration.WhiteColor});
		table.insert(contents, {cType = MessageContentType.Text; text = msg.nickname, QualityColor[Configuration:getRare(msg.level)]});
		table.insert(contents, {cType = MessageContentType.Text; text = LANG__35, color = Configuration.WhiteColor});
		table.insert(contents, {cType = MessageContentType.Text; text = msg.yb .. LANG__36, color = Configuration.BlueColor});
		table.insert(contents, {cType = MessageContentType.Text; text = LANG__37, color = Configuration.WhiteColor});
		
		MessageBox:ShowDialog(MessageBoxType.Ok, contents);
	end
	
	if msg.count <= 0 then
		--红包已经被领完了
		removed = true;
	end
	
	if removed then
		--删除显示
		if MainUI:GetSceneType() == SceneType.Union then
			--删除
			GodsSenki.mainScene:RemoveUnionRedEnvelopes(msg.id);
		end
		
		--删除数据
		ActorManager.user_data.hongbao[msg.id] = nil;
	end

end

--通知发红包消息
function NetworkMsg_Union:onNT_HongBao( msg )
	
	--公会红包用id做key
	if ActorManager.user_data.hongbao == nil then
		ActorManager.user_data.hongbao = {};
	end

	for _,v in ipairs(msg.hongbao) do
		ActorManager.user_data.hongbao[v.id] = v;
	end
	
	if MainUI:GetSceneType() == SceneType.Union then
		--在公会里，就增加红包
		for _,v in ipairs(msg.hongbao) do
			GodsSenki.mainScene:AddUnionRedEnvelopes(v);
			
			if ActorManager.user_data.uid == v.uid then
				--自己发的红包，则发送一条公会留言
				local sendmsg = {};
				sendmsg.type = UnionInputType.hongbao;
				sendmsg.msg = LANG__38;
				Network:Send(NetworkCmdType.nt_gang_msg, sendmsg, true);
			end
		end
	end

end
