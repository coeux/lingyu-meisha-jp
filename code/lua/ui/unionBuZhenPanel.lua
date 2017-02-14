--UnionBuZhenPanel.lua
--================================================================================
UnionBuZhenPanel =
{
	nextLevelMoney = 0;
	buildingLevel = 0;
	buildingId = 0;
	selfFp = 0;
	buzhenCount = 0;
};
GBState = 
{
	unknown = 0,
	normal = 1,
	infight = 2,
	over = 3,
	sacrificing = 4,
	sacrificed = 5,
	spy_fight = 6,
	watch_fight = 7,
}
--控件
local mainDesktop;
local unionBuZhenPanel;
local topPanel;
local returnBtn; 
local itemStack;
local touchScroll;
local leftPanel;
local leftUpPanel;
local leftUpBtn;
local leftJinBi;
local nowAttPanel;
local upAttPanel;
local upMaxLabel;
local nowAttlabelList = {};
local upAttlabelList = {};
local teamItemList = {};
local saJoinPanel;
local joinPanelMain;
local joinPanelMinor;
local joinMainFpNeed;
local joinMinorFpCur;
local joinMinorFpNeed

local monsterId = 3006;
local roundId 							--关卡ID
local roundPos							--关卡pos
local defence_info = {}
local defence_state = {}
local tDefenceState = {}
--变量
--======================================================================================
function UnionBuZhenPanel:InitPanel(desktop)
	mainDesktop = desktop;
	unionBuZhenPanel = desktop:GetLogicChild('unionBuZhenPanel');
	unionBuZhenPanel:IncRefCount();
	unionBuZhenPanel.Visibility = Visibility.Hidden;
	returnBtn = unionBuZhenPanel:GetLogicChild('returnBtn');
	touchScroll = unionBuZhenPanel:GetLogicChild('touchScroll')
	itemStack = touchScroll:GetLogicChild('itemStack')
	topPanel = unionBuZhenPanel:GetLogicChild('topPanel')
	self:initLeftPanel()
	self:initSaJoinPanel();
end


function UnionBuZhenPanel:initLeftPanel()
	leftPanel = unionBuZhenPanel:GetLogicChild('leftPanel')
	leftUpPanel = leftPanel:GetLogicChild('upPanel')
	leftUpBtn = leftUpPanel:GetLogicChild('upBtn')
	leftUpBtn:SubscribeScriptedEvent('Button::ClickEvent','UnionBuZhenPanel:buildingLevelUpClick')
	leftJinBi = leftUpPanel:GetLogicChild('jinbi')

	nowAttPanel = leftPanel:GetLogicChild('jueDianAttrBef')
	for i = 1 , 5 do
		table.insert(nowAttlabelList,nowAttPanel:GetLogicChild('attrPanel'):GetLogicChild('attr'..i):GetLogicChild('value'))
	end	

	upAttPanel = leftPanel:GetLogicChild('jueDianAttrAft')
	for i = 1 , 5 do
		table.insert(upAttlabelList,upAttPanel:GetLogicChild('attrPanel'):GetLogicChild('attr'..i):GetLogicChild('value'))
	end	
	upMaxLabel = upAttPanel:GetLogicChild('upperLabel')
	upMaxLabel.Visibility = Visibility.Hidden
end

function UnionBuZhenPanel:initSaJoinPanel()
	saJoinPanel = unionBuZhenPanel:GetLogicChild('saJoinPanel');
	saJoinPanel.Visibility = Visibility.Hidden;
	joinPanelMain = saJoinPanel:GetLogicChild('mainPanel'):GetLogicChild('panel_main');
	joinPanelMinor = {};
	for i=1, 3 do
		joinPanelMinor[i] = saJoinPanel:GetLogicChild('otherPanel'):GetLogicChild('panel_'..i);
	end
	saJoinPanel:GetLogicChild('close'):SubscribeScriptedEvent('Button::ClickEvent', 'UnionBuZhenPanel:closeSacificeInfo');
	joinMainFpNeed = saJoinPanel:GetLogicChild('mainPanel'):GetLogicChild('main_fp');
	joinMinorFpCur = saJoinPanel:GetLogicChild('otherPanel'):GetLogicChild('minor_fp_cur');
	joinMinorFpNeed = saJoinPanel:GetLogicChild('otherPanel'):GetLogicChild('minor_fp_need');
end

