--unionPanel.lua
--==============================================================================================
--公会主界面

UnionPanel =
	{
	};

--变量
local curMemberCount;
local maxMemberCount;
local msg;
local maxUnionExp;
local curUnionExp;

--控件
local panel;
local mainDesktop;
local labelUnionName;
local labelNotice;
local rtbMessageBoards;
local labelLevel;
local labelmaster;
local labelRank;
local labelDonate;
local labelUnionDonate;
local labelMember;
local btnModify;
local unionCountLabel;
local applyCountLabel;
local alterCountLabel;
local btnother;

local btnQuit;

local btnOtherMargin = Rect(297, 466, 0, 0);

--初始化
function UnionPanel:InitPanel(desktop)
	--变量初始化
	curMemberCount = 0;
	maxMemberCount = 0;
	msg = '';
	curUnionExp = 0;
	maxUnionExp = 0;

	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('unionPanel'));
	panel:IncRefCount();
	
	labelUnionName = panel:GetLogicChild('unionInfo'):GetLogicChild('unionName');
	labelNotice = panel:GetLogicChild('noticePanel'):GetLogicChild('notice');
	rtbMessageBoards = panel:GetLogicChild('messagePanel'):GetLogicChild('messageboard');
	labelLevel = panel:GetLogicChild('unionInfo'):GetLogicChild('level');
	labelmaster = panel:GetLogicChild('unionInfo'):GetLogicChild('master');
	labelRank = panel:GetLogicChild('unionInfo'):GetLogicChild('rank');
	labelDonate = panel:GetLogicChild('unionInfo'):GetLogicChild('donate');
	labelMember = panel:GetLogicChild('unionInfo'):GetLogicChild('member');
	btnModify = panel:GetLogicChild('modify');
	btnModify.Text = LANG_unionPanel_16
	labelUnionDonate = panel:GetLogicChild('unionInfo'):GetLogicChild('unionDonate');
	unionCountLabel = desktop:GetLogicChild('unionSceneUI'):GetLogicChild('unionInfoButton'):GetLogicChild('leftCountLabel');
	applyCountLabel = panel:GetLogicChild('btnMember'):GetLogicChild('leftCountLabel');
	alterCountLabel = panel:GetLogicChild('altar'):GetLogicChild('leftCountLabel');
	btnQuit = panel:GetLogicChild('quit');
	btnother = panel:GetLogicChild('other');
	
	labelNotice.Text = '';
	panel.Visibility = Visibility.Hidden;
	
	--注册事件
	NetworkMsg_Union:RegisterEvent(NetworkCmdType.nt_gang_exp_change, UnionPanel, UnionPanel.refreshExp);
	NetworkMsg_Union:RegisterEvent(NetworkCmdType.nt_gang_level_change, UnionPanel, UnionPanel.refreshLevel);
	NetworkMsg_Union:RegisterEvent(NetworkCmdType.ret_deal_gang_req, UnionPanel, UnionPanel.refreshMemberCount);
	NetworkMsg_Union:RegisterEvent(NetworkCmdType.ret_kick_mem, UnionPanel, UnionPanel.refreshMemberCount);
	NetworkMsg_Union:RegisterEvent(NetworkCmdType.ret_kick_mem, UnionPanel, UnionPanel.refreshButton);
	NetworkMsg_Union:RegisterEvent(NetworkCmdType.ret_change_charman, UnionPanel, UnionPanel.refreshButton);
	NetworkMsg_Union:RegisterEvent(NetworkCmdType.ret_deal_gang_req, UnionPanel, UnionPanel.refreshButton);
	NetworkMsg_Union:RegisterEvent(NetworkCmdType.nt_gang_pay_change, UnionPanel, UnionPanel.refreshDonate);
end

--销毁
function UnionPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function UnionPanel:Show()
	--记录老战斗力
	ActorManager.oldFP = ActorManager.user_data.fp;
	
	StoryBoard:OnPopPlayingUI();
	
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
	--请求社团战状态
end

--隐藏
function UnionPanel:Hide()
	rtbMessageBoards:Clear();
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');

	--战斗力改变
	ActorManager:UpdateFightAbility();
	--GemPanel:totleFp();
	FightPoint:ShowFP(ActorManager.user_data.fp - ActorManager.oldFP);
	ActorManager.oldFP = ActorManager.user_data.fp;
end

--==============================================================================================
--功能函数

