--armoryPanel.lua
--=====================================================================================
--英雄榜
ArmoryPanel = 
	{
	};
	
--变量	
local pageData = {};
local PopupMenuYPos = {75, 110, 145, 180, 215, 250, 285, 155, 190, 225};
local PopupMenuXPos = 242;
local selectPageIndex = 0;
local selectRowIndex = 0;

--控件
local mainDesktop;
local panel;
local listView;
local armoryPageList;
local pageFlagList;
local infoPopupMenu;			--弹出菜单
local stackPanel;

--初始化
function ArmoryPanel:InitPanel(desktop)
	--变量初始化
	pageData = {};
	PopupMenuYPos = {75, 110, 145, 180, 215, 250, 285, 155, 190, 225};
	PopupMenuXPos = 242;
	selectPageIndex = 0;
	selectRowIndex = 0;
	armoryPageList = {};
	pageFlagList = {};

	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('armoryPanel'));
	panel:IncRefCount();
	listView = ListView(panel:GetLogicChild('listView'));
	stackPanel = panel:GetLogicChild('pageFlag');
	infoPopupMenu = Panel(panel:GetLogicChild('infoPopupMenu'));
	infoPopupMenu:SubscribeScriptedEvent('UIControl::LostFocusEvent', 'ArmoryPanel:onInfoPopupMenuLoseFocus');
	
	listView.ShowPageBrush = false;
	infoPopupMenu.Visibility = Visibility.Hidden;
	panel.Visibility = Visibility.Hidden;
end

--销毁
function ArmoryPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function ArmoryPanel:Show()
	selectPageIndex = 1;
	self:addPage();	
	for i = 1, #pageData do
		self:refresh(i);
	end
	
	self:refreshPageFlag(1);
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function ArmoryPanel:Hide()
	self:removeAllPage();
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--=========================================================================================
--功能函数
--添加英雄榜页
function ArmoryPanel:addPage()
	local pageCount = #pageData;
	for index = 1, pageCount do
		local temp = uiSystem:CreateControl('armoryPageTemplate');
		listView:AddChild(temp);
		
		local pageList = {};
		for index = 1, 5 do
			local list = {};			--一页英雄榜中的十条信息
			local row = temp:GetLogicChild('armoryPagePanel'):GetLogicChild(tostring(index));
			list.row = row;
			list.labelName = Label(row:GetLogicChild('name'));
			list.labelRanking = Label(row:GetLogicChild('ranking'));
			list.brushRanking = BrushElement(row:GetLogicChild('rankingPic'));
			list.labelLevel = Label(row:GetLogicChild('level'));
			list.labelFP = Label(row:GetLogicChild('fightPoint'));
			list.brushReward = BrushElement(row:GetLogicChild('reward'));
			list.labelName.Tag = index;
			list.labelName:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ArmoryPanel:onPlayerClick');
			list.brushReward:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'ArmoryPanel:onShowRewardTips');
			table.insert(pageList, list);
		end
		
		table.insert(armoryPageList, pageList);
	end

	--页面的下的翻页标志
	local flag = 0;
	if pageCount >= 5 then
		flag = 5;
	else
		flag = pageCount;
	end	
	for index = 1, flag do
		local child = UserControl(uiSystem:CreateControl('fenyeTemplate'));
		stackPanel:GetLogicChild(0):AddChild(child);
		table.insert(pageFlagList, child:GetLogicChild(0):GetLogicChild(0));
	end
end

--删除页面
function ArmoryPanel:removeAllPage()
	listView:RemoveAllChildren();
	stackPanel:GetLogicChild(0):RemoveAllChildren();
	armoryPageList = {};
	pageFlagList = {};
end

--刷新
function ArmoryPanel:refresh(pIndex)
	local count = #pageData[pIndex];			--该页有多少条数据
	for index = 1, 5 do
		if index <= count then
			armoryPageList[pIndex][index].row.Visibility = Visibility.Visible;
			armoryPageList[pIndex][index].labelName.Text = pageData[pIndex][index].name;
			armoryPageList[pIndex][index].labelName.TextColor = QualityColor[Configuration:getRare(pageData[pIndex][index].level)];
			armoryPageList[pIndex][index].labelRanking.Text = tostring(pageData[pIndex][index].rank);
			armoryPageList[pIndex][index].labelLevel.Text = tostring(pageData[pIndex][index].level);
			armoryPageList[pIndex][index].labelFP.Text = tostring(pageData[pIndex][index].fp);	
			armoryPageList[pIndex][index].brushReward.Tag = pageData[pIndex][index].rank;
			
			--显示礼包和排名图片,设置字体
			if 1 == pageData[pIndex][index].rank then
				armoryPageList[pIndex][index].labelRanking.TextColor = QuadColor(Color(255, 249, 153, 255), Color(255, 162, 0, 255), Color(255, 249, 153, 255), Color(255, 162, 0, 255));
				armoryPageList[pIndex][index].labelRanking.Font = uiSystem:FindFont('artFont_24');
				armoryPageList[pIndex][index].brushRanking.Visibility = Visibility.Visible;
				armoryPageList[pIndex][index].brushReward.Background = uiSystem:FindResource('pvp_libao_1', 'godsSenki');
			elseif 2 == pageData[pIndex][index].rank then
				armoryPageList[pIndex][index].labelRanking.TextColor = QuadColor(Color(255, 255, 255, 255), Color(133, 133, 133, 255), Color(255, 255, 255, 255), Color(133, 133, 133, 255));
				armoryPageList[pIndex][index].labelRanking.Font = uiSystem:FindFont('artFont_24');
				armoryPageList[pIndex][index].brushRanking.Visibility = Visibility.Visible;
				armoryPageList[pIndex][index].brushReward.Background = uiSystem:FindResource('pvp_libao_2', 'godsSenki');
			elseif 3 == pageData[pIndex][index].rank then
				armoryPageList[pIndex][index].labelRanking.TextColor = QuadColor(Color(231, 151, 87, 255), Color(149, 46, 19, 255), Color(231, 151, 87, 255), Color(149, 46, 19, 255));
				armoryPageList[pIndex][index].labelRanking.Font = uiSystem:FindFont('artFont_24');
				armoryPageList[pIndex][index].brushRanking.Visibility = Visibility.Visible;
				armoryPageList[pIndex][index].brushReward.Background = uiSystem:FindResource('pvp_libao_3', 'godsSenki');
			else
				armoryPageList[pIndex][index].labelRanking.TextColor = QuadColor(Color(255, 255, 255, 255));
				armoryPageList[pIndex][index].labelRanking.Font = uiSystem:FindFont('huakang_20');
				armoryPageList[pIndex][index].brushRanking.Visibility = Visibility.Hidden;
				if pageData[pIndex][index].rank > 10 then
					armoryPageList[pIndex][index].brushReward.Visibility = Visibility.Hidden;
				else
					armoryPageList[pIndex][index].brushReward.Background = uiSystem:FindResource('pvp_libao_4', 'godsSenki');
				end	
			end	
		else
			armoryPageList[pIndex][index].row.Visibility = Visibility.Hidden;
		end
		
	end
	
