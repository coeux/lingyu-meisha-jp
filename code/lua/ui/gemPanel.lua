--gemPanel.lua
--==================================================================================
--宝石镶嵌合成界面


GemPanel =
{
	gemPageFlag = true;
	gemPageList = {};
};

--变量
local curRole;
local curType;
local roleList;
local gemRightList;
local leftGem;
local leftNum;
local leftLvl;
local leftName;
local leftCount;
local rightGem;
local rightNum;
local rightLvl;
local rightCount;
local rightName;
local synResid;
local pagePanel;
local pageScrollPanel;
local pageItemStack;
local pageLeftBtn;
local pageRightBtn;
local pageNamePanel;
local nameLabel;
local pageListView;
local pageNum = 0;
local lastText = '';

local pageId;
local curPid;
--常量
local allNoHorcruxImage =               --当卡槽内没有魂器时候的图片
{
	[171] = 'gem/wugong_03.ccz', 
	[172] = 'gem/jigong_03.ccz',	
	[173] = 'gem/wufang_03.ccz', 
	[174] = 'gem/jifang_03.ccz', 
	[175] = 'gem/shegnming_03.ccz'
};
--控件
local mainDesktop;
local panel;
local imgBg;
local panelMos;
local panelSyn;
local panelSynNor;
local roleListPanel;
local typeList;
local centerPanel;
local centerImg;
local gemMosList;
local gemSynList;
local shandow;
local synInfo;
local explainBtn;
local changeGemNamePanel;
local namePanel;		  
local okBtn;			  
local cancelBtn;		  
local nameTextBox;
local ruleExplain; 
local explainLabel;
local explainBG;   		  
local pageBtnList = {};