--我方建筑属性
function UnionBuZhenPanel:freshLeftPanel(buildLevel)
	leftUpPanel.Visibility = Visibility.Visible
	upAttPanel.Visibility = Visibility.Visible
	upAttPanel:GetLogicChild('attrPanel').Visibility = Visibility.Visible
	upMaxLabel.Visibility = Visibility.Hidden
	local bLevel  = 0;
	if UnionBattlePanel.unionSideFlage == 1 then
		bLevel = UnionBattlePanel.buildingLevel;
	else
		bLevel = UnionBattlePanel.otherBuidingLevel;
	end
	self.buildingLevel = 0
	if buildLevel then
		self.buildingLevel = buildLevel
	else
		for k,v in pairs(bLevel) do
			if tonumber(k) == self.buildingId then
				self.buildingLevel = v;
				break;
			end
		end
	end
	if self.buildingLevel == 0 then
		self.buildingLevel = 1
	end

	local buildingType = resTableManager:GetValue(ResTable.guild_battle, tostring(self.buildingId), 'type');
	local descrip = resTableManager:GetRowValue(ResTable.guild_battle_building, tostring(tonumber(buildingType)*100+self.buildingLevel));
	nowAttlabelList[1].Text = 'Lv.'..tostring(self.buildingLevel)
	nowAttlabelList[2].Text = tostring(descrip['score'])
	nowAttlabelList[3].Text = tostring(descrip['station'])
	if descrip['description1'] then
		nowAttlabelList[4].Visibility = Visibility.Visible
		nowAttlabelList[4].Text = tostring(descrip['description1'])
	else
		nowAttlabelList[4].Visibility = Visibility.Hidden
	end
	if descrip['description2'] then
		nowAttlabelList[5].Visibility = Visibility.Visible
		nowAttlabelList[5].Text = tostring(descrip['description2'])
	else
		nowAttlabelList[5].Visibility = Visibility.Hidden
	end
	if UnionBattlePanel.unionSideFlage == 1 then
		self.nextLevelMoney = tonumber(descrip['gold_spend'])
		leftJinBi.Text = tostring(descrip['gold_spend'])
		if tonumber(descrip['gold_spend']) == 0 then
			leftUpPanel.Visibility = Visibility.Hidden
			upAttPanel:GetLogicChild('attrPanel').Visibility = Visibility.Hidden
			upMaxLabel.Visibility = Visibility.Visible 
		else
			upDescrip = resTableManager:GetRowValue(ResTable.guild_battle_building, tostring(tonumber(buildingType)*100+self.buildingLevel+1));
			upAttlabelList[1].Text = 'Lv.'..tostring((self.buildingLevel+1))
			upAttlabelList[2].Text = tostring(upDescrip['score'])
			upAttlabelList[3].Text = tostring(upDescrip['station'])
			if upDescrip['description1'] then
				upAttlabelList[4].Visibility = Visibility.Visible
				upAttlabelList[4].Text = tostring(upDescrip['description1'])
			else
				upAttlabelList[4].Visibility = Visibility.Hidden
			end
			if upDescrip['description2'] then
				upAttlabelList[5].Visibility = Visibility.Visible
				upAttlabelList[5].Text = tostring(upDescrip['description2'])
			else
				upAttlabelList[5].Visibility = Visibility.Hidden
			end
		end
	else
		leftUpPanel.Visibility = Visibility.Hidden
		upAttPanel.Visibility = Visibility.Hidden
	end

end
function UnionBuZhenPanel:freshStack(data)
	teamItemList = {}
	itemStack:RemoveAllChildren()
	touchScroll:VScrollBegin()
	local bLevel = 0
	for k,v in pairs(UnionBattlePanel.buildingLevel) do
		if tonumber(k) == self.buildingId then
			bLevel = v;
		end
	end
	if bLevel == 0 then
		bLevel = 1
	end
	local buildingType = resTableManager:GetValue(ResTable.guild_battle, tostring(self.buildingId), 'type');
	local station = resTableManager:GetValue(ResTable.guild_battle_building, tostring(tonumber(buildingType)*100+bLevel),'station');
	for i = 1 , tonumber(station) do 
		local uiControl = uiSystem:CreateControl('unionBattleItemTemplate')
		local ctrol = uiControl:GetLogicChild(0)
		ctrol:GetLogicChild('rankLabel').Text = 'NO.'..i
		local tPanel = ctrol:GetLogicChild('panel')
		local btnStack = tPanel:GetLogicChild('btnPanel'):GetLogicChild('btnStack')
		local evacuateBtn = btnStack:GetLogicChild('evacuateBtn');
		evacuateBtn:SubscribeScriptedEvent('Button::ClickEvent','UnionBuZhenPanel:evacuateOnClick')
		evacuateBtn.Tag = i --撤退
		local noEmbattlePanel = ctrol:GetLogicChild('noEmbattlePanel')
		if UnionBattlePanel.union_battle_state ~= 3 then
			noEmbattlePanel:SubscribeScriptedEvent('UIControl::MouseClickEvent','UnionBuZhenPanel:NoEmbattleOnClick')
			noEmbattlePanel.Tag = i
		end
		table.insert(teamItemList,ctrol)
		if data[''..i] then
			self:InitItem(i,data[''..i])
		else
			self:InitItem(i)
		end
		itemStack:AddChild(uiControl)
	end