--设置公告
function UnionPanel:SetNotice(msg)
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionPanel_1);
	labelNotice.Text = UnionInputPanel:GetNotice() ;
end

--刷新公会经验
function UnionPanel:refreshExp(msg)
	local level = tonumber(labelLevel.Text);
	local preExp = resTableManager:GetValue(ResTable.unionLevel, tostring(level), 'exp');
	curUnionExp = msg.exp;
	labelUnionDonate.Text = curUnionExp .. '/' .. maxUnionExp;
end

--刷新个人贡献
function UnionPanel:refreshDonate(msg)
	labelDonate.Text = ActorManager.user_data.curDonate .. '/' .. ActorManager.user_data.totalDonate;
end

--刷新公会等级
function UnionPanel:refreshLevel(msg)
	--计算增加的祭祀次数
	local incAlterCount = UnionAlterPanel:getMaxAlterCount(msg.level) - UnionAlterPanel:getMaxAlterCount(ActorManager.user_data.unionLevel);
	self:RefreshAlterCountLabel(UnionAlterPanel:GetLeftTime() + incAlterCount);
	
	ActorManager.user_data.unionLevel = msg.level;
	labelLevel.Text = tostring(msg.level);
	local preExp = resTableManager:GetValue(ResTable.unionLevel, tostring(msg.level), 'exp');
	local nextExp = resTableManager:GetValue(ResTable.unionLevel, tostring(msg.level + 1), 'exp');
	if nil == nextExp then
		maxUnionExp = preExp;
	else
		maxUnionExp = nextExp;
	end	
	labelUnionDonate.Text = curUnionExp .. '/' .. maxUnionExp;
	
	UnionSkillPanel:refreshDonate();				--刷新技能
	--UnionSkillPanel:refreshSkillState();			--刷新技能状态（开启/未开启）
	
	UnionAlterPanel:refreshLevelUp(incAlterCount)				--刷新祭祀次数
	
	--刷新公会人数
	maxMemberCount = UnionListPanel:GetTotalNumber(ActorManager.user_data.unionLevel);
	self:refreshMemberCount();
end

--刷新会长
function UnionPanel:refreshMaster(master)
	labelmaster.Text = master;
	--修改公告按钮
	if 2 ~= ActorManager.user_data.unionPos then
		btnModify.Visibility = Visibility.Hidden;
		btnQuit.Visibility = Visibility.Visible;
	else
		btnModify.Visibility = Visibility.Visible;
		btnQuit.Visibility = Visibility.Hidden;
		btnother.Margin = btnOtherMargin;
	end
end

--刷新退出公会按钮显示名称
function UnionPanel:refreshButton()
	--退出公会按钮显示
	if (1 == curMemberCount) and (2 == ActorManager.user_data.unionPos) then
		btnQuit.Text = LANG_unionPanel_2;
		btnQuit.Tag = 2;
	else
		btnQuit.Text = LANG_unionPanel_3;
		btnQuit.Tag = 1;
	end	
end

--获取公会名
function UnionPanel:GetUnionName()
	return msg.pro.name;
end

--获取公会当前等级的最大成员数
function UnionPanel:GetMaxMemberCount()
	return maxMemberCount;
end

--获取公会的当前成员数
function UnionPanel:GetCurMemberCount()
	return curMemberCount;
end

--设置公会当前等级的最大成员数
function UnionPanel:SetMaxMemberCount(count)
	maxMemberCount = count;
end

--设置公会的当前成员数
function UnionPanel:SetCurMemberCount(count)
	curMemberCount = count;
end

--刷新公会人数
function UnionPanel:refreshMemberCount()
	labelMember.Text = curMemberCount .. '/' ..  maxMemberCount;
end

--设置公会属性
function UnionPanel:SetUnionProperty(message)
	msg = message;
	ActorManager.user_data.unionPos = message.mem.flag;				--0:普通会员，1:官员,2:会长
	ActorManager.user_data.dailyDonate = message.dpm;				--今天的贡献值
	ActorManager.user_data.curDonate = message.mem.gm;				--当前的贡献值
	ActorManager.user_data.totalDonate = message.mem.totalgm;		--总共的贡献值
	ActorManager.user_data.unionLevel = message.pro.level;			--公会等级
	ActorManager.user_data.unionBossDay = message.bossday;			--公会boss开启日期
	
	--公会红包用id做key
	ActorManager.user_data.hongbao = {};
	for _,v in ipairs(message.hongbao) do
		ActorManager.user_data.hongbao[v.id] = v;
	end

	ActorManager.hero:setUnionName(self:GetUnionName());
