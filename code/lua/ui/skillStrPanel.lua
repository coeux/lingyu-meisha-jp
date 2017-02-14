--skillStrPanel.lua
--========================================================================
--技能面板

SkillStrPanel =
	{
		curIndex = 0;
	};

--local 表
local skillEnum = 
{
	'active1',  --无用项
	'active2',	--无用项
	'active3',	--无用项
	'active1',
	'active2',
	'passive1',
	'passive2',
	'passive3',
}

--卡牌类型（反击起手攻击连击）
local skill_class_map = 
{
  [0] = 'skillup/skilltype2.ccz'; -- 攻击
  [1] = 'skillup/skilltype1.ccz'; -- 起手
  [2] = 'skillup/skilltype5.ccz'; -- 反击
  [3] = 'skillup/skilltype4.ccz'; -- 连击
  [4] = 'skillup/skilltype3.ccz'; -- 辅助
  [5] = 'skillup/skilltype6.ccz';	-- 被动
  [6] = 'skillup/skilltype7.ccz';	-- 追击
  [7] = 'skillup/skilltype6.ccz';	-- 天赋,暂时用被动图标
}
--变量

local pageIndex = 1;					--分页页数
local currentRoleSelected;				--当前人物编号
local selectedRole;						--当前选中的人物
local isShow;

--控件
local mainDesktop;
local skillStrPanel;
local centerPanel;
local roleName;
local cardRole;
local btnReturn;
local tabControl;
local strPanel;
local advPanel;
local skillStrList = {};					--升级控件列表
local skillAdvList = {};					--升阶控件列表
local imgBg;

local strStackPanel;
local strInfoPanel;
local skillInfoPanel;
local skillInfoNews;
local skillTipsPanel;
local skill;

local strMoney;
local advInfoPanel;
local advSkillPanel;
local advMaterial = {};

local effectAU = nil;
local playTimes = 1;
local skillUpSound
local curItemConsumeId;
--初始化面板
function SkillStrPanel:InitPanel( desktop )
	--变量初始化
	selectedRole = nil;
	pageIndex = 1;
	currentRoleSelected = ActorManager.user_data.role.resid;
	isShow = false;
	skillUpSound = nil
	curItemConsumeId = -1;
	--控件初始化
	mainDesktop = desktop;
	skillStrPanel = Panel(desktop:GetLogicChild('SkillPanel'));
	skillStrPanel.ZOrder = PanelZOrder.skill;
	skillStrPanel:IncRefCount();
	skillStrPanel.Visibility = Visibility.Hidden;
	skillStrPanel.ZOrder = 500;

	btnReturn = Button(skillStrPanel:GetLogicChild('returnBtn'));
	btnReturn:SubscribeScriptedEvent('Button::ClickEvent', 'SkillStrPanel:onClose');
	centerPanel = skillStrPanel:GetLogicChild('center');

	tabControl = centerPanel:GetLogicChild('tabControl');
	tabControl.ActiveTabPageIndex = 0;

	strPanel = tabControl:GetLogicChild('str');
	advPanel = tabControl:GetLogicChild('adv');

	strStackPanel = strPanel:GetLogicChild('strStackPanel');
	strInfoPanel = strPanel:GetLogicChild('strInfoPanel');
	skillInfoPanel = strInfoPanel:GetLogicChild('skillInfo');
	skillTipsPanel = strInfoPanel:GetLogicChild('skillTipsPanel');
	strMoney = strPanel:GetLogicChild('goldPanel'):GetLogicChild('num');

	advInfoPanel = advPanel:GetLogicChild('advInfoPanel');
	advSkillPanel = advInfoPanel:GetLogicChild('advSkillPanel');

	for i=1, 5 do
		local str = customUserControl.new(strPanel:GetLogicChild('strStackPanel'), 'HomeIconTemplate');
		local adv = customUserControl.new(advPanel:GetLogicChild('advStackPanel'), 'HomeIconTemplate');
		skillStrList[i] = str;
		skillAdvList[i] = adv;
	end
	self:bind()
	uiSystem:UpdateDataBind();
end

--销毁
function SkillStrPanel:Destroy()
	SkillStrPanel:unbind();
	skillStrPanel:DecRefCount();
	skillStrPanel = nil;
