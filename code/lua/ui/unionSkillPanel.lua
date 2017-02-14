--unionSkillPanel.lua
--=============================================================================================
--公会技能面板
UnionSkillPanel =
	{
	};
	
--变量
local isShow = false;
local leftPoint = 0;

--控件
local mainDesktop;
local panel;
local labelDonate;
local skillPanelList = {};
local skillList = {};
local btnClose;

--常量
local maxSkill = 6

--初始化
function UnionSkillPanel:InitPanel(desktop)
	--变量初始化
	isShow = false;
	skillPanelList = {};
	
	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('unionSkillPanel'));
	panel:IncRefCount();
	
	labelDonate = panel:GetLogicChild('labelDonate');
	
	for index = 1, maxSkill do
		local ctrl = customUserControl.new(panel:GetLogicChild(tostring(index)), 'unionSkillTemplate');
		skillPanelList[index] = ctrl;
		skillList[index] = {};
		skillList[index].resid = 0;
		skillList[index].level = 0;
	end
	
	panel.Visibility = Visibility.Hidden;

	btnClose = panel:GetLogicChild('close');
	btnClose:SubscribeScriptedEvent('Button::ClickEvent', 'UnionSkillPanel:onClose'); 
	
	--注册事件
	NetworkMsg_Union:RegisterEvent(NetworkCmdType.nt_gang_pay_change, UnionSkillPanel, UnionSkillPanel.refreshDonate);
end

--销毁
function UnionSkillPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function UnionSkillPanel:Show()
	isShow = true;
	mainDesktop:DoModal(panel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(panel, StoryBoardType.ShowUI1);
end

--隐藏
function UnionSkillPanel:Hide()
	isShow = false;
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(panel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');	
end

--=============================================================================================
--功能函数
--刷新个人贡献值
function UnionSkillPanel:refreshDonate()
	labelDonate.Text = tostring(ActorManager.user_data.curDonate);
end

--刷新公会技能状态
--[[
function UnionSkillPanel:refreshSkillState()
	if isShow then
		for _,ctrl in pairs(skillPanelList) do
			local openLevel = resTableManager:GetValue(ResTable.unionSkill, tostring(ctrl.resid), 'unlock_guildlv');
			if (ActorManager.user_data.unionLevel >= openLevel) and (0 == ctrl.advance.TagExt) then			--未开启的技能
				self:refreshSkillPanel(ctrl, ctrl.resid, 0);
			end
		end
	end	
end
--]]

--刷新技能按钮
--[[
function UnionSkillPanel:refreshSkillPanel(ctrl, resid, level)
	local donate = self:GetConsumeDonate(resid, (level + 1));
	if level < ActorManager.user_data.role.lvl.level then		--小于等于角色等级
		ctrl.advance.Text = LANG_unionSkillPanel_1;
		ctrl.advance.TagExt = donate;
		ctrl.consume.Text = donate .. LANG_unionSkillPanel_2;
		ctrl.consume.Visibility = Visibility.Visible;
		ctrl.title.Visibility = Visibility.Visible;
		ctrl.info.Visibility = Visibility.Hidden;
		ctrl.level.Text = 'Lv' .. level;
		ctrl.level.Tag = level;
		if donate > ActorManager.user_data.curDonate then
			ctrl.advance.Enable = false;
			ctrl.consume.TextColor = Configuration.RedColor;
		else
			ctrl.advance.Enable = true;
			ctrl.consume.TextColor = Configuration.WhiteColor;
		end
	else
		ctrl.advance.Enable = false;
		ctrl.advance.Text = LANG_unionSkillPanel_3;
		ctrl.advance.TagExt = donate;
		ctrl.consume.Text = donate .. LANG_unionSkillPanel_4;
		ctrl.info.Text = LANG_unionSkillPanel_5;
		ctrl.consume.Visibility = Visibility.Hidden;
		ctrl.title.Visibility = Visibility.Hidden;
		ctrl.info.Visibility = Visibility.Visible;
		ctrl.level.Text = 'Lv' .. level;
		ctrl.level.Tag = level;
	end
	
end
--]]
--计算升级公会技能需要消耗的贡献值
function UnionSkillPanel:GetConsumeDonate(resid, level)
	local data = resTableManager:GetRowValue(ResTable.unionSkillCon, tostring(level));
	for _,id in ipairs(data['type_one']) do
		if id == resid then
			return data['cost_one'];
		end
	end
	return data['cost_two'];
end

--=============================================================================================
--事件

--关闭
function UnionSkillPanel:onClose()
	Network:Send(NetworkCmdType.up_team_pro, {}, true);
	MainUI:Pop();
end

--显示公会技能界面
function UnionSkillPanel:onShowUnionSkillPanel(msg)
	ActorManager.user_data.unionLevel = msg.lv;
	ActorManager.user_data.curDonate = msg.gm;

	for i=1, maxSkill-1 do
		skillList[i].resid = msg.gskls[i].resid;
		skillList[i].level = msg.gskls[i].level;
		skillPanelList[i].initWithInfo(skillList[i].resid, skillList[i].level, msg.gm);
	end
	skillPanelList[maxSkill].initWithDefault();

	self:refreshDonate();
	MainUI:Push(self);
end

--技能升级按钮点击事件
function UnionSkillPanel:onAdvanceSkill(Args)
	local args = UIControlEventArgs(Args);
	local msg = {};
	msg.resid = args.m_pControl.Tag;	
	Network:Send(NetworkCmdType.req_learn_gskl, msg, true);	
	
	--播放特效
	--self:playEffect(args.m_pControl);
end

--点击捐献按钮
function UnionSkillPanel:onDonate()
	MainUI:Push(UnionDonatePanel);
end

--播放技能升级特效
function UnionSkillPanel:playEffect(button)
	local x = button:GetAbsTranslate().x;
	local y = button:GetAbsTranslate().y;
	local renderSize = button.RenderSize;
	PlayEffectLT('gonghuijinengshengji_output/', Rect(x + renderSize.Width * 0.3, y + renderSize.Height / 2, 0, 0), 'gonghuijinengshengji');
end

--技能升级
function UnionSkillPanel:onSkillAdvanced(msg)
	skillPanelList[msg.resid%100].initWithInfo(msg.resid, msg.level, ActorManager.user_data.curDonate);
	self:refreshDonate();
	--self:refreshSkillPanel(skillPanelList[msg.resid], msg.resid, msg.level);
end

function UnionSkillPanel:checkTheLeftPoint()
    for i=1, maxSkill-1 do
		local cost = skillPanelList[i].getcostPoint()
        if cost and cost > leftPoint then 
            skillPanelList[i].setButtonEnabled()
        end 
	end
end

function UnionSkillPanel:setLeftPoint(arg)
    leftPoint = arg
end

function UnionSkillPanel:onAdvanceSkillSuccess()
    self:checkTheLeftPoint()
end