end
--敌方建筑
function UnionBuZhenPanel:freshOtherStack()
	teamItemList = {};
	touchScroll:VScrollBegin()
	itemStack:RemoveAllChildren();
	local n = 1
	while defence_info[tostring(n)] do
		--for k,itemData in pairs(defence_info) do
		local uiControl = uiSystem:CreateControl('unionBattleItemTemplate')
		local ctrol = uiControl:GetLogicChild(0)
		table.insert(teamItemList,ctrol)
		ctrol:GetLogicChild('rankLabel').Text = 'NO.'..n
		local tPanel = ctrol:GetLogicChild('panel')
		local btnStack = tPanel:GetLogicChild('btnPanel'):GetLogicChild('btnStack')
		local challengeBtn = btnStack:GetLogicChild('challengeBtn')
		challengeBtn:SubscribeScriptedEvent('Button::ClickEvent','UnionBuZhenPanel:challengeOnClick')
		local sleuthingBtn = btnStack:GetLogicChild('sleuthingBtn')
		sleuthingBtn:SubscribeScriptedEvent('Button::ClickEvent','UnionBuZhenPanel:sleuOnClick')
		local evacuateBtn = btnStack:GetLogicChild('evacuateBtn');
		evacuateBtn.Visibility = Visibility.Hidden
		sleuthingBtn.Tag = tonumber(n) --侦查
		sleuthingBtn.Text = LANG_union_battle_33
		challengeBtn.Tag = tonumber(n) --挑战
		local sacrificePanel = tPanel:GetLogicChild('btnPanel'):GetLogicChild('sacrifice');
		local beginSbtn = sacrificePanel:GetLogicChild('sacrifice_begin');
		beginSbtn.Tag = tonumber(n);
		beginSbtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'UnionBuZhenPanel:onSacrificeBegin');
		local joinSbtn = sacrificePanel:GetLogicChild('sacrifice_join');
		joinSbtn.Tag = tonumber(n);
		joinSbtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'UnionBuZhenPanel:onSacrificeJoin');
		sacrificePanel:GetLogicChild('sacrificed').Tag = tonumber(n);
		local noEmbattlePanel = ctrol:GetLogicChild('noEmbattlePanel')
		noEmbattlePanel.Visibility = Visibility.Hidden
		itemStack:AddChild(uiControl)
		n = n + 1
	end
	self:freshItem()
end
function UnionBuZhenPanel:freshItem()
	local tPos = -1;
	local tState = -1;
	local n = 1;
	while defence_state[tostring(n)] do
		--for k,state in pairs(defence_state) do
		local state = defence_state[tostring(n)]
		if state ~= GBState.over then
			tPos = n;
			tState = tonumber(state);
			break;
		end
		n = n + 1;
	end

	if tState  == GBState.unknown then
		defence_state[''..tPos] = GBState.spy_fight;
	elseif tState == 1 then
		defence_state[''..tPos] = GBState.watch_fight;
	end
	n = 1;
	while defence_state[tostring(n)] do
		--for k,state in pairs(defence_state) do
		local state = defence_state[tostring(n)]
		self:InitItem(n,defence_info[tostring(n)], state);
		--[[
		if state == 0 then
			self:InitItem(n,defence_info[''..n],3)
		elseif state == 1 then
			self:InitItem(n,defence_info[''..n],5)
		elseif state == 2 then
			self:InitItem(n,defence_info[''..n],6)
		elseif state == 3 then
			self:InitItem(n,defence_info[''..n],4)
		elseif state == 4 then
			self:InitItem(n,defence_info[''..n],1)
		elseif state == 5 then
			self:InitItem(n,defence_info[''..n],2)
		end
		--]]
		n = n + 1;
	end