end

function SkillStrPanel:GetUserGuideTabBtn()
	return tabControl;
end

--显示
function SkillStrPanel:Show(enterRoleId)
	if not self:IsVisible() then
		HomePanel:destroyRoleSound()
	end
    if not HomePanel:returnVisble() then
       HomePanel:onEnterHomePanel(true)
    end
	if not HomePanel:rolePanelInfo() then HomePanel:ListClick() end
	if CardDetailPanel:isShow() then CardDetailPanel:onBack(); end
	tabControl.ActiveTabPageIndex = 0;
	currentRoleSelected = enterRoleId or ActorManager.user_data.role.resid;
	self:updateRole();
	self:RefreshSkill();

	isShow = true;
	skillInfoNews = skillStrList[1];
	SkillStrPanel:UpdateInfo();
	skillInfoNews.ctrl.Selected = true;
	skillStrPanel.Visibility = Visibility.Visible;
	self.curIndex = skillInfoNews.ctrl:GetLogicChild('btn').TagExt;
	if UserGuidePanel:IsInGuidence(UserGuideIndex.skillup, 2) then
		UserGuidePanel:ShowGuideShade(SkillStrPanel:GetUserGuideTabBtn(),GuideEffectType.hand,GuideTipPos.right,'');
	end
	effectAU = nil;

	--技能tips刷新
	SkillStrPanel:UpdateAdvSkill(selectedRole);
end

--隐藏
function SkillStrPanel:Hide()
	curItemConsumeId = -1;
	skillStrPanel.Visibility = Visibility.Hidden;
	if HomePanel:rolePanelInfo() then HomePanel:ListClick() end
	isShow = false;
end

--========================================================================
--功能函数
--========================================================================
--是否显示
function SkillStrPanel:IsVisible()
	return isShow;
end

--绑定数据
function SkillStrPanel:bind()
	uiSystem:Bind(DDXTYPE.DDX_INT, ActorManager.user_data, 'money', strMoney, 'Text');					--绑定金币
end

--取消绑定数据
function SkillStrPanel:unbind()
	uiSystem:UnBind(ActorManager.user_data, 'money', strMoney, 'Text');						--取消绑定金币
end
--========================================================================
--界面响应
--========================================================================
--关闭事件
function SkillStrPanel:onClose()
	self:destroySkillUpSound()
	HomePanel:RoleShow();
	CardDetailPanel:Show(selectedRole.pid, selectedRole.resid);
	self:Hide();
end

--分页改变
function SkillStrPanel:onPageChange(Args)
	local args = UITabControlPageChangeEventArgs(Args);
	pageIndex = args.m_pNewPage.Tag;

	if selectedRole then
		if 1 == pageIndex then
			skillInfoNews = skillStrList[self.curIndex];
			skillInfoNews.ctrl.Selected = true;
			SkillStrPanel:UpdateInfo();
		elseif 2 == pageIndex then
			skillInfoNews = skillAdvList[self.curIndex];
			skillInfoNews.ctrl.Selected = true;
			SkillStrPanel:UpdateAdvInfo();
			if UserGuidePanel:IsInGuidence(UserGuideIndex.skillup, 2) then
				UserGuidePanel:ReqWriteGuidence(UserGuideIndex.skillup, 2);
				--UserGuidePanel:ShowGuideShade(strInfoPanel:GetLogicChild('lvUpBtn'),GuideEffectType.hand,GuideTipPos.right,'');
			end
		end
	end
end

--升级技能
function SkillStrPanel:onStrength( Args )
	local arg = UIControlEventArgs(Args);
	local tag = arg.m_pControl.Tag;
	if selectedRole == nil then
		return;
	end

	local skill = selectedRole.skls[tag];
	if skill == nil then
		return;
	end

	local msg = {};
	msg.pid = selectedRole.pid;
	msg.skid = skill.skid;
	msg.num = 1;
	Network:Send(NetworkCmdType.req_upgrade_skill, msg);
	PlayEffectLT('qianghua_output/', Rect(strInfoPanel:GetLogicChild('item'):GetAbsTranslate().x + strInfoPanel:GetLogicChild('item').Width * 0.5, strInfoPanel:GetLogicChild('item'):GetAbsTranslate().y + strInfoPanel:GetLogicChild('item').Height * 0.3, 0, 0), 'qianghua', strInfoPanel:GetLogicChild('item'));