local addInfoBtn
local addInfoPanel
local addInfoList
--初始化
function GemPanel:InitPanel(desktop)
	--变量
	curType = GemPrefix[1];
	curRole = nil;
	pageId = 1;
	--控件
	mainDesktop = desktop;
	panel = desktop:GetLogicChild('gemSystemPanel1');
	panel.Visibility = Visibility.Hidden;
	panel.ZOrder = PanelZOrder.gem;
	panel:IncRefCount();

	imgBg = panel:GetLogicChild('bg');
	panelMos = panel:GetLogicChild('gemMos');
	panelSyn = panel:GetLogicChild('gemSyn');
	panelSynNor = panel:GetLogicChild('gemSynNor');
	panel:GetLogicChild('btnReturn'):SubscribeScriptedEvent('Button::ClickEvent', 'GemPanel:onClose');
	centerPanel = panelMos:GetLogicChild('centerPanel');

	--roleListPanel = panelMos:GetLogicChild('huobanListClip'):GetLogicChild('huobanList');

	typeList = {};
	for i=1, 5 do 
		typeList[i] = centerPanel:GetLogicChild('buttonList'):GetLogicChild(tostring(i));
		typeList[i].Tag = i;
		typeList[i]:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'GemPanel:clickGemType');
	end

	centerImg = centerPanel:GetLogicChild('centerImg');

	gemMosList = {};
	for i=1, 5 do
		gemMosList[i] = {};
		gemMosList[i].name = centerPanel:GetLogicChild('gem_' .. i):GetLogicChild('name');
		gemMosList[i].gem = customUserControl.new(centerPanel:GetLogicChild('gem_' .. i):GetLogicChild('gem'), 'itemTemplate');
		gemMosList[i].debus = centerPanel:GetLogicChild('gem_' .. i):GetLogicChild('debus');
		gemMosList[i].inlay = centerPanel:GetLogicChild('gem_' .. i):GetLogicChild('inlay');

		gemMosList[i].debus.Tag = i;
		gemMosList[i].debus:SubscribeScriptedEvent('Button::ClickEvent', 'GemPanel:onDebus');
		gemMosList[i].inlay.Tag = i;
		gemMosList[i].inlay:SubscribeScriptedEvent('Button::ClickEvent', 'GemPanel:onInlay');

		gemMosList[i].default = centerPanel:GetLogicChild('gem_' .. i):GetLogicChild('gem'):GetLogicChild('defaultBg');
		gemMosList[i].default.Background = Converter.String2Brush("common.icon_bg");
		gemMosList[i].defaultImg = gemMosList[i].default:GetLogicChild('img');
	end

	centerPanel:GetLogicChild('allDebus'):SubscribeScriptedEvent('Button::ClickEvent', 'GemPanel:debusAll');
	centerPanel:GetLogicChild('allInlay'):SubscribeScriptedEvent('Button::ClickEvent', 'GemPanel:inlayAll');

	gemSynList = {};
	gemRightList = {};
	for i=1, 9 do
		gemSynList[i] = {};
		gemSynList[i].panel = panelSyn:GetLogicChild('panel' .. i);
		gemSynList[i].gem = customUserControl.new(gemSynList[i].panel:GetLogicChild('panel'), 'itemTemplate');
		gemSynList[i].name = gemSynList[i].panel:GetLogicChild('label');
		gemSynList[i].name.Visibility = Visibility.Visible;
		gemSynList[i].panel.Tag = 0;
		gemSynList[i].panel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'GemPanel:onClickSyn');
		gemRightList[i] = gemSynList[i].gem;
	end

	panelSyn:GetLogicChild('buy_gem'):SubscribeScriptedEvent('Button::ClickEvent', 'GemPanel:buyGem');
	panelSyn:GetLogicChild('fast_mos'):SubscribeScriptedEvent('Button::ClickEvent', 'GemPanel:synAll');


	--合成弹框
	panelSynNor.Visibility = Visibility.Hidden;
	panelSynNor:GetLogicChild('close'):SubscribeScriptedEvent('Button::ClickEvent', 'GemPanel:closeSynPanel');
	panelSynNor:GetLogicChild('btnSyn'):SubscribeScriptedEvent('Button::ClickEvent', 'GemPanel:synGem');
	leftGem = customUserControl.new(panelSynNor:GetLogicChild('iconLeft'), 'itemTemplate');
	leftName = panelSynNor:GetLogicChild('bottombg1'):GetLogicChild('label');
	leftLvl = panelSynNor:GetLogicChild('bottombg2'):GetLogicChild('label');
	leftNum = panelSynNor:GetLogicChild('bottombg3'):GetLogicChild('label');
	leftCount = panelSynNor:GetLogicChild('bottombg1'):GetLogicChild('count');

	rightGem = customUserControl.new(panelSynNor:GetLogicChild('iconRight'), 'itemTemplate');
	rightName = panelSynNor:GetLogicChild('bottombg4'):GetLogicChild('label');
	rightLvl = panelSynNor:GetLogicChild('bottombg5'):GetLogicChild('label');
	rightNum = panelSynNor:GetLogicChild('bottombg6'):GetLogicChild('label');
	rightCount = panelSynNor:GetLogicChild('bottombg4'):GetLogicChild('count');

	synInfo = panelSynNor:GetLogicChild('label');
	shandow = panel:GetLogicChild('shadow');
	shandow.Visibility = Visibility.Hidden;

	-- 魂器属性总览
	addInfoBtn = panel:GetLogicChild('gemMos'):GetLogicChild('addInfoBtn');
	addInfoBtn:SubscribeScriptedEvent('Button::ClickEvent','GemPanel:addInfoShow');
	addInfoPanel = panel:GetLogicChild('addInfoPanel');
	addInfoPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent','GemPanel:explainHide')
	addInfoList = addInfoPanel:GetLogicChild('content'):GetLogicChild('addInfoList');
	addInfoLabel = addInfoPanel:GetLogicChild('addInfoLabel');
	
	if self.gemPageFlag then
		--宝石页
		pagePanel = panelMos:GetLogicChild('pagePanel');
		pageList  = panelMos:GetLogicChild('page');
		
		for i = 1 , 5 do
			local Rbtn = pageList:GetLogicChild('pageRbtn'..i);
			Rbtn.Tag = 6 - i;
			Rbtn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'GemPanel:onPageRadioChange')
			table.insert(pageBtnList,Rbtn);
		end
		
		--魂器说明
		explainBtn = panel:GetLogicChild('illustrate');
		explainBtn:SubscribeScriptedEvent('Button::ClickEvent','GemPanel:explainShow');
		ruleExplain  = panel:GetLogicChild('ruleExplain');
		ruleExplain:SubscribeScriptedEvent('UIControl::MouseClickEvent','GemPanel:explainHide')
		explainLabel = ruleExplain:GetLogicChild('content'):GetLogicChild('explainLabel');
		explainBG    = panel:GetLogicChild('explainBG');
		explainBG:SubscribeScriptedEvent('UIControl::MouseClickEvent','GemPanel:explainHide')
		explainLabel.Text = LANG_gemPaenl_explain
	end
end

function GemPanel:explainShow()
	ruleExplain.Visibility = Visibility.Visible
	explainBG.Visibility = Visibility.Visible
end

function GemPanel:addInfoShow()
	addInfoPanel.Visibility = Visibility.Visible
	explainBG.Visibility = Visibility.Visible
end

function GemPanel:explainHide()
	ruleExplain.Visibility = Visibility.Hidden
	explainBG.Visibility = Visibility.Hidden
	addInfoPanel.Visibility = Visibility.Hidden
end

function GemPanel:onPageRadioChange(Args)
	--print('onPageRadioChange--->')
	local args = UIControlEventArgs(Args);
	pageId = args.m_pControl.Tag;
	self:refreshGemType();
	self:addInfoListPanel()
end
--销毁
function GemPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function GemPanel:Show1()
	centerImg.Image = GetPicture('gem/baoshi_03.ccz');
	panel.Visibility = Visibility.Visible;

	if PveLosePanel.isGuideGem then
		PlotPanel:changeContentPos(0, -30);
		PlotPanel:changeContentText(LANG_pve_lose_tip_3);
		PlotPanel:guideEquipShow()
	end
end

--隐藏
function GemPanel:Hide()
	panel.Visibility = Visibility.Hidden;