end
function UnionBuZhenPanel:InitItem(num,data,state,selfFlag)
	local ctrol = teamItemList[num]
	local tPanel = ctrol:GetLogicChild('panel')
	local infoPanel = tPanel:GetLogicChild('infoPanel')
	infoPanel.Visibility = Visibility.Hidden
	local btnPanel = tPanel:GetLogicChild('btnPanel')
	local btnStack = btnPanel:GetLogicChild('btnStack')
	btnPanel.Visibility = Visibility.Hidden
	local challengeBtn = btnStack:GetLogicChild('challengeBtn')
	local sleuthingBtn = btnStack:GetLogicChild('sleuthingBtn')
	local evacuateBtn = btnStack:GetLogicChild('evacuateBtn');
	challengeBtn.Visibility = Visibility.Hidden
	sleuthingBtn.Visibility = Visibility.Hidden
	evacuateBtn.Visibility = Visibility.Hidden
	local kbImg = tPanel:GetLogicChild('kbImg')
	local jzImg = tPanel:GetLogicChild('onFighting')
	jzImg.Visibility = Visibility.Hidden
	kbImg.Visibility = Visibility.Hidden
	local noinfo = tPanel:GetLogicChild('noinfo')
	noinfo.Visibility = Visibility.Hidden
	local headStack = tPanel:GetLogicChild('headItem')
	local noEmbattlePanel = ctrol:GetLogicChild('noEmbattlePanel')
	local sacrificePanel = btnPanel:GetLogicChild('sacrifice');
	sacrificePanel.Visibility = Visibility.Hidden;
	local sacrifice_begin = sacrificePanel:GetLogicChild('sacrifice_begin');
	sacrifice_begin.Visibility = Visibility.Hidden;
	local sacrifice_join = sacrificePanel:GetLogicChild('sacrifice_join');
	sacrifice_join.Visibility = Visibility.Hidden;
	local sacrifice_img = sacrificePanel:GetLogicChild('sacrificing');
	sacrifice_img.Visibility = Visibility.Hidden;
	local sacrificed_btn = sacrificePanel:GetLogicChild('sacrificed');
	sacrificed_btn.Visibility = Visibility.Hidden;
	for z = 1,5 do 
		headStack:GetLogicChild(z-1):RemoveAllChildren()
	end
	if data then
		local nameLabel = infoPanel:GetLogicChild('nameLabel')
		local zhandouli = infoPanel:GetLogicChild('zhandouli')
		if state then
			if state == GBState.spy_fight then --侦查,挑战
				for j = 1 , 5 do
					local o = customUserControl.new(headStack:GetLogicChild(j-1), 'cardHeadTemplate');
					o.initUnionItemEnemy(68);
				end
				btnPanel.Visibility = Visibility.Visible
				noinfo.Visibility = Visibility.Visible
				challengeBtn.Visibility = Visibility.Visible
				sleuthingBtn.Visibility = Visibility.Visible
			elseif state == GBState.watch_fight then --挑战
				local itemData = data
				infoPanel.Visibility = Visibility.Visible
				btnPanel.Visibility = Visibility.Visible
				challengeBtn.Visibility = Visibility.Visible
				if itemData.uid ~= -1 then
					for j = 1 , #itemData.team_info do
						local role = itemData.team_info[j]
						local o = customUserControl.new(headStack:GetLogicChild(j-1), 'cardHeadTemplate');
						o.initEnemyInfo(role,68);
					end
					nameLabel.Text = tostring(itemData.name)
				else
					nameLabel.Text = LANG_union_battle_44
					local o = customUserControl.new(headStack:GetLogicChild(0), 'cardHeadTemplate');
					local icon = resTableManager:GetValue(ResTable.monster, tostring(monsterId), 'icon');
					o.initUnionDefendItemEnemy(68,icon);
				end
				zhandouli.Text = tostring(itemData.fp);
				sacrificePanel.Visibility = Visibility.Hidden;
				sacrifice_begin.Visibility = Visibility.Hidden;

			elseif state == GBState.unknown then --侦查
				for j = 1 , 5 do
					local o = customUserControl.new(headStack:GetLogicChild(j-1), 'cardHeadTemplate');
					o.initUnionItemEnemy(68);
				end
				noinfo.Visibility = Visibility.Visible
				btnPanel.Visibility = Visibility.Visible
				sleuthingBtn.Visibility = Visibility.Visible
			elseif state == GBState.over then	--溃败
				local itemData = data
				infoPanel.Visibility = Visibility.Visible
				if itemData.uid ~= -1 then
					for j = 1 , #itemData.team_info do
						local role = itemData.team_info[j]
						local o = customUserControl.new(headStack:GetLogicChild(j-1), 'cardHeadTemplate');
						o.initEnemyInfo(role,68);
						o.setDefeated()
					end
					nameLabel.Text = tostring(itemData.name)
				else
					nameLabel.Text = LANG_union_battle_44
					local o = customUserControl.new(headStack:GetLogicChild(0), 'cardHeadTemplate');
					local icon = resTableManager:GetValue(ResTable.monster, tostring(monsterId), 'icon');
					o.initUnionDefendItemEnemy(68,icon);
					o.setDefeated()
				end

				zhandouli.Text = tostring(itemData.fp);
				kbImg.Visibility = Visibility.Visible
			elseif state == GBState.normal then	--侦查后不能挑战的
				local itemData = data
				infoPanel.Visibility = Visibility.Visible
				if itemData.uid ~= -1 then
					for j = 1 , #itemData.team_info do
						local role = itemData.team_info[j]
						local o = customUserControl.new(headStack:GetLogicChild(j-1), 'cardHeadTemplate');
						o.initEnemyInfo(role,68);
					end
					nameLabel.Text = tostring(itemData.name)
				else
					nameLabel.Text = LANG_union_battle_44
					local o = customUserControl.new(headStack:GetLogicChild(0), 'cardHeadTemplate');
					local icon = resTableManager:GetValue(ResTable.monster, tostring(monsterId), 'icon');
					o.initUnionDefendItemEnemy(68,icon);
				end
				zhandouli.Text = tostring(itemData.fp);
			elseif state == GBState.infight then	--激战中
				local itemData = data
				infoPanel.Visibility = Visibility.Visible
				if itemData.uid ~= -1 then
					for j = 1 , #itemData.team_info do
						local role = itemData.team_info[j]
						local o = customUserControl.new(headStack:GetLogicChild(j-1), 'cardHeadTemplate');
						o.initEnemyInfo(role,68);
					end
					nameLabel.Text = tostring(itemData.name)
				else
					nameLabel.Text = LANG_union_battle_44
					local o = customUserControl.new(headStack:GetLogicChild(0), 'cardHeadTemplate');
					local icon = resTableManager:GetValue(ResTable.monster, tostring(monsterId), 'icon');
					o.initUnionDefendItemEnemy(68,icon);
				end
				zhandouli.Text = tostring(itemData.fp);
				jzImg.Visibility = Visibility.Visible
			elseif state == GBState.sacrificing then
				local itemData = data
				infoPanel.Visibility = Visibility.Visible
				btnPanel.Visibility = Visibility.Visible
				if itemData.uid ~= -1 then
					for j = 1 , #itemData.team_info do
						local role = itemData.team_info[j]
						local o = customUserControl.new(headStack:GetLogicChild(j-1), 'cardHeadTemplate');
						o.initEnemyInfo(role,68);
					end
					nameLabel.Text = tostring(itemData.name)
				else
					nameLabel.Text = LANG_union_battle_44
					local o = customUserControl.new(headStack:GetLogicChild(0), 'cardHeadTemplate');
					local icon = resTableManager:GetValue(ResTable.monster, tostring(monsterId), 'icon');
					o.initUnionDefendItemEnemy(68,icon);
				end
				zhandouli.Text = tostring(itemData.fp);
				sacrificePanel.Visibility = Visibility.Visible;
				sacrifice_join.Visibility = Visibility.Visible;
				sacrifice_img.Visibility = Visibility.Visible;
			elseif state == GBState.sacrificed then
				local itemData = data
				infoPanel.Visibility = Visibility.Visible
				if itemData.uid ~= -1 then
					for j = 1 , #itemData.team_info do
						local role = itemData.team_info[j]
						local o = customUserControl.new(headStack:GetLogicChild(j-1), 'cardHeadTemplate');
						o.initEnemyInfo(role,68);
					end
					nameLabel.Text = tostring(itemData.name)
				else
					nameLabel.Text = LANG_union_battle_44
					local o = customUserControl.new(headStack:GetLogicChild(0), 'cardHeadTemplate');
					local icon = resTableManager:GetValue(ResTable.monster, tostring(monsterId), 'icon');
					o.initUnionDefendItemEnemy(68,icon);
				end
				zhandouli.Text = tostring(itemData.fp);
				sacrificePanel.Visibility = Visibility.Visible;
				sacrifice_join.Visibility = Visibility.Visible;
				sacrificed_btn.Visibility = Visibility.Visible;
			end
		else
			if selfFlag then --自己上阵
				local team = UnionBattle:getUnionBattleTeamPidList()
				local count = 1
				for k,v in pairs(team) do
					if v >= 0 then
						local o = customUserControl.new(headStack:GetLogicChild(count-1), 'cardHeadTemplate');
						o.initWithPid(v,68);
						count = count + 1;
					end
				end
				infoPanel.Visibility = Visibility.Visible
				nameLabel.Text = tostring(ActorManager.user_data.name);
				zhandouli.Text = tostring(math.floor(self.selfFp));
				evacuateBtn.TagExt = ActorManager.user_data.uid
				btnPanel.Visibility = Visibility.Visible
				evacuateBtn.Visibility = Visibility.Visible
			else
				local itemData = data
				for j = 1 , #itemData.team_info do
					local role = itemData.team_info[j]
					local o = customUserControl.new(headStack:GetLogicChild(j-1), 'cardHeadTemplate');
					o.initEnemyInfo(role,68);
				end
				infoPanel.Visibility = Visibility.Visible
				nameLabel.Text = tostring(itemData.name)
				zhandouli.Text = tostring(itemData.fp);
				evacuateBtn.TagExt = itemData.uid
				if ActorManager.user_data.unionPos > 0 or itemData.uid == ActorManager.user_data.uid then
					--if UnionBattlePanel.union_battle_state ~= 3 then
					btnPanel.Visibility = Visibility.Visible
					evacuateBtn.Visibility = Visibility.Visible
					--end
				end
			end
		end
		tPanel.Visibility = Visibility.Visible
		noEmbattlePanel.Visibility = Visibility.Hidden
	else
		tPanel.Visibility = Visibility.Hidden
		noEmbattlePanel.Visibility = Visibility.Visible
	end