end

--自动强化
function SkillStrPanel:onStrengthTen( Args )
	local arg = UIControlEventArgs(Args);
	local tag = arg.m_pControl.Tag;
	if selectedRole == nil then
		return;
	end
	
	local skill = selectedRole.skls[tag];
	if skill == nil then
		return;
	end
	
	local count = 0;
	local cost = 0;
	for i = 1, selectedRole.lvl.level - skill.level do
		local discount = LovePanel:getGoldCostDecreased(selectedRole) or 1;
		cost = resTableManager:GetValue(ResTable.skill_upgrade, tostring(skill.level+i), 'btp') * discount + cost;
		if cost <= ActorManager.user_data.money then
			count = count + 1;
		else
			break;
		end
	end
	local msg = {};
	msg.pid = selectedRole.pid;
	msg.skid = skill.skid;
	msg.num = count;
	Network:Send(NetworkCmdType.req_upgrade_skill, msg);
	effectAU = PlayEffectLT('qianghua_output/', Rect(strInfoPanel:GetLogicChild('item'):GetAbsTranslate().x + strInfoPanel:GetLogicChild('item').Width * 0.5, strInfoPanel:GetLogicChild('item'):GetAbsTranslate().y + strInfoPanel:GetLogicChild('item').Height * 0.3, 0, 0), 'qianghua', strInfoPanel:GetLogicChild('item'));
	playTimes = 3;
	effectAU:SetScriptAnimationCallback('SkillStrPanel:replay',0);
end

--重复播放特效
function SkillStrPanel:replay()
	if playTimes == 1 then
		return;
	end
	effectAU = PlayEffectLT('qianghua_output/', Rect(strInfoPanel:GetLogicChild('item'):GetAbsTranslate().x + strInfoPanel:GetLogicChild('item').Width * 0.5, strInfoPanel:GetLogicChild('item'):GetAbsTranslate().y + strInfoPanel:GetLogicChild('item').Height * 0.3, 0, 0), 'qianghua', strInfoPanel:GetLogicChild('item'));
	playTimes = playTimes - 1;
	effectAU:SetScriptAnimationCallback('SkillStrPanel:replay',0);
end

--升阶技能
function SkillStrPanel:onAdvance( Args )
	local arg = UIControlEventArgs(Args);
	local tag = arg.m_pControl.Tag;
	if selectedRole == nil then
		return;
	end

	local skill = selectedRole.skls[tag];
	if skill == nil then
		return;
	end

	local msg = {};
	msg.pid = selectedRole.pid;
	msg.skid = skill.skid;
	Network:Send(NetworkCmdType.req_upnext_skill, msg);
end

--更新角色
function SkillStrPanel:updateRole()
	selectedRole = ActorManager:GetRoleFromResid(currentRoleSelected);
	if not selectedRole then
		selectedRole = ResTable:createRoleNoHave(currentRoleSelected);
	end
end

--更新技能s
function SkillStrPanel:RefreshSkill()
	local index = 1;
	for i=1, 8 do
		skill = selectedRole.skls[i];
		if skill.resid ~= 0 then
			skillStrList[index].initSkill (skill, selectedRole, index, i, 1);
			skillStrList[index].initWithBtnClick(HomeTemplateType.Skillup);
			skillAdvList[index].initSkill(skill, selectedRole, index, i, 2);
			skillAdvList[index].initWithBtnClick(HomeTemplateType.Skilladv);
			index = index + 1;
		end
	end
end