end
--
function GemPanel:Show()
	HomePanel:hideRolePanel();
	--初始化背景
	local resid = ActorManager:GetRole(curPid).resid;
	local path = resTableManager:GetValue(ResTable.navi_main, tostring(resid), 'bg_path');
	imgBg.Background = CreateTextureBrush('navi/' .. path .. '.jpg', 'navi');
	pageBtnList[1].Selected = true;
	--设置当前选中gem类型
	typeList[1].Selected = true;
	--初始化选中gem时，对应的镶嵌内容以及右侧应该显示的宝石
	self:refreshGemType();
	self:addInfoListPanel()
	centerImg.Image = GetPicture('gem/baoshi_03.ccz');
	panel.Visibility = Visibility.Visible;

	if PveLosePanel.isGuideGem then
		PlotPanel:changeContentPos(0, -30);
		PlotPanel:changeContentText(LANG_pve_lose_tip_3);
		PlotPanel:guideEquipShow()
	end
end
function GemPanel:onShow(pid)
	HomePanel:destroyRoleSound()
	curPid = pid or 0;
	--Network:Send(NetworkCmdType.req_gem_page_t,{})
	self:Show();
end
--显示
function GemPanel:onShow1(pid)
	pid = pid or 0;
	HomePanel:destroyRoleSound()
	--初始化背景
	local resid = ActorManager:GetRole(pid).resid;
	local path = resTableManager:GetValue(ResTable.navi_main, tostring(resid), 'bg_path');
	imgBg.Background = CreateTextureBrush('navi/' .. path .. '.jpg', 'navi');

	--初始化人物列表
	self:initRoleList();
	--设置当前选中角色
	roleList[pid].setSelected();
	--初始化当前角色的gem列表
	self:initRoleGemList();
	--设置当前选中gem类型
	typeList[1].Selected = true;
	--初始化选中gem时，对应的镶嵌内容以及右侧应该显示的宝石
	self:refreshGemType();
	self:addInfoListPanel()
	
	self:Show();
end

--关闭
function GemPanel:onClose()
	self:Hide();
	if HomePanel:returnVisble() then
		HomePanel:turnPageChange();
		HomePanel:showRolePanel();
	end
	--if UserGuidePanel:IsInGuidence(UserGuideIndex.task11, 3) then
	--	UserGuidePanel:ReqWriteGuidence(UserGuideIndex.task11);
	--end
end

--初始化人物列表
function GemPanel:initRoleList()
	--创建头像列表
	roleListPanel:RemoveAllChildren();
	roleList = {};

	local pid = 0;
	local mainHero = customUserControl.new(roleListPanel, 'gemSystemInfoTemplate');
	mainHero.initWithPid(0);
	roleList[pid] = mainHero;

	local fp_arrange_list = {};
	for _, role in pairs(ActorManager.user_data.partners) do
		table.insert(fp_arrange_list, {pid = role.pid, resid = role.resid, fp = role.pro.fp});
	end

	table.sort(fp_arrange_list,
	function(a,b)
		return a.fp > b. fp;
	end)

	for _, role in pairs(fp_arrange_list) do
		local pid = role.pid;
		local role = customUserControl.new(roleListPanel, 'gemSystemInfoTemplate');
		role.initWithPid(pid);
		roleList[pid] = role;
	end
end

--控件点击角色
function GemPanel:onRoleClick(Args)
	local args = UIControlEventArgs(Args);
	self:setCurRole(args.m_pControl.Tag);
	self:refreshGemType();
	self:addInfoListPanel()
end

--设置当前选中角色
function GemPanel:setCurRole(pid)
	curRole = ActorManager:GetRole(pid);
end

--初始化当前角色的gem列表
function GemPanel:initRoleGemList()
end