end

--挑战
function UnionBuZhenPanel:challengeOnClick(args)
	local arg = UIControlEventArgs(args);
	local id = arg.m_pControl.Tag;
	roundPos = id
	if UnionBattlePanel.ourPartnerCount == 0 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_union_battle_32);
		return;
	end
	if UnionBattlePanel.resetTimes == 0 then
		UnionBattlePanel:onBuy();
		return; 
	end
	if UnionBattlePanel.coolDown > 0 then
		local contents = {}
		local brushElement = uiSystem:CreateControl('BrushElement')
		brushElement.Background = CreateTextureBrush('recharge/GuildWelfare_gem.ccz', 'unionbattle')
		brushElement.Size = Size(37,34)
		table.insert(contents,{cType = MessageContentType.Text; text = LANG_union_battle_28,color = QuadColor(Color(9,47,145,255))})
		table.insert(contents,{cType = MessageContentType.Text; text = '50',color = QuadColor(Color(9,47,145,255))})
		table.insert(contents,{cType = MessageContentType.brush; brush = brushElement})
		table.insert(contents,{cType = MessageContentType.Text; text = LANG_union_battle_30,color = QuadColor(Color(9,47,145,255))})

		local okDelegate = Delegate.new(UnionBattlePanel,UnionBattlePanel.onClearCd,0)
		MessageBox:ShowDialog(MessageBoxType.OkCancel, contents, okDelegate)
		return;
	end
	UnionBattleSelectActorPanel:onShow(2)
