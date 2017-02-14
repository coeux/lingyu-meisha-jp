--unionDialogPanel.lua
--========================================================================================================================================================
--公会npc对话框

UnionDialogPanel =
	{
	};

--常量
local maxBtnNum = 3;
	
--变量
local UnionNpc = {901,902,903,907,Configuration.StatueNPCID,908};
local npcID;

--控件
local panel;
local mainDesktop;
local labelNpcName;
local labelTalkContent;
local btnOperation1;
local btnContent1;
local btnOperation2;
local btnContent2;
local portraitImage;				--半身像
local leftPanel;
local lImage;
local lName;
local btnList;
local btnPanel;

--初始化
function UnionDialogPanel:InitPanel(desktop)
	--变量初始化
	UnionNpc = {901,902,903,907,Configuration.StatueNPCID,908};
	npcID = 0;
	
	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('unionDialogPanel'));
	panel:IncRefCount();

	leftPanel = Panel(panel:GetLogicChild('leftPanel'));
	lImage = ImageElement(leftPanel:GetLogicChild('leftImage'));
	lName = Label(leftPanel:GetLogicChild('leftName'));

	labelTalkContent = panel:GetLogicChild('scpanel'):GetLogicChild('child'):GetLogicChild('scenarioInfo');
	btnPanel = panel:GetLogicChild('selectPanel'):GetLogicChild('btnPanel');
	btnList = {};
	for i=1, maxBtnNum do
		btnList[i] = btnPanel:GetLogicChild('choiceBtn' .. i);
		btnList[i]:SubscribeScriptedEvent('Button::ClickEvent', 'UnionDialogPanel:onOpt'..i);
	end
	scenarioBtn = panel:GetLogicChild('scenarioBtn');
	scenarioBtn:SubscribeScriptedEvent('Button::ClickEvent','UnionDialogPanel:onClose');
	panel.Visibility = Visibility.Hidden;
end

--销毁
function UnionDialogPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function UnionDialogPanel:Show()
	local data = resTableManager:GetRowValue(ResTable.npc, tostring(npcID));
	lName.Text = data['name'];
	--labelNpcName.Text = data['name'];
	labelTalkContent.Text = data['dialogue'];
	lImage.Image = GetPicture('navi/' .. data['portrait'] .. '.ccz');
	local btnNum;
	if UnionNpc[1] == npcID then			--公会管家
		btnNum = 3;
		btnList[1].Text = '  ' .. LANG_unionDialogPanel_1;
		btnList[2].Text = '  ' .. LANG_unionDialogPanel_6;
		btnList[3].Text = '  ' .. LANG_unionDialogPanel_7;

	elseif UnionNpc[2] == npcID then		--工会技能
		btnNum = 1;
		btnList[1].Text = '  ' .. LANG_unionDialogPanel_2;

	elseif UnionNpc[3] == npcID then		--公会boss
		btnNum = 2;
		if WOUBossPanel.isUnionBossAva then
			btnList[1].Text = '  ' .. LANG_unionDialogPanel_4;
		else
			btnList[1].Text = '  ' .. LANG_unionDialogPanel_3;
			if 0 == ActorManager.user_data.unionPos then
				btnList[1].Text = '  ' .. LANG_unionDialogPanel_16;
			end
		end
		--if 2 == ActorManager.user_data.unionPos then	--会长
		btnList[2].Text = '  ' .. LANG_unionDialogPanel_15;
		labelTalkContent.Text = LANG_unionDialogPanel_17;
	elseif UnionNpc[4] == npcID then
		btnNum = 2
		if UnionBattlePanel.union_battle_state == 0 then
		elseif UnionBattlePanel.union_battle_state == 1 then
			btnList[1].Text = '  ' ..LANG_union_battle_16
			if UnionBattlePanel.union_state == 0 then
				labelTalkContent.Text = LANG_union_battle_35
			else
				labelTalkContent.Text = LANG_union_battle_36
			end
		elseif UnionBattlePanel.union_battle_state == 2 then
			btnList[1].Text = '  ' ..LANG_union_battle_17
			if UnionBattlePanel.union_state == 0 then
				labelTalkContent.Text = LANG_union_battle_37
			else
				labelTalkContent.Text = LANG_union_battle_38
			end
		elseif UnionBattlePanel.union_battle_state == 3 then
			btnList[1].Text = '  ' ..LANG_union_battle_18
			if UnionBattlePanel.union_state == 0 then
				labelTalkContent.Text = LANG_union_battle_39
			else
				labelTalkContent.Text = LANG_union_battle_40
			end
		elseif UnionBattlePanel.union_battle_state == 10 then
			labelTalkContent.Text = LANG_union_battle_34
		elseif UnionBattlePanel.union_battle_state == 11 then
			labelTalkContent.Text = LANG_union_battle_36
		elseif UnionBattlePanel.union_battle_state == 12 then
			labelTalkContent.Text = LANG_union_battle_45
		elseif UnionBattlePanel.union_battle_state == 13 then
			labelTalkContent.Text = LANG_union_battle_48
		end
		
	    btnList[2].Text = '  ' .. LANG_unionDialogPanel_9
    elseif UnionNpc[6] == npcID then
    	btnNum = 2
    	btnList[1].Text = '  ' .. LANG_TaskDialogPanel_2
    	btnList[2].Text = '  ' .. LANG_ShopSetPanel_5
	end
	
	local space = (5-btnNum)*10;
	btnPanel.Size = Size(270, space*(btnNum-1)+50*btnNum);
	btnPanel.Space = space;
	for i=1, maxBtnNum do
		if i <= btnNum then
			btnList[i].Visibility = Visibility.Visible;
		else
			btnList[i].Visibility = Visibility.Hidden;
		end
	end
	if UnionNpc[4] == npcID then
		if (math.floor(UnionBattlePanel.union_battle_state / 10) > 0) 
		or (UnionBattlePanel.union_battle_state == 1 and UnionBattlePanel.union_state == 1) 
		or UnionBattlePanel.union_battle_state == 0 then
			local space = 4*10;
			btnPanel.Size = Size(270, 50);
			btnPanel.Space = space;
			btnList[1].Visibility = Visibility.Hidden
		end
	end
	
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end
function UnionDialogPanel:setTalkContentText()
	labelTalkContent.Text = LANG_union_battle_36
	btnList[1].Visibility = Visibility.Hidden
