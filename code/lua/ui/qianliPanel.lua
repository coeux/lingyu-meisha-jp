--qianliPanel.lua
--==============================================================
--潜力界面

QianliPanel = 
	{
	};

--变量

local currentRole;
local currentRoleId;
local isVisible;
local materialId;
local materialNum;
local currentAttribute;

--控件
local mainDesktop;
local panel;
local labelAttributeList = {};
local imgRole;
local btnList = {};
local labelMaterialList = {};
local numMaterial;
local bg;
local btnReturn;
local imgRole;
local partnerlv;

local isFirstShow = false
local canClickBtnList = {}
local canClickBtnNum = 0
local isClickBtn = false

function QianliPanel:InitPanel(desktop)
	--变量
	isVisible = false;
	materialId = resTableManager:GetValue(ResTable.potential, '105', 'consume');
	--控件
	mainDesktop = desktop;
	panel = desktop:GetLogicChild('qianliPanel');
	panel:IncRefCount();
	panel.Visibility = Visibility.Hidden;
	panel.ZOrder = PanelZOrder.qianli;   
	for i=1, 5 do
		--label 位置绑定控件
		labelAttributeList[i] = {};
		labelAttributeList[i].atkbefor = panel:GetLogicChild('stackPanel'):GetLogicChild('panel' .. i):GetLogicChild('wugongBg'):GetLogicChild('before_lv');
		labelAttributeList[i].mgcbefor = panel:GetLogicChild('stackPanel'):GetLogicChild('panel' .. i):GetLogicChild('jigongBg'):GetLogicChild('before_lv');
		labelAttributeList[i].mgcafter = panel:GetLogicChild('stackPanel'):GetLogicChild('panel' .. i):GetLogicChild('jigongBg'):GetLogicChild('after_lv');
		labelMaterialList[i] = panel:GetLogicChild('stackPanel'):GetLogicChild('panel' .. i):GetLogicChild('xiaohao');
		--按钮事件绑定
		btnList[i] = panel:GetLogicChild('stackPanel'):GetLogicChild('panel' .. i):GetLogicChild('upgradebutton');
		btnList[i]:SubscribeScriptedEvent('Button::ClickEvent', 'QianliPanel:onClickLevelup');
		btnList[i].Tag = i;
		panel:GetLogicChild('stackPanel'):GetLogicChild('panel' .. i):GetLogicChild('bottomWhiteBg'..i).Background = CreateTextureBrush('home/home_cardlist_upgrade_item_bg.ccz','godsSenki');
	end	
	bg = panel:GetLogicChild('bg');
	numMaterial = panel:GetLogicChild('elementPanel'):GetLogicChild('num');
    self.isShow = false;
end

function QianliPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function QianliPanel:Show(roleresid, roleinfo)
	--更新角色
	self:refreshRole(roleinfo);
	currentRole = roleinfo;
	--更新拥有材料
	self:refreshMaterial();
	--更新当前潜力数值与消耗
	if UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and UserGuidePanel.isPropertyBegin then
		isFirstShow = true
	end
	 self:refreshQianli();
	 self.isShow = true;
	 isVisible = true; 
	 panel:SetUIStoryBoard("storyboard.showUIBoard2"); 
	 panel.Visibility = Visibility.Visible;
end

--隐藏
function QianliPanel:Hide()
	self.isShow  = false;
    CardDetailPanel:refreshFp();
	panel.Visibility = Visibility.Hidden;
end

function QianliPanel:showPanel()
	self.isShow  = true;
	panel.Visibility = Visibility.Visible;
end

function QianliPanel:getSelfPanel()
	return panel;
end

--更新角色
function QianliPanel:refreshRole(roleinfo)
	currentRole = roleinfo;
end

function QianliPanel:recordProperInfo(partnerlv, nextstate)  --记录一下所有物防和 生命等信息
     local atk = resTableManager:GetValue(ResTable.levelup_attribute, tostring(partnerlv), 'atk');
     local mgc = resTableManager:GetValue(ResTable.levelup_attribute, tostring(partnerlv), 'mgc');  --技能攻
     local def = resTableManager:GetValue(ResTable.levelup_attribute, tostring(partnerlv), 'def');  --物防 
     local res = resTableManager:GetValue(ResTable.levelup_attribute, tostring(partnerlv), 'res');  --技能防御
     local hp = resTableManager:GetValue(ResTable.levelup_attribute, tostring(partnerlv), 'hp');
     if(not nextstate) then
       recordBeforePartnerInfoList = {atk, mgc, def, res, hp};
     end
     if(nextstate) then                          --说明此时是主角增长后的信息
       recordNextPartnerInfoList   = {atk, mgc, def, res, hp};
       timer = timerManager:CreateTimer(0.8, 'QianliPanel:makeTimer', 1);
	 end
end
local time = 0;
function QianliPanel:makeTimer()
	time = time + 1;
	if(time <= 5)  then
	    ToastMove:CreateToast(GemWord[time]..' '.. '+'..' '..recordNextPartnerInfoList[time] - recordBeforePartnerInfoList[time], Configuration.GreenColor);
    else
    	self:recordProperInfo(partnerlv, false);
       	timerManager:DestroyTimer(timer);
       	time = 0;
	end
end

