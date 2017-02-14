--unionListPanel.lua
--============================================================================================
--公会信息
UnionListPanel =
	{
	};
	
--变量
local isAll;			--是否全部请求完毕
local isShow;			--是否显示
local isSearch;			--是否搜索结果
local isSearchToAll;	--是否从搜索到普通显示
local curPage;			--当前页数
local curUnionCount;	--当前显示的公会个数
local scrollFlag;
local unionList = {};
local unionSearchList = {};

--控件
local mainDesktop;
local panel;
local memberList;
local vScrollBar;
local tbInput;

--初始化
function UnionListPanel:InitPanel(desktop)
	--变量初始化
	isAll = false;				--是否全部请求完毕
	isShow = false;				--是否显示
	isSearch = false;			--是否搜索结果
	isSearchToAll = false;		--是否从搜索到普通显示
	curPage = 0;				--当前页数
	curUnionCount = 0;			--当前显示的公会个数
	scrollFlag = true;
	unionList = {};
	unionSearchList = {};

	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('unionListPanel'));
	panel:IncRefCount();
	
	memberList = panel:GetLogicChild('memberListClip'):GetLogicChild(0);
	tbInput = panel:GetLogicChild('input');	
	vScrollBar = panel:GetLogicChild('memberListClip'):GetInnerVScrollBar();
	vScrollBar:SubscribeScriptedEvent('ScrollBar::ScrolledEvent', 'UnionListPanel:onScrolled');
	panel:GetLogicChild('memberListClip'):SubscribeScriptedEvent('UIControl::MouseUpEvent', 'UnionListPanel:onMouseUp');
	
	memberList:RemoveAllChildren();						--删除所有子控件
	curPage = 0;
	curUnionCount = 0;
	scrollFlag = true;
	isShow = false;
	isAll = false;
	panel.Visibility = Visibility.Hidden;
end

--销毁
function UnionListPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function UnionListPanel:Show()
	isShow = true;
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function UnionListPanel:Hide()
	isShow = false;
	isAll = false;
	scrollFlag = true;
	isSearch = false;
	isSearchToAll = false;
	curUnionCount = 0;
	curPage = 0;
	unionList = {};
	unionSearchList = {};
	memberList:RemoveAllChildren();
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--==============================================================================================
--功能函数

--计算公会总人数
function UnionListPanel:GetTotalNumber(level)
	return resTableManager:GetValue(ResTable.unionLevel, tostring(level), 'member');
end

--加载公会列表
function UnionListPanel:loadUnionList(gangList)
	local list = {};
	if isSearch then
		list = unionSearchList;
	else
		list = unionList;
	end	
	
	table.sort(gangList, function (i1, i2) return i1.grank < i2.grank end);						--按公会等级排名

	for _,info in ipairs(gangList) do	
		if not isSearchToAll then
			table.insert(list, info);				--插入到公会总表
		end	
		
		curUnionCount = curUnionCount + 1;			--记录个数
		local unionItemControl = uiSystem:CreateControl('unionInfoTemplate1'):GetLogicChild('unionInfoTemplate1');
		local labelRank = unionItemControl:GetLogicChild('ranking');
		local labelName = unionItemControl:GetLogicChild('name');
		local labelMaster = unionItemControl:GetLogicChild('master');
		local labelLevel = unionItemControl:GetLogicChild('level');
		local labelMembers = unionItemControl:GetLogicChild('members');
		local btnApply = unionItemControl:GetLogicChild('apply');
		local rank1 = unionItemControl:GetLogicChild('rewrd1')
		local rank2 = unionItemControl:GetLogicChild('rewrd2')
		local rank3 = unionItemControl:GetLogicChild('rewrd3')
		local bg = unionItemControl:GetLogicChild('bg')
		if ActorManager.user_data.ggid > 0 then
			--已经加入公会
			btnApply.Enable = false;
		elseif 1 == info.reqed then
			--已申请
			btnApply.Text = LANG_unionListPanel_1;
			btnApply.Enable = false;
		else
			btnApply:SubscribeScriptedEvent('Button::ClickEvent', 'UnionListPanel:onApplyJoin');
		end
		
		labelRank.Text = tostring(info.grank);
		bg.Background = Converter.String2Brush("godsSenki.rank_dibian4");
		if curUnionCount == 1 then
			bg.Background = Converter.String2Brush("godsSenki.rank_dibian1");
			rank1:GetLogicChild('Ranking').Text = tostring(info.grank)
			rank1.Visibility = Visibility.Visible;
			rank2.Visibility = Visibility.Hidden;
			rank3.Visibility = Visibility.Hidden;
			labelRank.Visibility = Visibility.Hidden;
		elseif curUnionCount == 2 then
			bg.Background = Converter.String2Brush("godsSenki.rank_dibian2");
			rank2:GetLogicChild('Ranking').Text = tostring(info.grank)
			rank1.Visibility = Visibility.Hidden;
			rank2.Visibility = Visibility.Visible;
			rank3.Visibility = Visibility.Hidden;
			labelRank.Visibility = Visibility.Hidden;
		elseif curUnionCount == 3 then
			bg.Background = Converter.String2Brush("godsSenki.rank_dibian3");
			rank3:GetLogicChild('Ranking').Text = tostring(info.grank)
			rank1.Visibility = Visibility.Hidden;
			rank2.Visibility = Visibility.Hidden;
			rank3.Visibility = Visibility.Visible;
			labelRank.Visibility = Visibility.Hidden;
		end
		
		labelName.Text = info.name;		
		--labelMaster.TextColor = QualityColor[Configuration:getNameColorByEquip(info.quality)];
		labelMaster.Text = info.cname;
		labelLevel.Text = tostring(info.level);
		labelMembers.Text = info.total .. '/' .. self:GetTotalNumber(info.level);
		btnApply.Tag = curUnionCount;
		memberList:AddChild(unionItemControl);
	end
	
	isSearchToAll = false;						--表示下次加载已经不是从搜索转过来的了