end
--隐藏
function UnionDialogPanel:Hide()
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--===============================================================================================
--功能函数
--设置公会npcID
function UnionDialogPanel:SetNpcID(id)
	npcID = id;
end

function UnionDialogPanel:GetNpcID()
	return npcID
end
--===========================================================================================
--事件
--关闭
function UnionDialogPanel:onClose()
	MainUI:Pop();
end

--显示
function UnionDialogPanel:onShow()
	if UnionNpc[5] == npcID then
		UnionPanel:onShowAlter();
	else
		MainUI:Push(UnionDialogPanel);
	end	
end

--点击按钮事件
function UnionDialogPanel:onOpt1()
	MainUI:Pop();

	if UnionNpc[1] == npcID then			--公会管家
		
		MainUI:RequestUnionScene();	
		
	elseif UnionNpc[2] == npcID then		--工会技能
		
		Network:Send(NetworkCmdType.req_gskl_list, {});	--查看公会技能
		
	elseif UnionNpc[3] == npcID then		--公会boss
		if ActorManager.user_data.unionLevel < Configuration.UnionBossOpenLevel then
			Toast:MakeToast(Toast.TimeLength_Long, LANG_unionDialogPanel_5);
		else
			--MainUI:Push(UnionSetBossTimePanel);
			if  WOUBossPanel.isUnionBossAva then
				--MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionDialogPanel_13);
				MainUI:onUnionBossClick();
			elseif 2 == ActorManager.user_data.unionPos or 1 == ActorManager.user_data.unionPos then
				local data = resTableManager:GetRowValue(ResTable.unionboss_open, tostring(WOUBossPanel.bosscount+1));
				if data == nil then
					MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionDialogPanel_14);
				else
					local totalcount = 0;
					local leftcount = 0;
					local gold = 0;
					local yb = 0;
					local i=1;
					local level = ActorManager.user_data.unionLevel;
					while true do
						local tmp = resTableManager:GetRowValue(ResTable.unionboss_open, tostring(i));
						if tmp == nil then
							break;
						end
						if level >= tmp['guild_lv'] then
							totalcount = totalcount + 1;
						end
						i = i + 1;
					end
					leftcount = totalcount - WOUBossPanel.bosscount;
					if data['cost'] ~= nil then 
						if data['cost'][1][1] == 10001 then
							gold = data['cost'][1][2];
						elseif data['cost'][1][1] == 10003 then
							yb = data['cost'][1][2];
						end
					end
					--local tip = '是否';
					local contents = {};
					local content1 = '';
					local content2 = '';
					local content3 = '';
					local content4 = '';
					if (gold == 0 and yb == 0) or leftcount <= 0 then
      					content1 = LANG_unionDialogPanel_18;
      					content2 = LANG_unionDialogPanel_19;
      					content3 = LANG_unionDialogPanel_20;
      					content4 = LANG_unionDialogPanel_21;
						--tip = tip .. '激活社团boss，boss场景将在17点后可进入挑战，本周剩余挑战次数：'..tostring(leftcount);
					elseif gold == 0 then
						content1 = LANG_unionDialogPanel_22;
      					content2 = LANG_unionDialogPanel_23;
      					content3 = LANG_unionDialogPanel_24;
      					content4 = LANG_unionDialogPanel_25..tostring(yb);
						--tip = tip .. '消耗'..tostring(yb)..'钻石激活社团boss，boss场景将在17点后可进入挑战，本周剩余挑战次数：'..tostring(leftcount);
					elseif yb == 0 then
						content1 = LANG_unionDialogPanel_26;
      					content2 = LANG_unionDialogPanel_27;
      					content3 = LANG_unionDialogPanel_28;
      					content4 = LANG_unionDialogPanel_29..tostring(gold)
						--tip = tip .. '消耗'..tostring(gold)..'金币激活社团boss，boss场景将在17点后可进入挑战，本周剩余挑战次数：'..tostring(leftcount);
					end
					--table.insert(contents,{cType = MessageContentType.Text; text = content1});
      				table.insert(contents,{cType = MessageContentType.Text; text = content2});
      				table.insert(contents,{cType = MessageContentType.Text; text = content3});
      				table.insert(contents,{cType = MessageContentType.Text; text = content4});
					local okDelegate = Delegate.new(UnionDialogPanel,UnionDialogPanel.openBoss);
					local cancelDelegate = Delegate.new(UnionDialogPanel,UnionDialogPanel.cancelOpenBoss);
					MessageBox:ShowDialog(MessageBoxType.OkCancel, contents, okDelegate, cancelDelegate);
				end
			end
		end
	elseif 	UnionNpc[4] == npcID then 		--社团战斗
		--UnionBattlePanel:reqEnlist()
		---[[
		if UnionBattlePanel.union_battle_state == 0 then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_union_battle_15);
		elseif UnionBattlePanel.union_battle_state == 1 then
			if UnionBattlePanel.union_state == 0 then
				if ActorManager.user_data.unionPos == 0 then
					MessageBox:ShowDialog(MessageBoxType.Ok, LANG_unionDialogPanel_10);
				else
					if ActorManager.user_data.unionLevel >= 5 then
						UnionBattlePanel:reqEnlist()
					else
						MessageBox:ShowDialog(MessageBoxType.Ok, LANG_union_battle_19);
					end
				end
			else
				MessageBox:ShowDialog(MessageBoxType.Ok, LANG_union_battle_12);	
			end
		elseif UnionBattlePanel.union_battle_state == 2 then
			if UnionBattlePanel.union_state == 0 then
				MessageBox:ShowDialog(MessageBoxType.Ok, LANG_union_battle_13);	
			else
				UnionBattlePanel:reqWholeDefenceInfo()
			end
		elseif UnionBattlePanel.union_battle_state == 3 then
			if UnionBattlePanel.union_state == 0 then
				MessageBox:ShowDialog(MessageBoxType.Ok, LANG_union_battle_14);
			else
				UnionBattlePanel:reqWholeDefenceInfoFight()
			end
		end
		--]]
	end	

end


function UnionDialogPanel:openBoss()
	Network:Send(NetworkCmdType.req_open_union_boss, {});
end

function UnionDialogPanel:cancelOpenBoss()
end

--点击按钮事件
function UnionDialogPanel:onOpt2()
	MainUI:Pop();
	if UnionNpc[1] == npcID then			--公会管家
		MainUI:Push(UnionDonatePanel);
	elseif UnionNpc[3] == npcID then
		MainUI:Push(UnionExplainPanel);
	elseif UnionNpc[4] == npcID then		--社团战斗说明
		MainUI:Push(UnionExplainPanel);
	elseif UnionNpc[6] == npcID then 
		ShopSetPanel:show(ShopSetType.guildShop)
	end
end

--公会说明
function UnionDialogPanel:onOpt3()
	MainUI:Pop();
	if UnionNpc[1] == npcID then			
		MainUI:Push(UnionExplainPanel);
	end
end
