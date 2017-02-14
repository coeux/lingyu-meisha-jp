--tipsPanel.lua

--========================================================================
--tips界面
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


local attribute =
	{ 
		'login/login_icon2.ccz', 				--é£?
		'login/login_icon4.ccz', 				--ç?
		'login/login_icon3.ccz', 				--æ°?
		'login/login_icon1.ccz', 				--é›?

	}
TipsPanel =
	{
	};	
local tipsPanel;
local mainDesktop;

local itemTipsPanel;
local itemPanel;
local itemName;
local itemCount;
local itemTipsInfo;

local roleTipsPanel;
local roleInfo;
local roleName;
local roleTipsInfo;
local haveCount;
local fpLabel;
local fpValue;
local typeIcon;
local natureIcon;
local chipCount;
local tipsId;
local countLabel;
local aptitudePanel;
local aptitudeLabel;
--初始化面板
function TipsPanel:InitPanel(desktop)

	--界面初始化
	mainDesktop 	= desktop;
	tipsPanel 		= UIControl(uiSystem:FindControl('TipsBox'));
	tipsPanel:IncRefCount();	
	tipsPanel.Visibility = Visibility.Hidden;
	tipsPanel.ZOrder = PanelZOrder.tips;

	itemTipsPanel 	= tipsPanel:GetLogicChild('itemTips');
	itemPanel 		= itemTipsPanel:GetLogicChild('item');
	itemName		= itemTipsPanel:GetLogicChild('name');
	itemCount		= itemTipsPanel:GetLogicChild('havecount');
	itemTipsInfo	= itemTipsPanel:GetLogicChild('tips');
	itemTip			= itemTipsPanel:GetLogicChild('tip');
	itemBtn 		= itemTipsPanel:GetLogicChild('btn');
	itemBtn:SubscribeScriptedEvent('Button::ClickEvent', 'TipsPanel:useItem');
	itemTipsPanel.Visibility = Visibility.Hidden;

	roleTipsPanel 	= tipsPanel:GetLogicChild('roleTips');
	roleInfo		= roleTipsPanel:GetLogicChild('item');
	roleName		= roleTipsPanel:GetLogicChild('name');
	roleTipsInfo	= roleTipsPanel:GetLogicChild('tips');
	roleTip 		= roleTipsPanel:GetLogicChild('tip');
	fpLabel			= roleTipsPanel:GetLogicChild('fpImg');
	fpValue			= fpLabel:GetLogicChild('zhanliValue');
	typeIcon		= roleTipsPanel:GetLogicChild('typeIcon1');
	natureIcon		= roleTipsPanel:GetLogicChild('nature');
	chipCount		= roleTipsPanel:GetLogicChild('havecount');
	countLabel		= roleTipsPanel:GetLogicChild('count');
	countLabel.Visibility = Visibility.Hidden;
	self.aptitudePanel	= roleTipsPanel:GetLogicChild('aptitudePanel');
	aptitudeLabel	= roleTipsPanel:GetLogicChild('aptitudePanel'):GetLogicChild('aptitudeLabel');
	roleTipsPanel.Visibility = Visibility.Hidden;
end

--销毁
function TipsPanel:Destroy()
	tipsPanel:IncRefCount();
	tipsPanel = nil;
end

--显示
function TipsPanel:Show()
	TipsPanel:ShowInfo(tipsId);
	tipsPanel.Visibility = Visibility.Visible;
	--设置模式对话框
	-- mainDesktop:DoModal(tipsPanel);	
	--增加UI弹出时候的效果
	-- StoryBoard:ShowUIStoryBoard(tipsPanel, StoryBoardType.ShowUI1);
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		itemTipsPanel:SetScale(factor,factor);
		roleTipsPanel:SetScale(factor,factor);
	end
	topDesktop:DoModal(tipsPanel);
	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(tipsPanel, StoryBoardType.ShowUI1);

end