--更新技能升级信息
function SkillStrPanel:UpdateInfo(args)
	local skillresid;
	if not args then
		skillresid = skillInfoNews.ctrl:GetLogicChild('btn').Tag;
	else
		skillresid = args.m_pControl.Tag;
		skillInfoNews = skillStrList[args.m_pControl.TagExt];
	end
	self.curIndex = skillInfoNews.ctrl:GetLogicChild('btn').TagExt;
	local skillArray = resTableManager:GetRowValue(ResTable.skill, tostring(skillresid));
	if not skillArray then
		skillArray = resTableManager:GetRowValue(ResTable.passiveSkill, tostring(skillresid));
		if not skillArray then
			return;
		else
			skillArray['skill_class'] = 6; 
		end
	end	
	local skillInfo = strInfoPanel:GetLogicChild('tips');
	local skillName = strInfoPanel:GetLogicChild('name');
	skillName.Text = skillArray['name'];
	local skillItem = strInfoPanel:GetLogicChild('item');
	skillItem.Background = CreateTextureBrush('home/home_dikuang' .. skillArray['quality'] - 1 .. '.ccz', 'home');
	skillInfo.Text = skillArray['info'];
	local labelLvl = strInfoPanel:GetLogicChild('level');
	local skillLabel = skillInfoPanel:GetLogicChild('count');
	local skillNextLabel = skillInfoPanel:GetLogicChild('count1');
	local mageType = strInfoPanel:GetLogicChild('icon');
	mageType.Image = GetPicture(skill_class_map[SkillStrPanel:GetSkillType(skillresid)]);
	local imageIcon = strInfoPanel:GetLogicChild('item'):GetLogicChild('skillIcon');
	imageIcon.Image = GetPicture('icon/' .. tostring(skillArray['icon'] .. '.ccz'));
	
	local btnStr = strInfoPanel:GetLogicChild('lvUpBtn');
	local btnautoStr = strInfoPanel:GetLogicChild('autolvUpBtn');
	local index = 1;
	while(selectedRole.skls[index] and selectedRole.skls[index].resid ~= skillresid) do
		index = index + 1;
	end

	local skill = selectedRole.skls[index];
	if not skill then
		--异常流程处理,现解决角色未配置技能造成的log
		return
	end
	skill.level = skill.level or 0;
	labelLvl.Text = tostring(skill.level);
	skillLabel.Text = tostring(skill.level);
	skillNextLabel.Text = tostring(skill.level + 1);
	local labelConsume = skillInfoPanel:GetLogicChild('cost');
	--爱恋度折扣
	local discount = LovePanel:getGoldCostDecreased(selectedRole);

	--超过最大等级
	local RoleMaxLv = resTableManager:GetValue(ResTable.config, '41', 'value');
	if RoleMaxLv <= skill.level then
		btnautoStr.Enable = false;
		btnStr.Enable = false;
		skillInfoPanel.Visibility = Visibility.Visible;
		skillTipsPanel.Visibility = Visibility.Hidden;
		return
	end

	local money = resTableManager:GetValue(ResTable.skill_upgrade, tostring(skill.level+1), 'btp') * discount;
	labelConsume.Text = tostring(math.ceil(money));

	btnStr.Tag = index;
	btnStr:SubscribeScriptedEvent('Button::ClickEvent', 'SkillStrPanel:onStrength');
	btnautoStr.Tag = index;
	btnautoStr:SubscribeScriptedEvent('Button::ClickEvent', 'SkillStrPanel:onStrengthTen');
		
	if skill.level >= selectedRole.lvl.level or not ActorManager:IsHavePartner(selectedRole.resid) then
		btnautoStr.Enable = false;
		btnStr.Enable = false;
		skillInfoPanel.Visibility = Visibility.Visible;
		skillTipsPanel.Visibility = Visibility.Hidden;
	else
		if selectedRole.rank >= SkillStrPanel:GetrequareRank(selectedRole.resid, skill.resid) or skillArray['next_skill'] == 0 then
			btnStr.Enable = true;
			btnautoStr.Enable = true;
			skillInfoPanel.Visibility = Visibility.Visible;
			skillTipsPanel.Visibility = Visibility.Hidden;
		else
			skillInfoPanel.Visibility = Visibility.Hidden;
			skillTipsPanel.Visibility = Visibility.Visible;
			local rank = 
			{
				['1'] = 'N',
				['2'] = 'R',
				['3'] = 'SR',
				['4'] = 'UR',
				['5'] = 'UTR',
			}
			skillTipsPanel:GetLogicChild('title').Text = rank[tostring(SkillStrPanel:GetrequareRank(selectedRole.resid, skill.resid))] .. '進化で開放';
			btnStr.Enable = false;
			btnautoStr.Enable = false;
		end
	end

	if money > ActorManager.user_data.money then
		btnStr.Enable = false;
		btnautoStr.Enable = false;
		labelConsume.TextColor = QuadColor(Color(232, 38, 74, 255));
	else
		labelConsume.TextColor = QuadColor(Color(60, 137, 11, 255));
	end

	labelConsume:SetFont('huakang_18_noborder_underline');
	labelConsume:SubscribeScriptedEvent('UIControl::MouseClickEvent','MainUI:onBuyGold');