end
function UnionBuZhenPanel:reqBattleFight()
	local msg = {};
	msg.building_id = self.buildingId;
	msg.building_pos = roundPos;
	msg.partners = UnionBattle:GetFightPartnersPid();
	Network:Send(NetworkCmdType.req_union_battle_fight, msg);
end
--侦查
function UnionBuZhenPanel:sleuOnClick(args)
	local arg = UIControlEventArgs(args);
	local id = arg.m_pControl.Tag;
	roundPos = id
	local contents = {}
	local brushElement = uiSystem:CreateControl('BrushElement')
	brushElement.Background = CreateTextureBrush('recharge/GuildWelfare_gem.ccz', 'unionbattle')
	brushElement.Size = Size(37,34)
	table.insert(contents,{cType = MessageContentType.Text; text = LANG_unionBattle_1,color = QuadColor(Color(9,47,145,255))})
	table.insert(contents,{cType = MessageContentType.brush; brush = brushElement})
	table.insert(contents,{cType = MessageContentType.Text; text = LANG_unionBattle_2,color = QuadColor(Color(9,47,145,255))})

	local okDelegate = Delegate.new(UnionBuZhenPanel,UnionBuZhenPanel.reqSleuthing,0)
	MessageBox:ShowDialog(MessageBoxType.OkCancel, contents, okDelegate)
end

function UnionBuZhenPanel:reqSleuthing(arg)
	if ActorManager.user_data.rmb >= 20 then
		local msg = {}
		msg.building_id = self.buildingId;
		msg.building_pos = roundPos;
		Network:Send(NetworkCmdType.req_union_battle_spy, msg)
	else
		RechargePanel:onShowRechargePanel();
	end
end
function UnionBuZhenPanel:retSleuthing(msg)
	print('retSleuthing-->')
end
--上阵
function UnionBuZhenPanel:NoEmbattleOnClick(args)
	local arg = UIControlEventArgs(args);
	local id = arg.m_pControl.Tag;
	roundPos = id

	if UnionBattlePanel.buzhenCount == 3 then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_union_battle_9);
		return
	else

	end

	UnionBattleSelectActorPanel:onShow(1)
end

--发起献祭
function UnionBuZhenPanel:onSacrificeBegin(args)
	local arg = UIControlEventArgs(args);
	roundPos = arg.m_pControl.Tag;
	local fp = defence_info[tostring(roundPos)].fp;
	UnionBattleSelectActorPanel:onShow(3, fp*0.8);
end