end

--是否显示
function UnionListPanel:IsVisible()
	return panel.Visibility == Visibility.Visible;
end

--==============================================================================================
--事件
--关闭
function UnionListPanel:onClose()
	MainUI:Pop();
end

--显示公会列表
function UnionListPanel:onShowUnionListPanel(msg)
	isSearch = false;
	isSearchToAll = false;
	curPage = curPage + 1;					--当前页数为1
	if #(msg.gangs) < 10 then				--当前服务器总公会数小于10
		isAll = true;
	else
		isAll = false;
	end
	
	self:loadUnionList(msg.gangs);

	if not isShow then
		MainUI:Push(self);
	end		
end

--显示创建公会界面
function UnionListPanel:onCreateUnion()
	if 0 == ActorManager.user_data.ggid then
		if ActorManager.user_data.rmb < Configuration.CreateDiamond then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionListPanel_2 .. Configuration.CreateDiamond .. LANG_unionListPanel_3);
		elseif Configuration.CreateUnionLevel > ActorManager.user_data.role.lvl.level then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionListPanel_4 .. Configuration.CreateUnionLevel .. LANG_unionListPanel_5);
		else
			MainUI:Push(UnionCreatePanel);
		end	
	else			--现在已经加入公会，无法创建
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionListPanel_6);
	end	
end

--滑动事件
function UnionListPanel:onScrolled(Args)
	if (not isSearch) and (not isAll) and (vScrollBar.Value > vScrollBar.Maximum * 0.90) and scrollFlag then
		--向服务器申请跟多列表数据
		local msg = {};
		msg.page = curPage + 1;
		Network:Send(NetworkCmdType.req_gang_list, msg, true);
		scrollFlag = false;
	end
end

--鼠标抬起事件
function UnionListPanel:onMouseUp()
	scrollFlag = true;
end

--搜索事件
function UnionListPanel:onSearch()
	if 0 == string.len(tbInput.Text) then
		curUnionCount = 0;
		unionSearchList = {};
		memberList:RemoveAllChildren();
		
		isSearchToAll = true;
		self:loadUnionList(unionList);
	else
		local msg = {};
		msg.name = tbInput.Text;
		Network:Send(NetworkCmdType.req_search_gang, msg);
	end
	
	memberList:GetLogicParent():VScrollBegin();
end

--显示搜索结果
function UnionListPanel:onShowSearchResult(msg)
	curUnionCount = 0;	
	unionSearchList = {};
	memberList:RemoveAllChildren();
	
	isSearch = true;
	self:loadUnionList(msg.gangs);
end

--申请加入公会
function UnionListPanel:onApplyJoin(Args)
	local args = UIControlEventArgs(Args);
	local index = args.m_pControl.Tag;
	local msg = {};
	if isSearch then			--搜索列表
		msg.ggid = unionSearchList[index].ggid;
	else						--非搜索列表
		msg.ggid = unionList[index].ggid;
	end	
	Network:Send(NetworkCmdType.req_add_gang, msg, true);
	
	args.m_pControl.Enable = false;
	args.m_pControl.Text = LANG_unionListPanel_7;
end

--公会人数已满，申请失败
function UnionListPanel:onApplyReturnFull(msg)
	local list = {};	
	local uIndex = 0;
	if isSearch then			--搜索列表
		list = unionSearchList;
	else						--非搜索列表
		list = unionList;
	end	

	for index, union in ipairs(list) do
		if msg.ggid == union.ggid then
			uIndex = index;
			break;
		end
	end
	
	local control = memberList:GetLogicChild(uIndex - 1);
	local labelMembers = control:GetLogicChild('members');
	local labelName = control:GetLogicChild('name');
	local labelLevel = control:GetLogicChild('level');
	local level = tonumber(labelLevel.Text);
	labelMembers.Text = self:GetTotalNumber(level) .. '/' .. self:GetTotalNumber(level);
	
	MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionListPanel_8 .. labelName.Text .. LANG_unionListPanel_9);
end