--更新潜力数值
function QianliPanel:refreshQianli(msg)
	local potentialList = {};
	potentialList[1] = currentRole.potential_1;
	potentialList[2] = currentRole.potential_2;
	potentialList[3] = currentRole.potential_3;
	potentialList[4] = currentRole.potential_4;
	potentialList[5] = currentRole.potential_5;
	for i = 1, 5 do
		local lv = potentialList[i];
		local potentialId = currentRole.job * 100 +  i;
		local value = resTableManager:GetValue(ResTable.potential, tostring(potentialId), 'value');
		labelAttributeList[i].atkbefor.Text = tostring(lv);
        labelAttributeList[i].mgcbefor.Text = tostring(value * lv);
        labelAttributeList[i].mgcafter.Text = tostring(value * (lv + 1));
		local requireNum = self:calculateConsume(lv);
		labelMaterialList[i].Text = tostring(requireNum);
		if requireNum > materialNum or lv + FunctionOpenLevel.refine > currentRole.lvl.level then

			btnList[i].CoverBrush = uiSystem:FindResource('btn_tongyong_hui_1', 'godsSenki');
			btnList[i].NormalBrush = uiSystem:FindResource('btn_tongyong_hui_1', 'godsSenki');
			btnList[i].PressBrush = uiSystem:FindResource('btn_tongyong_hui_1', 'godsSenki');
		else
			btnList[i].CoverBrush = uiSystem:FindResource('btn_tongyong_1', 'godsSenki');
			btnList[i].NormalBrush = uiSystem:FindResource('btn_tongyong_1', 'godsSenki');
			btnList[i].PressBrush = uiSystem:FindResource('btn_tongyong_1', 'godsSenki');
			if UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and UserGuidePanel.isPropertyBegin then
				canClickBtnNum = canClickBtnNum + 1
				canClickBtnList[canClickBtnNum] = btnList[i]
			end
		end
	end
	--新手引导
	if UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and canClickBtnNum > 0 and UserGuidePanel.isPropertyBegin then
		timerManager:CreateTimer(0.1,'QianliPanel:onEnterUserGuilde',0,true)
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and UserGuidePanel.isPropertyBegin then
		--属性试炼新手引导完成
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.propertyTask,2)
	end
end

function QianliPanel:onEnterUserGuilde(  )
	if UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and canClickBtnNum > 0 and not isClickBtn and UserGuidePanel.isPropertyBegin then
		UserGuidePanel:ShowGuideShade( canClickBtnList[1],GuideEffectType.hand,GuideTipPos.right,'', 0)
		isClickBtn = true
	end
	--  属性试炼新手引导完成
	if UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and UserGuidePanel.isPropertyBegin then
		UserGuidePanel:ReqWriteGuidence(UserGuideIndex.propertyTask,2)
	end
end

--更新拥有材料
function QianliPanel:refreshMaterial()
	local num = Package:GetItem(materialId) and Package:GetItem(materialId).num or 0;
	numMaterial.Text = tostring(num);
	materialNum = num;
end

function QianliPanel:IsVisible()
	return isVisible;
end

--================================================
--功能函数

--点击升级
function QianliPanel:onClickLevelup(Args)
	local args = UIControlEventArgs(Args);
	local attribute = args.m_pControl.Tag;
	currentAttribute = attribute;
	--发请求
	local msg = {};
	msg.pid = currentRole.pid;
	msg.flag = 1;		                         --以前的遗留变量
	msg.attribute = attribute;
	QianliPanel:setBtn(true)
	Network:Send(NetworkCmdType.req_potential_up, msg);
end

--关闭返回
function QianliPanel:onClose()
	self:Hide();
	isVisible = false;
end

--点击升级
function QianliPanel:setBtn(flag)
	if flag then
		for i=1, 5 do
			btnList[i].Pick = false;
		end
	else
		for i=1, 5 do
			btnList[i].Pick = true;
		end
	end
end

function QianliPanel:setRole(pid)
	currentRoleId = pid;
end

--计算对应等级下的材料消耗
function QianliPanel:calculateConsume(lv)
	local lv_next = lv + 1;
	if lv_next <= 20 then
		return math.floor(10 * (1.055 ^ lv_next) + lv_next^1.5);
	else
		return math.floor(10 * (1.055 ^ lv_next) + lv_next^1.575);
	end
end

--获取当前要升级的属性
function QianliPanel:getCurrentAttribute()
	return currentAttribute;
end


--判断角色是否可以提升潜力
function QianliPanel:IsRoleCanAttributeUp(roleinfo)
	local costId = resTableManager:GetValue(ResTable.potential, '105', 'consume');
	local num = Package:GetItem(costId) and Package:GetItem(costId).num or 0;
	local potentialList = {};
	potentialList[1] = roleinfo.potential_1;
	potentialList[2] = roleinfo.potential_2;
	potentialList[3] = roleinfo.potential_3;
	potentialList[4] = roleinfo.potential_4;
	potentialList[5] = roleinfo.potential_5;
	for i = 1, 5 do
		local lv = potentialList[i];
		local potentialId = roleinfo.job * 100 +  i;
		local value = resTableManager:GetValue(ResTable.potential, tostring(potentialId), 'value');
		local requireNum = self:calculateConsume(lv);
		if requireNum <= num and lv + FunctionOpenLevel.refine < roleinfo.lvl.level then
			return true;
		end
	end
	return false;
end