end

function UnionPanel:getTime( t )
	if t <= 5 then
		return LANG_unionPanel_4;
	elseif t < 60 then
		--1分钟内
		return t .. LANG_unionPanel_5;
	elseif t < 3600 then
		--1小时内
		return math.floor(t / 60) .. LANG_unionPanel_6;
	elseif t < 86400 then
		--1天内
		return math.floor(t / 3600) .. LANG_unionPanel_7;
	else
		return math.floor(t / 86400) .. LANG_unionPanel_8;
	end
	
end
--==============================================================================================
--事件
--向服务器发送请求显示公会界面的消息
function UnionPanel:onRequestShowUnionPanel()
	local msg = {};
	msg.ggid = ActorManager.user_data.ggid;
	Network:Send(NetworkCmdType.req_gang_info, msg);
end

--关闭
function UnionPanel:onClose()
	MainUI:PopAll();
end	

--显示公会信息界面
function UnionPanel:onShowUnionPanel()
	local font = uiSystem:FindFont('huakang_20');
	labelNotice.Text = msg.notice;							--设置公告
	rtbMessageBoards:Clear();
	for _,message in ipairs(msg.msgs) do					--加载留言
		message = cjson.decode(message);
		rtbMessageBoards:AddText(self:getTime(message.offtime) .. ' ', Configuration.WhiteColor, font);
		
		if message.type == UnionInputType.input then
			--留言
			rtbMessageBoards:AppendText(message.nickname .. '：', QualityColor[Configuration:getNameColorByEquip(message.quality)], font);
			rtbMessageBoards:AppendText(message.msg, Configuration.WhiteColor, font);
		elseif message.type == UnionInputType.hongbao then
			--红包
			rtbMessageBoards:AppendText(message.nickname .. ' ', QualityColor[Configuration:getNameColorByEquip(message.quality)], font);
			rtbMessageBoards:AppendText(message.msg, QualityColor[6], font);
		else
			rtbMessageBoards:AppendText(LANG__64, Configuration.WhiteColor, font);
		end
	end
	labelUnionName.Text = msg.pro.name;
	labelLevel.Text = tostring(msg.pro.level);
	labelmaster.Text = msg.pro.cname;
	labelmaster.TextColor = QualityColor[Configuration:getNameColorByEquip(msg.pro.quality)];
	if 2 ~= ActorManager.user_data.unionPos then
		btnModify.Visibility = Visibility.Hidden;
		btnQuit.Visibility = Visibility.Visible;
	else
		btnModify.Visibility = Visibility.Visible;
		btnQuit.Visibility = Visibility.Hidden;
		btnother.Margin = btnOtherMargin;
	end
	labelRank.Text = tostring(msg.pro.grank);
	labelDonate.Text = ActorManager.user_data.curDonate .. '/' .. ActorManager.user_data.totalDonate;
	curMemberCount = msg.pro.total;
	maxMemberCount = UnionListPanel:GetTotalNumber(msg.pro.level);
	labelMember.Text = curMemberCount .. '/' .. maxMemberCount;

	local preExp = resTableManager:GetValue(ResTable.unionLevel, tostring(msg.pro.level), 'exp');
	local nextExp = resTableManager:GetValue(ResTable.unionLevel, tostring(msg.pro.level + 1), 'exp');
	if nil == nextExp then
		maxUnionExp = preExp;
	else
		maxUnionExp = nextExp;
	end
	curUnionExp = msg.pro.exp;
	labelUnionDonate.Text = curUnionExp .. '/' .. maxUnionExp;
	
	--退出公会按钮显示
	if (1 == msg.pro.total) and (2 == msg.mem.flag) then
		btnQuit.Text = LANG_unionPanel_9;
		btnQuit.Tag = 2;
	else
		btnQuit.Text = LANG_unionPanel_10;
		btnQuit.Tag = 1;
	end
	
	--修改公告按钮
	if 0 == msg.mem.flag then
		btnModify.Visibility = Visibility.Hidden;
	else
		btnModify.Visibility = Visibility.Visible;
	end
	MainUI:Push(self);
end