end
function SkillStrPanel:UpdateHaveCount()
	if curItemConsumeId ~= -1 then
		local itemData = Package:GetItem(curItemConsumeId);
		local numHave = itemData and itemData.num or 0;
		local haveLabel = advSkillPanel:GetLogicChild('count');
		haveLabel.Text = tostring(numHave);
	end
end
function SkillStrPanel:UpdateAdvInfo(args)
	local skillresid;
	if not args then
		skillresid = skillInfoNews.ctrl:GetLogicChild('btn').Tag;
	else
		skillresid = args.m_pControl.Tag;
		skillInfoNews = skillAdvList[args.m_pControl.TagExt];
	end
	self.curIndex = skillInfoNews.ctrl:GetLogicChild('btn').TagExt;
	local nextSkillid = resTableManager:GetValue(ResTable.skill, tostring(skillresid), 'next_skill');
	if not nextSkillid then
		nextSkillid = resTableManager:GetValue(ResTable.passiveSkill, tostring(skillresid), 'next_skill');
	end

	local skillArray = resTableManager:GetRowValue(ResTable.skill, tostring(skillresid));
	if not skillArray then
		skillArray = resTableManager:GetRowValue(ResTable.passiveSkill, tostring(skillresid));
		if not skillArray then
			return;
		else
			skillArray['skill_class'] = 6; 
		end
	end

	local skillName = advInfoPanel:GetLogicChild('name1');
	skillName.Text = skillArray['name'];
	local imageType = advInfoPanel:GetLogicChild('icon1');
	imageType.Image = GetPicture(skill_class_map[SkillStrPanel:GetSkillType(skillresid)]);
	local skillItem = advInfoPanel:GetLogicChild('item1');
	skillItem.Background = CreateTextureBrush('home/home_dikuang' .. skillArray['quality'] - 1 .. '.ccz', 'home');
	local imageIcon = skillItem:GetLogicChild('skillIcon');
	imageIcon.Image = GetPicture('icon/' .. tostring(skillArray['icon'] .. '.ccz'));
	local pointImg =  advInfoPanel:GetLogicChild('pointImg');
	local tipLabel = advInfoPanel:GetLogicChild('tip');
	local nexLvLabel = advInfoPanel:GetLogicChild('nextLvImg');
	local btnAdv = advSkillPanel:GetLogicChild('lvupBtn');
	btnAdv.Enable = true;
	if nextSkillid == 0 then
		advInfoPanel:GetLogicChild('item2').Visibility = Visibility.Hidden;
		advInfoPanel:GetLogicChild('name2').Visibility = Visibility.Hidden;
		advInfoPanel:GetLogicChild('icon2').Visibility = Visibility.Hidden;
		advInfoPanel:GetLogicChild('level2').Visibility = Visibility.Hidden;
		pointImg.Visibility = Visibility.Hidden;
		nexLvLabel.Visibility = Visibility.Hidden;

		tipLabel.Visibility = Visibility.Visible;
		advInfoPanel:GetLogicChild('tips').Text = skillArray['info'];
	else
		advInfoPanel:GetLogicChild('item2').Visibility = Visibility.Visible;
		advInfoPanel:GetLogicChild('name2').Visibility = Visibility.Visible;
		advInfoPanel:GetLogicChild('icon2').Visibility = Visibility.Visible;
		advInfoPanel:GetLogicChild('level2').Visibility = Visibility.Visible;
		pointImg.Visibility = Visibility.Visible;
		nexLvLabel.Visibility = Visibility.Visible;
		tipLabel.Visibility = Visibility.Hidden;
		local skillArray = resTableManager:GetRowValue(ResTable.skill, tostring(nextSkillid));
		if not skillArray then
			skillArray = resTableManager:GetRowValue(ResTable.passiveSkill, tostring(nextSkillid));
			if not skillArray then
				return;
			else
				skillArray['skill_class'] = 6; 
			end
		end

		local skillName = advInfoPanel:GetLogicChild('name2');
		skillName.Text = skillArray['name'];
		skillName.Visibility = Visibility.Visible;
		local imageType = advInfoPanel:GetLogicChild('icon2');
		imageType.Image = GetPicture(skill_class_map[SkillStrPanel:GetSkillType(nextSkillid)]);
		local skillItem = advInfoPanel:GetLogicChild('item2');
		skillItem.Visibility = Visibility.Visible;
		skillItem.Background = CreateTextureBrush('home/home_dikuang' .. skillArray['quality'] - 1 .. '.ccz', 'home');
		local imageIcon = skillItem:GetLogicChild('skillIcon');
		imageIcon.Image = GetPicture('icon/' .. tostring(skillArray['icon'] .. '.ccz'));
		local skillInfo = advInfoPanel:GetLogicChild('tips');
		skillInfo.Text = skillArray['info'];
	end
	
	local index = 1;
	while(selectedRole.skls[index] and selectedRole.skls[index].resid ~= skillresid) do
		index = index + 1;
	end

	local skill = selectedRole.skls[index];
	if not skill then
		--异常流程处理,现解决角色未配置技能造成的log
		return
	end

	local skill = selectedRole.skls[index];
	skill.level = skill.level or 0;
	local labelConsume = advSkillPanel:GetLogicChild('total');
	local itemNum = resTableManager:GetValue(ResTable.skill_compose, tostring(skill.resid), 'consume');
	local itemNum = itemNum or 0;
	labelConsume.Text = tostring(itemNum);
	local labelLvl = advInfoPanel:GetLogicChild('level1');
	local labelLvlNext = advInfoPanel:GetLogicChild('level2');
	labelLvl.Text = tostring(skill.level);
	labelLvlNext.Text = tostring(skill.level);

	btnAdv.Tag = index;
	btnAdv:SubscribeScriptedEvent('Button::ClickEvent', 'SkillStrPanel:onAdvance');
		

	if selectedRole.rank >= SkillStrPanel:GetrequareRank(selectedRole.resid, skill.resid) then
		btnAdv.Enable = true;
	else
		btnAdv.Enable = false;
	end

	local itemConsumeId = resTableManager:GetValue(ResTable.skill, tostring(skill.resid), 'next_skill_drawing');
	if itemConsumeId == 0 then
		itemConsumeId = resTableManager:GetValue(ResTable.skill, tostring(skill.resid - 1), 'next_skill_drawing');
	end
	curItemConsumeId = itemConsumeId;
	local itemData = Package:GetItem(itemConsumeId);
	local numHave = itemData and itemData.num or 0;
	local haveLabel = advSkillPanel:GetLogicChild('count');
	haveLabel.Text = tostring(numHave);
	local costType = advSkillPanel:GetLogicChild('costType');
	local icon = resTableManager:GetValue(ResTable.item, tostring(itemConsumeId), 'icon');
	if icon then
		costType.Image = GetPicture('icon/' .. icon .. '.ccz');
	end
	if itemNum > numHave or nextSkillid == 0 or not ActorManager:IsHavePartner(selectedRole.resid) then 
		btnAdv.Enable = false;
	end
	
	--技能tips刷新
	SkillStrPanel:UpdateAdvSkill(selectedRole);