--隐藏
function TipsPanel:Hide()
	tipsPanel.Visibility = Visibility.Hidden;
	--增加UI消失时的效果
	StoryBoard:HideTopUIStoryBoard(tipsPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopTopUI');
	-- StoryBoard:HideUIStoryBoard(tipsPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

function TipsPanel:fromIconShow(Args)
	local args = UIControlEventArgs(Args);
	local tag = args.m_pControl.Tag;
	
	self:onShow(tag);
end

function TipsPanel:onShow(resid)
	tipsId = resid;
	self:Show();
	--MainUI:Push(self);
end	

function TipsPanel:onClose()
	self:Hide();
	--MainUI:Pop();
end

--显示Tips信息
function TipsPanel:ShowInfo(resid)
	if resid >= 0 and resid <= ActorManager.user_data.role.resid then
		TipsPanel:updateRoleInfo(resid)
		roleTipsPanel.Visibility = Visibility.Visible;
	elseif resid >= 30001 and resid <= ActorManager.user_data.role.resid + 30000 then
		roleTipsPanel.Visibility = Visibility.Visible;
		TipsPanel:updateChipInfo(resid);
	else
		itemTipsPanel.Visibility = Visibility.Visible;
		TipsPanel:updateItemInfo(resid)
	end
end

function TipsPanel:useItem(Arg)
	local arg = UIControlEventArgs(Arg);	
	local msg = {};
	msg.resid = arg.m_pControl.Tag;
	msg.num = 1;
	msg.param = '';
	Network:Send(NetworkCmdType.req_use_item_t, msg);
end

--更新物品Tips信息
function TipsPanel:updateItemInfo(resid)
	itemTipsPanel.Visibility = Visibility.Visible;
	roleTipsPanel.Visibility = Visibility.Hidden;
	local itemInfo = resTableManager:GetRowValue(ResTable.item, tostring(resid));
	if not itemInfo then
		TipsPanel:onClose();
		Toast:MakeToast(Toast.TimeLength_Long, '该物品不存在,无法找到Tips信息');
	end
	local itemContrl = customUserControl.new(itemPanel, 'itemTemplate');
	itemContrl.initWithInfo(resid, -1, 80, false);
	itemName.Text		= itemInfo['name'];
	itemCount.Text		= tostring(Package:GetItemCount(resid)) or 0;
	itemTipsInfo.Text	= itemInfo['info'];
	itemTip.Text		= itemInfo['description'];
	itemBtn.Tag = resid;
	if itemInfo['type'] == 6  or ( itemInfo['type'] == 12 and resid > 20000 ) then
		itemBtn.Visibility = Visibility.Hidden;
	else
		itemBtn.Visibility = Visibility.Hidden;
	end
end

--更新伙伴Tips信息
function TipsPanel:updateRoleInfo(resid)
	itemTipsPanel.Visibility = Visibility.Hidden;
	roleTipsPanel.Visibility = Visibility.Visible;
	fpLabel.Visibility = Visibility.Visible;
	natureIcon.Visibility = Visibility.Visible;
	chipCount.Visibility = Visibility.Hidden;
	--countLabel.Visibility = Visibility.Hidden;
	roleTip.Visibility = Visibility.Hidden;
	--self.aptitudePanel.Visibility = Visibility.Hidden;
	local partnerInfo = ActorManager:GetRoleFromResid(resid);
	if not partnerInfo then
		TipsPanel:onClose();
		Toast:MakeToast(Toast.TimeLength_Long, '该伙伴不存在,无法找到Tips信息');
	end

	local itemContrl = customUserControl.new(roleInfo, 'itemTemplate');
	itemContrl.initWithInfo(resid, -1, 80, false);
	--找到等级最低的装备
	local equip_lvl = 100;
	for i=1, 5 do
	local equip_resid = partnerInfo.equips[tostring(i)].resid;
		local equip_rank = resTableManager:GetValue(ResTable.equip, tostring(equip_resid), 'rank');
		if equip_rank < equip_lvl then
			equip_lvl = equip_rank;
		end
	end

	--根据装备等级来决定边框颜色
	local ActorInfo = resTableManager:GetRowValue(ResTable.actor, tostring(resid));
	roleName.Text		= ActorInfo['name'];
	roleTipsInfo.Text	= ActorInfo['cdescription'];
	fpValue.Text		= tostring(partnerInfo.pro.fp);
	natureIcon.Image	= GetPicture('cardRelated/home_quality'.. partnerInfo.quality - 1 .. '.ccz')

	typeIcon.Image = GetPicture('login/login_icon_' .. ActorInfo['attribute'] .. '.ccz');
    local roleAptitude = resTableManager:GetValue(ResTable.actor, tostring(resid%10000),'Quality');
	aptitudeLabel.Text = tostring(roleAptitude);
	TipsPanel:updateSkillInfo(partnerInfo);
end

--更新碎片Tips信息
function TipsPanel:updateChipInfo(resid)
	itemTipsPanel.Visibility = Visibility.Hidden;
	roleTipsPanel.Visibility = Visibility.Visible;
	fpLabel.Visibility = Visibility.Hidden;
	natureIcon.Visibility = Visibility.Hidden;
	chipCount.Visibility = Visibility.Visible;
	--countLabel.Visibility = Visibility.Visible;
	--self.aptitudePanel.Visibility = Visibility.Visible;
	local itemInfo = resTableManager:GetRowValue(ResTable.item, tostring(resid));
	if not itemInfo then
		TipsPanel:onClose();
		Toast:MakeToast(Toast.TimeLength_Long, '该碎片不存在,无法找到Tips信息');
	end
	local itemContrl = customUserControl.new(roleInfo, 'itemTemplate');
	itemContrl.initWithInfo(resid, -1, 80, false);
	roleName.Text		= itemInfo['name'];
	roleTipsInfo.Text	= itemInfo['info'];
	roleTip.Text		= ''--'(' .. itemInfo['description'] .. ')';
	roleTip.Visibility = Visibility.Visible;
	local haveCount = Package:GetItemCount(resid) or 0;
	chipCount.Text		= tostring(haveCount);

	local ActorInfo = resTableManager:GetRowValue(ResTable.actor, tostring(resid - 30000));
	typeIcon.Image = GetPicture('login/login_icon_' .. ActorInfo['attribute'] .. '.ccz');

	local partnerInfo = ActorManager:GetRoleFromResid(resid - 30000);
	if not partnerInfo then
		partnerInfo = ResTable:createRoleNoHave(resid - 30000)
	end
	local needChipNum = ActorInfo['hero_piece']
	countLabel:RemoveAllChildren();
	countLabel:AddText('(', Configuration.WhiteColor, uiSystem:FindFont('huakang_20'));
	if haveCount <= needChipNum then
		countLabel:AppendText(tostring(haveCount), Configuration.RedColor, uiSystem:FindFont('huakang_20'));
	else
		countLabel:AppendText(tostring(haveCount), Configuration.WhiteColor, uiSystem:FindFont('huakang_20'));
	end
	countLabel:AppendText('/', Configuration.WhiteColor, uiSystem:FindFont('huakang_20_noborder'));
	countLabel:AppendText(tostring(needChipNum), Configuration.WhiteColor, uiSystem:FindFont('huakang_20'));
	countLabel:AppendText(')', Configuration.WhiteColor, uiSystem:FindFont('huakang_20'));
	local roleAptitude = resTableManager:GetValue(ResTable.actor, tostring(resid%10000),'Quality');
	aptitudeLabel.Text = tostring(roleAptitude);

	TipsPanel:updateSkillInfo(partnerInfo);
end


--刷新技能相关信息
function TipsPanel:updateSkillInfo(role)
	local i = 1;
	for _,skill in ipairs(role.skls) do
		if i <= 5 then
			local skillPanel = roleTipsPanel:GetLogicChild('sk' .. i);
			if skill.resid ~= 0 then
				local skillInfo = resTableManager:GetValue(ResTable.skill, tostring(skill.resid), {'name','icon','quality','info'});
				if not skillInfo then
					skillInfo = resTableManager:GetValue(ResTable.passiveSkill, tostring(skill.resid), {'name','icon','quality','info'});
				end
				local skillBg	= skillPanel:GetLogicChild('item');
				local skillIcon = skillBg:GetLogicChild(0);
				local typeIcon 	= skillPanel:GetLogicChild('icon1');
				local skillTips = skillPanel:GetLogicChild('tips');
				skillTips:RemoveAllChildren();
				skillTips:AddText(skillInfo['name'] .. ':', QuadColor(Color(255,255,255,255)), uiSystem:FindFont('huakang_18_noborder'));
				skillTips:AppendText(skillInfo['info'],  QuadColor(Color(255,255,255,255)), uiSystem:FindFont('huakang_18_noborder'));
				typeIcon.Image 	= GetPicture(skill_class_map[SkillStrPanel:GetSkillType(skill.resid)]);
				skillIcon.Image = GetIcon(skillInfo['icon']);
				skillBg.Image = GetPicture('home/home_dikuang' .. skillInfo['quality'] - 1 .. '.ccz');
				i = i + 1;
			end
		end
	end
end