--修改公告（会长和官员可以修改）
function UnionPanel:onModifyNotice()
	if ActorManager.user_data.unionPos > 0 then
		UnionInputPanel:onShowInputPanel(1, labelNotice.Text);
	else
		MessageBox(MessageBoxType.Ok, LANG_unionPanel_11);
	end	
end

--发布留言
function UnionPanel:onSendMessage()
	UnionInputPanel:onShowInputPanel(2);
end

--接收留言
function UnionPanel:onReceiveMessage(msg)
	if not MainUI.IsInitSuccess then
		return;
	end
	local font = uiSystem:FindFont('huakang_20');
	rtbMessageBoards:AddText(self:getTime(msg.offtime) .. ' ', Configuration.WhiteColor, font);
	
	if msg.type == UnionInputType.input then
		--留言
		rtbMessageBoards:AppendText(msg.nickname .. '：', QualityColor[Configuration:getNameColorByEquip(msg.quality)], font);
		rtbMessageBoards:AppendText(msg.msg, Configuration.WhiteColor, font);
	elseif msg.type == UnionInputType.hongbao then
		--红包
		rtbMessageBoards:AppendText(msg.nickname .. ' ', QualityColor[Configuration:getNameColorByEquip(msg.quality)], font);
		rtbMessageBoards:AppendText(msg.msg, QualityColor[6], font);
	else
		rtbMessageBoards:AppendText(LANG__65, Configuration.WhiteColor, font);
	end
	
end

--查看其他公会
function UnionPanel:onLookoverOtherUnion()
	--请求公会列表第一页
	local msg = {};
	msg.page = 1;
	Network:Send(NetworkCmdType.req_gang_list, msg);
end

--退出/解散公会按钮点击事件
function UnionPanel:onQuitOrDissolve(Args)
	local args = UIControlEventArgs(Args);
	local msg = {};
	
	local str;
	local okDelegate;
	
	if 1 == args.m_pControl.Tag then				--退出公会
		okDelegate = Delegate.new(UnionPanel, UnionPanel.onQuitUnion, 0);
		if 2 == ActorManager.user_data.unionPos then
			str = LANG_unionPanel_12;
			MessageBox:ShowDialog(MessageBoxType.Ok, str);
		else
			str = LANG_unionPanel_13;
			MessageBox:ShowDialog(MessageBoxType.OkCancel, str, okDelegate);
		end	
	elseif 2 == args.m_pControl.Tag then			--解散公会
		okDelegate = Delegate.new(UnionPanel, UnionPanel.onDissolveUnion, 0);
		str = LANG_unionPanel_14;
		MessageBox:ShowDialog(MessageBoxType.OkCancel, str, okDelegate);
	end

	
end

--解散工会
function UnionPanel:onDissolveUnion()
	Network:Send(NetworkCmdType.req_close_gang, {});
end	

--退出公会
function UnionPanel:onQuitUnion()
	Network:Send(NetworkCmdType.req_leave_gang, {});
end	

--公会技能按钮点击事件
function UnionPanel:onUnionSkillClick()
	Network:Send(NetworkCmdType.req_gskl_list, {});
end

--公会成员点击事件
function UnionPanel:onMemberList()
	UnionMemberPanel:Reset();
	
	local msg = {};
	msg.page = 1;
	Network:Send(NetworkCmdType.req_gang_mem, msg);
end

--公会祭祀按钮点击事件
function UnionPanel:onShowAlter()
	if ActorManager.user_data.unionLevel < 2 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionPanel_15);
	else
		Network:Send(NetworkCmdType.req_enter_pray, {});
	end	
end

--刷新公会tips
function UnionPanel:RefreshUnionCountLabel(count)
	unionCountLabel.Text = tostring(count);
	if count <= 0 then
		unionCountLabel.Visibility = Visibility.Hidden;
	else
		unionCountLabel.Visibility = Visibility.Visible;
	end
end

--刷新祭祀次数tips
function UnionPanel:RefreshAlterCountLabel(count)
	alterCountLabel.Text = tostring(count);
	if count <= 0 then
		alterCountLabel.Visibility = Visibility.Hidden;
	else
		alterCountLabel.Visibility = Visibility.Visible;
	end
end

--刷新申请公会人数tips
function UnionPanel:RefreshApplyCountLabel(count)
	applyCountLabel.Text = tostring(count);
	if count <= 0 then
		applyCountLabel.Visibility = Visibility.Hidden;
	else
		applyCountLabel.Visibility = Visibility.Visible;
	end
end