end

function SkillStrPanel:GetrequareRank(resid, skillid)
	for rank=1, 5 do
		local skillinfo = resTableManager:GetRowValue(ResTable.qualityup_attribute, tostring(resid * 100 + rank));
		for _,typeindex in ipairs (skillEnum) do	
			if skillinfo[typeindex] == skillid and skillinfo then
				return rank;
			elseif skillinfo[typeindex] == skillid - 1 and skillinfo then
				return rank;
			end
		end
	end
	return 5;
end

function SkillStrPanel:isShow()
	return skillStrPanel.Visibility == Visibility.Visible;
end

function SkillStrPanel:GetSkillType(skillId)
  local skill_data = resTableManager:GetRowValue(ResTable.skill, tostring(skillId));
  if not skill_data then
	return 7;
  end
  local temp = skill_data['skill_class']; --如果等于0，则要另行区分攻击和辅助
  if skill_data['skill_type'] == 0 then
	if temp == 0 then
	  if skill_data['count'] > 0 then 
        --攻击
        temp = 0;
      else
        --辅助
        temp = 4;
      end
	end
  elseif skill_data['skill_type'] == 1 then
    if temp == 4 then
		temp = 6;
	else
		temp = 5;
	end
  end
  return temp;
end

--判断技能是否可升阶
function SkillStrPanel:IsCanAdv(skillresid, roleinfo)
	local nextSkillid = resTableManager:GetValue(ResTable.skill, tostring(skillresid), 'next_skill');
	if not nextSkillid then
		nextSkillid = resTableManager:GetValue(ResTable.passiveSkill, tostring(skillresid), 'next_skill');
	end
	if not nextSkillid or nextSkillid == 0 then
		return false
	end

	if roleinfo.rank < SkillStrPanel:GetrequareRank(roleinfo.resid, skillresid) then
		return false;
	end

	local itemNum = resTableManager:GetValue(ResTable.skill_compose, tostring(skillresid), 'consume');
	local itemConsumeId = resTableManager:GetValue(ResTable.skill, tostring(skillresid), 'next_skill_drawing');

	local itemData = Package:GetItem(itemConsumeId);
	local numHave = itemData and itemData.num or 0;
	if itemNum <= numHave and itemNum ~= 0 then 
		return true;
	else
		return false;
	end