--控件点击 魂器属性选择
function GemPanel:clickGemType(Args)
	local args = UIControlEventArgs(Args);
	self:setGemType(GemPrefix[args.m_pControl.Tag]);
	self:refreshGemType();
	self:addInfoListPanel()
	--if UserGuidePanel:IsInGuidence(UserGuideIndex.task11, 3) then
	--	UserGuidePanel:ShowGuideShade(gemMosList[1].inlay,GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	--end
end

--设置当前宝石属性
function GemPanel:setGemType(type_gem)
	curType = type_gem;
end

--根据当前选中类型和角色 决定对应的镶嵌内容以及右侧应该显示的宝石
function GemPanel:refreshGemType()
	local gemInfo = self.gemPageList[tostring(pageId)];
	if gemInfo then
		for i=1, 5 do
			local gemSlot = curType *100* 10 + i;
			--print('freshGem->'..tostring(gemInfo.slot_map[tostring(gemSlot)]))
			if gemInfo.slot_map[tostring(gemSlot)] and gemInfo.slot_map[tostring(gemSlot)] > 0 then
				local itemName = resTableManager:GetValue(ResTable.item, tostring(gemInfo.slot_map[tostring(gemSlot)]), 'name');
				gemMosList[i].name.Text = tostring(itemName);
				gemMosList[i].gem.initWithInfo(gemInfo.slot_map[tostring(gemSlot)],-1,75,false);
				gemMosList[i].gem:Show();
				gemMosList[i].debus.Visibility = Visibility.Visible;
				gemMosList[i].inlay.Visibility = Visibility.Hidden;
				gemMosList[i].default.Visibility = Visibility.Hidden;
			else
				gemMosList[i].name.Text = '';
				gemMosList[i].gem:Hide();
				gemMosList[i].debus.Visibility = Visibility.Hidden;
				gemMosList[i].inlay.Visibility = Visibility.Visible;
				gemMosList[i].default.Visibility = Visibility.Visible;
				gemMosList[i].defaultImg.Image = GetPicture(allNoHorcruxImage[curType]);
			end
		end
	end
	local curSlot = 1;
	local curLevel = 9;
	while(curSlot <= 9) do
		if curLevel == 0 then
			gemSynList[curSlot].panel.Tag = 0;
			gemSynList[curSlot].gem:Hide();
			gemSynList[curSlot].name.Text = '';
			curSlot = curSlot + 1;
		else
			local resid = curType * 100 + curLevel;
			--获取宝石个数
			local gemItem = Package:GetGemStone(tonumber(resid));
			local gemNum = gemItem and gemItem.num or 0;
			if gemNum > 0 then
				gemSynList[curSlot].gem:Show();
				local itemName = resTableManager:GetValue(ResTable.item, tostring(resid), 'name');
				gemSynList[curSlot].name.Text = tostring(itemName);
				gemSynList[curSlot].gem.initWithInfo(resid,gemNum,60,false);
				gemSynList[curSlot].panel.Tag = resid;
				curLevel = curLevel - 1;
				curSlot = curSlot + 1;
			else
				curLevel = curLevel - 1;
			end
		end
	end
	--[[
	--当前镶嵌内容
	local mos_equip = curRole.equips[tostring(curType)];
	for i=1, 5 do
		resid = mos_equip.gresids[i];			
		if resid and resid > 0 then
			local itemName = resTableManager:GetValue(ResTable.item, tostring(resid), 'name');
			gemMosList[i].name.Text = tostring(itemName);
			gemMosList[i].gem.initWithInfo(resid,-1,65,false);
			gemMosList[i].gem:Show();
			gemMosList[i].debus.Visibility = Visibility.Visible;
			gemMosList[i].inlay.Visibility = Visibility.Hidden;
			gemMosList[i].default.Visibility = Visibility.Hidden;
		else
			gemMosList[i].name.Text = '';
			gemMosList[i].gem:Hide();
			gemMosList[i].debus.Visibility = Visibility.Hidden;
			gemMosList[i].inlay.Visibility = Visibility.Visible;
			gemMosList[i].default.Visibility = Visibility.Visible;
			gemMosList[i].defaultImg.Image = GetPicture(allNoHorcruxImage[curType]);
		end
	end

	--右侧显示宝石
	local curSlot = 1;
	local curLevel = 9;
	while(curSlot <= 9) do
		if curLevel == 0 then
			gemSynList[curSlot].panel.Tag = 0;
			gemSynList[curSlot].gem:Hide();
			gemSynList[curSlot].name.Text = '';
			curSlot = curSlot + 1;
		else
			local resid = GemPrefix[curType] * 100 + curLevel;
			--获取宝石个数
			local gemItem = Package:GetGemStone(tonumber(resid));
			local gemNum = gemItem and gemItem.num or 0;
			if gemNum > 0 then
				gemSynList[curSlot].gem:Show();
				local itemName = resTableManager:GetValue(ResTable.item, tostring(resid), 'name');
				gemSynList[curSlot].name.Text = tostring(itemName);
				gemSynList[curSlot].gem.initWithInfo(resid,gemNum,60,false);
				gemSynList[curSlot].panel.Tag = resid;
				curLevel = curLevel - 1;
				curSlot = curSlot + 1;
			else
				curLevel = curLevel - 1;
			end
		end
	end
	]]
end
function GemPanel:retGemPage(msg)

	self.gemPageList = msg.gem_page_map;
	--self:totleFp()
end
function GemPanel:totleFp()
	local gFp = self:gemFp(GemPanel:defaultTeamNum())
	--print('gemFp----->'..tostring(gFp))
	local teamFp = MutipleTeam:GetDefaultTeamFp()
	--print('teamFp----->'..tostring(teamFp))
	ActorManager.user_data.fp = gFp + teamFp
	RolePortraitPanel:updateBind()
end
function GemPanel:defaultTeamNum()
	--print(debug.traceback())
	local teamId = MutipleTeam:getDefault()
	team = MutipleTeam:getTeam(teamId)
	local heroNum = 0
	for i=5,1,-1 do
		if team[i] >= 0 then
			heroNum = heroNum + 1
		end
	end
	return heroNum;
end

function GemPanel:reCalculateFp(role, pos, factor_)
	local factor = {};
	if factor_ then
		factor[1] = factor_['atk'];
		factor[2] = factor_['mgc'];
		factor[3] = factor_['def'];
		factor[4] = factor_['res'];
		factor[5] = factor_['hp'];
	else
		for i=1, 5 do
			factor[i] = 1;
		end
	end
	role.pos = pos;
	local fp=0;
	local proList=self:reCaluclatePro(role, pos, 1, factor);
	fp = fp + proList[1]*1.1 + proList[2]*1 + proList[3]*1.2 + proList[4]*1 + proList[5]*0.3 + role.lvl.level*20;
	local cal_skill_fp = function(resid, level)
		local data = resTableManager:GetRowValue(ResTable.skill, tostring(resid));
		if data ~= nil then
			if data['next_skill'] == 0 then
				return level*6;
			else
				return level*4;
			end
		end
		local pdata = resTableManager:GetRowValue(ResTable.passiveSkill, tostring(resid));
		if data ~= nil then
			if data['next_skill'] == 0 then
				return level*6;
			else
				return level*4;
			end
		end
		return 0;
	end
	for _,skill in ipairs(role.skls) do
		fp = fp + cal_skill_fp(skill.resid, skill.level);
	end
	return fp*0.9;
end

function GemPanel:reCaluclatePro(role, pos, factor, factorList_)
	local factorList = {};
	if factorList_ then
		for i=1, 5 do
			factorList[i] = factorList_[i];
		end
	else
		for i=1, 5 do
			factorList[i] = 1;
		end
	end
	local getVipPlus = function(vip)
		if vip>=12 and vip<=13 then
			return 1.03;
		elseif vip>=14 and vip<=16 then
			return 1.06;
		elseif vip>= 17 then
			return 1.09;
		else
			return 1;
		end			
	end
	local getRankPlus = function(resid, qulv, type_id)
		local properinfo = {'rankup_atk', 'rankup_mgc', 'rankup_def', 'rankup_res', 'rankup_hp'};
		local info = resTableManager:GetValue(ResTable.qualityup_attribute, tostring(resid * 100 + qulv), properinfo[type_id]);
		return info+1;
	end
	local getLovePlus = function(resid, love_level, type_id)
		if love_level < 1 then
			return 1;
		end
		local properinfo = {'atk', 'mgc', 'def', 'res', 'hp'};
		local love_task_id = resid*100+love_level;
		local taskData = resTableManager:GetRowValue(ResTable.love_task, tostring(love_task_id));
		local info = resTableManager:GetValue(ResTable.love_reward, tostring(taskData['love_reward_id']), properinfo[type_id]);
		return info+1;
	end

	local proList = {};
	local minus = false;
	if (MutipleTeam:isInDefaultTeam(role.pid)) then
		minus = true;
	end
	local vip_add = getVipPlus(ActorManager.user_data.viplevel);
	local rank_add={};
	local love_add={};
	for i = 1, 5 do
		if role.rank == nil then 
			role.rank = 1;
		end
		rank_add[i] = getRankPlus(role.resid, role.rank, i);
		love_add[i] = getLovePlus(role.resid, role.lvl.lovelevel, i);
	end
	local ori_pos = minus and MutipleTeam:getRolePos(role.pid) or 1;
	local oriList = {};
	oriList[1] = role.pro.atk;
	oriList[2] = role.pro.mgc;
	oriList[3] = role.pro.def;
	oriList[4] = role.pro.res;
	oriList[5] = role.pro.hp;
	for i=1, 5 do
		proList[i] = (oriList[i]/vip_add/rank_add[i]/love_add[i] + (minus and (0 - self:getAttribute(ori_pos, i)) or 0) + self:getAttribute(pos, i)*factor) * vip_add * rank_add[i] * love_add[i] * factorList[i];
	end
	return proList;
end
--local teamId = MutipleTeam:getDefault()
--team = MutipleTeam:getTeam(teamId)
function GemPanel:getAttribute(pos, type_id)
	local page_id = pos
	local sum=0;
	local gemInfo = GemPanel.gemPageList[tostring(page_id)];
	if gemInfo == nil then
		return 0;
	end
	for i=1, 5 do
		if gemInfo.slot_map[tostring(GemPrefix[type_id] *100* 10 + i)] > 0 then
			local rId = gemInfo.slot_map[tostring(GemPrefix[type_id] *100* 10 + i)];
			local gem = resTableManager:GetRowValue(ResTable.gemstone, tostring(rId));
			sum = sum + gem['value'];
		end
	end
	return sum;
end
function GemPanel:gemFp(role_list)
	local gemPhysicalAttack = 0;
	local gemMagicAttack	= 0;
	local gemPhysicalDefence= 0;
	local gemMagicDefence	= 0;
	local gemMaxHP			= 0;
	for k = 1, 5 do
		if role_list[k] == 1 then
--	for k = 1, roleNum do
		local gemInfo = GemPanel.gemPageList[tostring(k)];
		for i = 1 , 5 do
			for j = 1 , 5 do
				if gemInfo.slot_map[tostring(GemPrefix[i] *100* 10 + j)] and gemInfo.slot_map[tostring(GemPrefix[i] *100* 10 + j)] > 0 then
					local rId = gemInfo.slot_map[tostring(GemPrefix[i] *100* 10 + j)];
					local gem = resTableManager:GetRowValue(ResTable.gemstone, tostring(rId));
					if gem['attribute'] == 1 then
						gemPhysicalAttack = gemPhysicalAttack + gem['value']
					elseif gem['attribute'] == 2 then
						gemMagicAttack = gemMagicAttack + gem['value']
					elseif gem['attribute'] == 3 then
						gemPhysicalDefence = gemPhysicalDefence + gem['value']
					elseif gem['attribute'] == 4 then
						gemMagicDefence = gemMagicDefence + gem['value']
					else
						gemMaxHP = gemMaxHP + gem['value']
					end
				end
			end
		end
	end
	end
	return gemPhysicalAttack+gemMagicAttack+gemPhysicalDefence+gemMagicDefence+gemMaxHP;
end
--点击宝石进行合成
function GemPanel:onClickSyn(Args)
	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;
	if tag == 0 then
		return;
	end

	self:openSynPanel(tag);
end

--卸下
function GemPanel:onDebus(Args)
	if not Args then
		return;
	end
	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;
	--local mos_equip = curRole.equips[tostring(curType)];
	local gemInfo = self.gemPageList[tostring(pageId)];
	local gemSlot = curType *100* 10 + tag;
	if gemInfo.slot_map[tostring(gemSlot)] then
		local msg = {};
		msg.pageid = pageId;
		msg.resid = gemInfo.slot_map[tostring(gemSlot)];
		msg.slotid = gemSlot;
		msg.flag = 2;				            --卸下宝石
		Network:Send(NetworkCmdType.req_gemstone_inlay, msg);
	end
end

--镶嵌
function GemPanel:onInlay(Args)
	if not Args then
		return;
	end
	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;
	--local mos_equip = curRole.equips[tostring(curType)];
	if gemSynList[1].panel.Tag > 0 then
		local msg = {};
		msg.pageid = pageId;
		msg.resid = gemSynList[1].panel.Tag;    
		msg.slotid = curType*100*10+tag;
		msg.flag = 1;				--装上宝石
		--print('onInlay-pageId->'..tostring(msg.pageid)..' -resid->'..tostring(msg.resid)..' -slotId->'..tostring(msg.slotid))
		Network:Send(NetworkCmdType.req_gemstone_inlay, msg);	
	else
		Toast:MakeToast(Toast.TimeLength_Long, '对应宝石的数量不足: 请到商店购买');
	end
end

--一键卸下
function GemPanel:debusAll()
	local msg = {};
	msg.eg = {};
	msg.flag = 2;
	local gemInfo = self.gemPageList[tostring(pageId)];
	--local gemSlot = curType * 10 + i;
	for i=1, 5 do
		msg.eg[i] = {};
		for j=1, 5 do
			msg.eg[i][j] = gemInfo.slot_map[tostring(GemPrefix[i]*100*10+j)] --测试
			--msg.eg[i][j] = curRole.equips[tostring(i)].gresids[j];
		end
		--msg.eg[i][6] = curRole.equips[tostring(i)].eid;
		msg.eg[i][6] = pageId;
	end
	Network:Send(NetworkCmdType.req_gemstone_inlay_all, msg);
end

--一键镶嵌
function GemPanel:inlayAll()
	local msg = {};
	msg.eg = {};
	msg.flag = 1;
	local curLevel;
	local resid;
	local gemGetNum;
	local gemInfo = self.gemPageList[tostring(pageId)];
	--local gemSlot = curType * 10 + i;
	for i=1, 5 do
		msg.eg[i] = {};
		curLevel = 9;
		gemGetNum = 0;
		for j=1, 5 do
			if gemInfo.slot_map[tostring(GemPrefix[i]*100* 10 + j)] == 0 then
				local findGem = false;
				while(not findGem) do
					if curLevel == 0 then
						findGem = true;
						resid = 0;
						break;
					end
					resid = GemPrefix[i] * 100 + curLevel;
					local gemItem = Package:GetGemStone(tonumber(resid));
					local gemNum = gemItem and gemItem.num or 0;
					if gemNum > gemGetNum then
						findGem = true;
						gemGetNum = gemGetNum + 1;
					else
						curLevel = curLevel - 1;
						gemGetNum = 0;
					end
				end
				msg.eg[i][j] = resid;
			else
				msg.eg[i][j] = 0;
			end
		end
		msg.eg[i][6] = pageId;
	end
	Network:Send(NetworkCmdType.req_gemstone_inlay_all, msg);
--[[
	local msg = {};
	msg.eg = {};
	msg.flag = 1;
	local curLevel;
	local resid;
	local gemGetNum;
	for i=1, 5 do
		msg.eg[i] = {};
		curLevel = 9;
		gemGetNum = 0;
		for j=1, 5 do
			if curRole.equips[tostring(i)].gresids[j] == 0 then
				local findGem = false;
				while(not findGem) do
					if curLevel == 0 then
						findGem = true;
						resid = 0;
						break;
					end
					resid = GemPrefix[i] * 100 + curLevel;
					local gemItem = Package:GetGemStone(tonumber(resid));
					local gemNum = gemItem and gemItem.num or 0;
					if gemNum > gemGetNum then
						findGem = true;
						gemGetNum = gemGetNum + 1;
					else
						curLevel = curLevel - 1;
						gemGetNum = 0;
					end
				end
				msg.eg[i][j] = resid;
			else
				msg.eg[i][j] = 0;
			end
		end
		msg.eg[i][6] = pageId;
	end
	Network:Send(NetworkCmdType.req_gemstone_inlay_all, msg);
	]]
end

--一键镶嵌/卸下回调
function GemPanel:mosAllCallback(msg)
	local gemInfo = self.gemPageList[tostring(pageId)];
	if 1 == msg.flag then
		for i=1, 5 do
			local resid = 0;
			local totleValue = 0;
			for j=1, 5 do
				if (gemInfo.slot_map[tostring(GemPrefix[i] *100* 10 + j)] == 0) and (msg.eg[i][j] ~= 0) then
					gemInfo.slot_map[tostring(GemPrefix[i] *100* 10 + j)] = msg.eg[i][j];
					resid = tonumber(msg.eg[i][j]);
					local gem = resTableManager:GetRowValue(ResTable.gemstone, tostring(msg.eg[i][j]));
					if gem then
						totleValue = totleValue + gem['value'];
					end
				end
			end
			if reisd ~= 0 then
				local id = resid % 1000;
				local gemType = math.floor(id / 100);
				ToastMove:CreateToast(GemWord[gemType] .. ' +'..totleValue);
			end
		end
	else
		for i=1, 5 do
			for j=1, 5 do
				gemInfo.slot_map[tostring(GemPrefix[i] *100* 10 + j)] = 0;
			end
		end
	end	
	--[[
	if 1 == msg.flag then
		for i=1, 5 do
			for j=1, 5 do
				if (curRole.equips[tostring(i)].gresids[j] == 0) and (msg.eg[i][j] ~= 0) then
					curRole.equips[tostring(i)].gresids[j] = msg.eg[i][j];
				end
			end
		end
	else
		for i=1, 5 do
			for j=1, 5 do
				curRole.equips[tostring(i)].gresids[j] = 0;
			end
		end
	end	
	]]
	--刷新宝石镶嵌界面
	self:refreshGemType();
	self:addInfoListPanel()
end

--一键合成
function GemPanel:synAll()
	local okDelegate = Delegate.new(GemPanel, GemPanel.sureSynAll);
	local cancelDelgate = Delegate.new(GemPanel, GemPanel.cancelSynAll);
	MessageBox:ShowDialog(MessageBoxType.OkCancel, LANG_gemPaenl_13, okDelegate, cancelDelgate);
end

--确认一键合成
function GemPanel:sureSynAll()
	local msg = {};
	msg.type_gem = curType;
	Network:Send(NetworkCmdType.req_gemstone_syn_all, msg);
end

--取消一键合成
function GemPanel:cancelSynAll()
end

--一键合成回调
function GemPanel:synAllCallBack()
	self:refreshGemType();
	self:addInfoListPanel()
end

--购买魂器
function GemPanel:buyGem()
	-- self:onClose();
	-- HomePanel:onClickBack();
	-- if(ShopPanel) then
	-- 	ShopPanel:OpenShop();    
	-- end
	ShopSetPanel:show(ShopSetType.gameShop)
end

--镶嵌/卸下回调
function GemPanel:mosCallback(msg)
	--print('mosCallback->')
	--print('slotId->'..tostring(msg.slotid)..' -resid->'..tostring(msg.resid))
	local gemInfo = self.gemPageList[tostring(pageId)];
	if 1 == msg.flag then
		gemInfo.slot_map[tostring( msg.slotid)] = msg.resid;
		local resid = tonumber(msg.resid);
		local gem = resTableManager:GetRowValue(ResTable.gemstone, tostring(msg.resid));
		if gem then
			local id = resid % 1000;
			local gemType = math.floor(id / 100);
			--print('gemType-->'..tostring(gemType));
			ToastMove:CreateToast(GemWord[gemType] .. ' +'..gem['value']);
		end
	else
		gemInfo.slot_map[tostring(msg.slotid)] = 0;	
	end	
	--[[
	if 1 == msg.flag then
		curRole.equips[tostring(curType)].gresids[msg.slotid] = msg.resid;	
	else
		curRole.equips[tostring(curType)].gresids[msg.slotid] = 0;	
	end	
	]]
	--刷新宝石镶嵌界面
	self:refreshGemType();
	self:addInfoListPanel()
	--if UserGuidePanel:IsInGuidence(UserGuideIndex.task11, 3) then
	--	UserGuidePanel:ShowGuideShade(panel:GetLogicChild('btnReturn'),GuideEffectType.hand,GuideTipPos.right,'', 0.3);
	--end
end
--================================================================================
--合成界面
function GemPanel:openSynPanel(resid)
	panelSynNor.Visibility = Visibility.Visible;
	shandow.Visibility = Visibility.Visible;
	
	synResid = resid;
	if (resid % 100) < 9 then
		rightGem:Show();
		panelSynNor:GetLogicChild('bottombg4').Visibility = Visibility.Visible;
		panelSynNor:GetLogicChild('bottombg5').Visibility = Visibility.Visible;
		panelSynNor:GetLogicChild('bottombg6').Visibility = Visibility.Visible;

		local leftInfo = resTableManager:GetRowValue(ResTable.item, tostring(resid));
		local leftgem = resTableManager:GetRowValue(ResTable.gemstone, tostring(resid));
		leftGem.initWithInfo(resid,-1,70,false);
		leftName.Text = tostring(leftInfo['description']);
		leftCount.Text = tostring("+" .. leftgem['value']);
		leftLvl.Text = tostring(resid % 100);
		local leftGemItem = Package:GetGemStone(tonumber(resid));
		local gemNum = leftGemItem and leftGemItem.num or 0;
		leftNum.Text = tostring(gemNum);
		panelSynNor:GetLogicChild('btnSyn').Enable = (math.floor(gemNum / 3) >= 1);

		local rightInfo = resTableManager:GetRowValue(ResTable.item, tostring(resid+1));
		local rightgem = resTableManager:GetRowValue(ResTable.gemstone, tostring(resid+1));
		rightGem.initWithInfo(resid+1,-1,70,false);
		rightName.Text = tostring(rightInfo['description']);
		rightCount.Text = tostring("+" .. rightgem['value']);
		rightLvl.Text = tostring((resid+1) % 100);
		local rightGemItem = Package:GetGemStone(tonumber(resid+1));
		gemNum = rightGemItem and rightGemItem.num or 0;
		rightNum.Text = tostring(gemNum);

		synInfo.Text = string.format(LANG_gemPaenl_11,tostring(resid % 100),tostring((resid+1) % 100))
	else
		rightGem:Hide();
		panelSynNor:GetLogicChild('bottombg4').Visibility = Visibility.Hidden;
		panelSynNor:GetLogicChild('bottombg5').Visibility = Visibility.Hidden;
		panelSynNor:GetLogicChild('bottombg6').Visibility = Visibility.Hidden;

		local leftInfo = resTableManager:GetRowValue(ResTable.item, tostring(resid));
		local leftgem = resTableManager:GetRowValue(ResTable.gemstone, tostring(resid));
		leftGem.initWithInfo(resid,-1,70,false);
		leftName.Text = tostring(leftInfo['description']);
		leftLvl.Text = tostring(resid % 100);
		leftCount.Text = tostring("+" .. leftgem['value']);
		local leftGemItem = Package:GetGemStone(tonumber(resid));
		local gemNum = leftGemItem and leftGemItem.num or 0;
		leftNum.Text = tostring(gemNum);
		panelSynNor:GetLogicChild('btnSyn').Enable = false;
		synInfo.Text = LANG_gemPaenl_12;
	end
end

function GemPanel:closeSynPanel()
	panelSynNor.Visibility = Visibility.Hidden;
	shandow.Visibility = Visibility.Hidden;
end

--合成
function GemPanel:synGem()
	local msg = {};
	msg.src_resid = synResid;
	msg.compose_num = 1;
	msg.safe = 0;
	Network:Send(NetworkCmdType.req_gemstone_compose, msg);
end

--合成回调
function GemPanel:synCallback(msg)
	self:refreshGemType();
	self:addInfoListPanel()
	self:closeSynPanel();
end

function GemPanel:isVisible()
	return panel.Visibility == Visibility.Visible;
end

function GemPanel:addInfoListPanel()
	local infoTypeList = {}
	local infoNumList = {}
	addInfoList:RemoveAllChildren();
	local gemIndex = {5,1,2,3,4}
	local allNum = 0
	for i = 1,5 do 
		local gemInfo = self.gemPageList[tostring(6-i)];
		local teamNum = 0
		infoTypeList = {}
		infoNumList = {}
		for j=1, #gemIndex do 
			if gemInfo then
				local singleNum = 0
				for k=1, 5 do 
					local gemSlot = (170+gemIndex[j]) *100* 10 + k;
					local gemId = gemInfo.slot_map[tostring(gemSlot)]
					local value = resTableManager:GetValue(ResTable.gemstone, tostring(gemId), 'value')
					if value ~= nil and value > 0 then
						singleNum = singleNum + value
					end
				end
				if singleNum > 0 then 
					table.insert(infoTypeList,j)
					table.insert(infoNumList,singleNum)
				end
				teamNum = teamNum + singleNum
			end
		end
		if teamNum > 0 then 
			-- if i > 1 then 
				addInfoList:AddChild(self:addInfoSingle(' '))
			-- end
			addInfoList:AddChild(self:addInfoSingle(LANG_GemPanel_new_1[i],1))
			for ii=1,#infoTypeList do
				local msg = LANG_GemPanel_new[infoTypeList[ii]]..'     '..infoNumList[ii]
				addInfoList:AddChild(self:addInfoSingle(msg))
			end
		end
		allNum = allNum + teamNum
	end
	if allNum == 0 then
		addInfoLabel.Visibility = Visibility.Visible
	else
		addInfoLabel.Visibility = Visibility.Hidden
	end
end

function GemPanel:addInfoSingle(info, fun)
	local label = uiSystem:CreateControl('Label')
	label.Horizontal = ControlLayout.H_CENTER
	label.Vertical = ControlLayout.V_CENTER
	label.Margin = Rect(0, 0, 0, 0)
	label.Size = Size(155, 30)
	label.Text = info
	if fun ~= nil then
		label.Font = uiSystem:FindFont('huakang_22_noborder_Big')
		label.TextAlignStyle = TextFormat.MiddleCenter
	else
		label.Font = uiSystem:FindFont('huakang_20miaobian_R38G19B0')
		label.TextAlignStyle = TextFormat.MiddleLeft
	end
	return label
end