--加入献祭
function UnionBuZhenPanel:onSacrificeJoin(args)
	local arg = UIControlEventArgs(args);
	roundPos = arg.m_pControl.Tag;

	local msg = {};
	msg.building_id = self.buildingId;
	msg.building_pos = roundPos;
	Network:Send(NetworkCmdType.req_guild_battle_sacrifice_info_t, msg)
end

function UnionBuZhenPanel:sacrificeInfo(msg)
	-- fp
	joinMainFpNeed.Text = tostring(msg.fp_main_require);
	joinMinorFpNeed.Text = tostring(msg.fp_minor_require);
	local curFp = 0;
	if msg.pos_1 and msg.pos_1.uid ~= -1 then
		curFp = curFp + msg.pos_1.fp;
	end
	if msg.pos_2 and msg.pos_2.uid ~= -1 then
		curFp = curFp + msg.pos_2.fp;
	end
	if msg.pos_3 and msg.pos_3.uid ~= -1 then
		curFp = curFp + msg.pos_3.fp;
	end
	joinMinorFpCur.Text = tostring(curFp);
	if curFp >= msg.fp_minor_require then
		joinMinorFpCur.TextColor = QuadColor(Color.Green);
	else
		joinMinorFpCur.TextColor = QuadColor(Color.Red);
	end

	-- main role
	joinPanelMain:RemoveAllChildren();
	local sItem = customUserControl.new(joinPanelMain, 'unionBattleSacrificeItemTemplate');
	sItem.initWithInfo(msg.main_pos, 0);
	-- minor role
	local sItem1 = customUserControl.new(joinPanelMinor[1], 'unionBattleSacrificeItemTemplate');
	sItem1.initWithInfo(msg.pos_1, 1);
	local sItem2 = customUserControl.new(joinPanelMinor[2], 'unionBattleSacrificeItemTemplate');
	sItem2.initWithInfo(msg.pos_2, 2);
	local sItem3 = customUserControl.new(joinPanelMinor[3], 'unionBattleSacrificeItemTemplate');
	if msg.is_pos_3_open then
		sItem3.initWithInfo(msg.pos_3, 3);
	else
		sItem3.initWithInfo({},3,true);
	end
	saJoinPanel.Visibility = Visibility.Visible;
end

function UnionBuZhenPanel:closeSacificeInfo()
	saJoinPanel.Visibility = Visibility.Hidden;
end

function UnionBuZhenPanel:reqUpTeam()
	local msg = {}
	msg.building_id = self.buildingId;
	msg.building_pos = roundPos;
	msg.fp = math.floor(self.selfFp);
	msg.team_info    = UnionBattle:getUnionBattleTeamPidList();
	Network:Send(NetworkCmdType.req_union_battle_defence_pos_on, msg)
end

function UnionBuZhenPanel:retUpTeam(msg)
	local pos = self.buildingId*100+roundPos
	UnionBattlePanel.selfBuidingInfo[''..pos] = {}
	UnionBattlePanel.selfBuidingInfo[''..pos].tid = -1;
	UnionBattlePanel.selfBuidingInfo[''..pos].name = ''
	local pidList = UnionBattle:getUnionBattleTeamPidList();
	for k,v in pairs(pidList) do
		if v>=0 then
			UnionBattlePanel.selfBuidingInfo[''..pos]['pid'..k] = v
		else
			UnionBattlePanel.selfBuidingInfo[''..pos]['pid'..k] = -1
		end
	end
	UnionBattlePanel.selfBuidingInfo[''..pos].is_default = -1
	UnionBattlePanel.buzhenCount = UnionBattlePanel.buzhenCount + 1
	self:InitItem(roundPos,true,false,true)
	UnionBattleSelectActorPanel:onClose()
end

-- 献祭
function UnionBuZhenPanel:reqSacrificeTeam(teamData)
	local msg = {};
	msg.building_id = self.buildingId;
	msg.building_pos = roundPos;
	msg.team_info    = teamData;
	Network:Send(NetworkCmdType.req_guild_battle_sacrifice_begin_t, msg)
end

function UnionBuZhenPanel:retSacrificeTeam()
	self:InitItem(roundPos,defence_info[tostring(roundPos)], GBState.sacrificing);
	UnionBattleSelectActorPanel:onClose()
end

-- 加入
function UnionBuZhenPanel:newMinor(args)
	local arg = UIControlEventArgs(args);
	local id = arg.m_pControl.Tag;
	if id >=1 and id <= 3 then
		UnionBattleSelectActorPanel:onShow(4, fp*0.8);
	end
end

--取消上阵
function UnionBuZhenPanel:evacuateOnClick(args)
	local arg = UIControlEventArgs(args);
	local id = arg.m_pControl.Tag;
	local uid = arg.m_pControl.TagExt
	roundPos = id
	self:reqDownteam(id,uid)
end