end

--判断某角色技能是否可以进阶
function SkillStrPanel:IsRoleSkillCanAdv(roleinfo)
	if not ActorManager:IsHavePartner(roleinfo.resid) and roleinfo.pid ~= 0 then
		return false;
	end

	for _,skill in ipairs(roleinfo.skls) do
		if SkillStrPanel:IsCanAdv(skill.resid, roleinfo) then
			return true;
		end
	end
end

--判断是否有角色技能可以进阶
function SkillStrPanel:IsSkillCanAdv()
	for _,roleinfo in ipairs(ActorManager.user_data.partners) do
		if SkillStrPanel:IsRoleSkillCanAdv(roleinfo) then
			TipFlag:UpdateFlagSkill(true);
			return;
		end
	end
	if SkillStrPanel:IsRoleSkillCanAdv(ActorManager.user_data.role) then
		TipFlag:UpdateFlagSkill(true);
		return;
	end
	TipFlag:UpdateFlagSkill(false);
	return;
end

--更新技能tip状态
function SkillStrPanel:UpdateAdvSkill(roleinfo)
	if not roleinfo then
		Debug.print('have no role info !!!!')
		return
	end
	if SkillStrPanel:IsRoleSkillCanAdv(roleinfo) then
		skillStrPanel:GetLogicChild('cricle').Visibility = Visibility.Visible;
	else
		skillStrPanel:GetLogicChild('cricle').Visibility = Visibility.Hidden;
	end
end

function SkillStrPanel:success()
	local effect = PlayEffectLT('jinengjinjie_output/', Rect(advInfoPanel:GetAbsTranslate().x + advInfoPanel.Width * 0.5 , advInfoPanel:GetAbsTranslate().y + advInfoPanel.Height * 0.5, 0, 0), 'jinengjinjie');
	effect:SetScale(1.5, 1.5);
end
function SkillStrPanel:destroySkillUpSound()
	if skillUpSound then
		soundManager:DestroySource(skillUpSound);
		skillUpSound = nil
	end
end
function SkillStrPanel:SkillUpgradeSound(resid)
	local randomNum = math.random(1,2)
	local soundName = resTableManager:GetValue(ResTable.actor,tostring(resid),'foster_voice')
	if soundName then
		self:destroySkillUpSound()
		skillUpSound = SoundManager:PlayVoice( tostring(soundName[math.floor(randomNum)]))
	end
end