end

--刷新页面下圆形标志
function ArmoryPanel:refreshPageFlag(pNewIndex)
	local pageCount = #pageData;
	local flagIndex = 0;	
	
	if 1 == pNewIndex then
		flagIndex = 1;
	elseif 2 == pNewIndex then
		flagIndex = 2;
	elseif ((pageCount - 1) == pNewIndex) then
		flagIndex = #pageFlagList - 1;
	elseif (pageCount == pNewIndex) then	
		flagIndex = #pageFlagList;
	else
		flagIndex = 3;
	end
	
	--隐藏上一个显示的圆圈
	for index,pageFlag in ipairs(pageFlagList) do
		if index ~= flagIndex then
			pageFlag.Visibility = Visibility.Hidden;
		else
			pageFlag.Visibility = Visibility.Visible;
		end
	end
end
--==========================================================================================
--事件
--关闭事件
function ArmoryPanel:onClose()
	MainUI:Pop();
end

--弹出菜单失去焦点
function ArmoryPanel:onInfoPopupMenuLoseFocus()
	infoPopupMenu.Visibility = Visibility.Hidden;
end

--翻页事件
function ArmoryPanel:onPageChange(Args)
	local args = UITabControlPageChangeEventArgs(Args);
	selectPageIndex = args.m_pNewPage + 1;
	self:refreshPageFlag(selectPageIndex);
end

--显示英雄榜
function ArmoryPanel:onShowArmory(msg)
	for _,item in ipairs(msg.pages) do
		local data = cjson.decode(item);
		pageData[data.page*2 - 1] = {};
		pageData[data.page*2] = {};
		for index = 1, 5 do
			table.insert(pageData[data.page*2 - 1], data.rows[index]);
		end

		for index = 6, 10 do
			table.insert(pageData[data.page*2], data.rows[index]);
		end		
	end	
	MainUI:Push(self);
end

--显示礼包tips
function ArmoryPanel:onShowRewardTips(Args)
	local args = UIControlEventArgs(Args);
	local item = {};
	if 1 == args.m_pControl.Tag then
		item.resid = 15005;
	elseif 2 == args.m_pControl.Tag then
		item.resid = 15006;
	elseif 3 == args.m_pControl.Tag then
		item.resid = 15007;
	elseif (args.m_pControl.Tag > 3) and (args.m_pControl.Tag < 11) then
		item.resid = 15008;
	end	
	TooltipPanel:ShowItem( panel, item, TipPacksShowButton.PacksNothing );
end

--玩家姓名点击事件
function ArmoryPanel:onPlayerClick(Args)
	local args = UIControlEventArgs(Args);
	mainDesktop.FocusControl = infoPopupMenu;
	infoPopupMenu.Visibility = Visibility.Visible;
	infoPopupMenu.Translate = Vector2(PopupMenuXPos, PopupMenuYPos[args.m_pControl.Tag]);
	selectRowIndex = args.m_pControl.Tag;
end

--查看玩家信息
function ArmoryPanel:onLookOverPlayerInfo(Args)
	local args = UIControlEventArgs(Args);	
	local msg = {};	
	msg.uid = pageData[selectPageIndex][selectRowIndex].uid;
	Network:Send(NetworkCmdType.req_view_user_info, msg);	
	
	infoPopupMenu.Visibility = Visibility.Hidden;
end

--发送私聊
function ArmoryPanel:onChat(Args)
	local data = pageData[selectPageIndex][selectRowIndex];
	ChatPanel:onWisper(data.uid, data.name, data.level);
	infoPopupMenu.Visibility = Visibility.Hidden;
end

--加为好友
function ArmoryPanel:onAddFriend(Args)
	local uid = pageData[selectPageIndex][selectRowIndex].uid;
	Friend:onAddFriend(uid);
	infoPopupMenu.Visibility = Visibility.Hidden;
end	