function UnionBuZhenPanel:reqDownteam(id,uid)
	local msg = {}
	msg.building_id = self.buildingId;
	msg.building_pos = roundPos;
	if uid == ActorManager.user_data.uid then --自己
		Network:Send(NetworkCmdType.req_union_battle_defence_pos_off,msg)
	elseif ActorManager.user_data.unionPos > 0 then --社长或干部
		Network:Send(NetworkCmdType.req_union_battle_cancel_other_pos,msg)
	else
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_union_battle_2);
	end
end

function UnionBuZhenPanel:retDownteam(msg)
	UnionBattlePanel.selfBuidingInfo[''..(self.buildingId*100+roundPos)] = nil
	UnionBattlePanel.buzhenCount = UnionBattlePanel.buzhenCount -1
	self:InitItem(roundPos);
end

--社长取消社员上阵返回
function UnionBuZhenPanel:retDownTeamByProp(msg)
	--UnionBattlePanel.buzhenCount = UnionBattlePanel.buzhenCount -1
	self:InitItem(roundPos);
end
--我方建筑队伍布阵情况
function UnionBuZhenPanel:battleBuildingInfo(msg)
	if msg.defence_info then
		self:freshLeftPanel()
		self:freshStack(msg.defence_info)
		MainUI:Push(self)
	end
end
--敌方建筑队伍布阵情况
function UnionBuZhenPanel:battleBuildingInfoFight(msg)
	if msg.defence_info and msg.defence_state then
		defence_info = msg.defence_info;
		defence_state = msg.defence_state;
		self:freshLeftPanel()
		self:freshOtherStack()
		MainUI:Push(self)
	end

end
--建筑升级
function UnionBuZhenPanel:buildingLevelUpClick()
	if self.buildingLevel == 5 then
		return;
	end
	if ActorManager.user_data.money >= self.nextLevelMoney then
		local msg = {}
		msg.building_id = self.buildingId
		msg.old_level = self.buildingLevel
		Network:Send(NetworkCmdType.req_union_battle_building_level_up,msg)
	else
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_union_battle_8);
	end
end
function UnionBuZhenPanel:buildingLevelUp(msg)
	self:freshLeftPanel(msg.new_level)
end
--实时更新建筑某队伍状态
function UnionBuZhenPanel:fightStateSwitch(msg)
	if msg.building_id == self.buildingId and
		UnionBattlePanel.unionSideFlage == 2  and MainUI:IsHaveMenu(self) then
		local buildingId = msg.building_id
		local nowState = msg.new_state
		local nowPos = msg.building_pos
		for k,v in pairs(defence_state) do
			if defence_state[k] == 4 then
				defence_state[k] = 0;
			end
			if defence_state[k] == 5 then
				defence_state[k] = 1;
			end
		end
		defence_state[tostring(nowPos)] = nowState
		self:freshItem()
	end
end
--没用到
function UnionBuZhenPanel:fightEndFreshItem(is_win)
	for k,v in pairs(defence_state) do
		if defence_state[k] == 4 then
			defence_state[k] = 0;
		end
		if defence_state[k] == 5 then
			defence_state[k] = 1;
		end
	end
	if is_win then
		defence_state[''..roundPos] = 3
	else
		defence_state[''..roundPos] = 1
	end
	self:freshItem()
end
function UnionBuZhenPanel:Show()
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		topPanel:SetScale(factor,factor)
		leftPanel:SetScale(factor,factor)
		leftPanel.Translate = Vector2(289*(factor-1)/2,496*(factor-1)/2)
		touchScroll:SetScale(factor,factor)
		touchScroll.Translate = Vector2(640*(1-factor)/2,450*(factor-1)/2)
	end
	unionBuZhenPanel.Background = CreateTextureBrush('background/unionBattle_bg.jpg', 'background')
	mainDesktop:DoModal(unionBuZhenPanel);
	StoryBoard:ShowUIStoryBoard(unionBuZhenPanel, StoryBoardType.ShowUI1, nil, '');  
end


function UnionBuZhenPanel:Hide()
	StoryBoard:HideUIStoryBoard(unionBuZhenPanel, StoryBoardType.HideUI1, 'UnionBuZhenPanel:onDestroy');
end

function UnionBuZhenPanel:onDestroy()
	StoryBoard:OnPopUI();
end

function UnionBuZhenPanel:Destroy()
	unionBuZhenPanel:DecRefCount();
	unionBuZhenPanel = nil;
end

function UnionBuZhenPanel:onReturn()
	if UnionBattlePanel.unionSideFlage == 1 then
		UnionBattlePanel:reqWholeDefenceInfo()
	else
		UnionBattlePanel:reqWholeDefenceInfoFight()
	end
	MainUI:Pop();
end


