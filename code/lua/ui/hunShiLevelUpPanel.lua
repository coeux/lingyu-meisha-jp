--HunShiLevelUpPanel.lua

--========================================================================
--角色升级面板

HunShiLevelUpPanel =
	{

	};
local attImages = 
{
	'login/login_icon_202.ccz',
	'login/login_icon_200.ccz',
	'login/login_icon_203.ccz',
	'login/login_icon_201.ccz',
}

local attNum = 
{
	'202',
	'200',
	'203',
	'201'
}
local hunShiLevelUpPanel
local levelNum
local levelUpBg
local sureBtn
local roleImg
local attPanelList={}
local armature     --  特效

--初始化面板
function HunShiLevelUpPanel:InitPanel( desktop )
		
	--变量初始化
	tiliTimer = 0;		--体力动画timer
	curTili = 0;
	targetTili = 0;
	startTime = 0;
	attPanelList={}
	--界面初始化
	mainDesktop = desktop;
	hunShiLevelUpPanel = desktop:GetLogicChild('hunShiLevelUpPanel')
	hunShiLevelUpPanel:IncRefCount()
	hunShiLevelUpPanel.ZOrder = 10000
	hunShiLevelUpPanel.Visibility = Visibility.Hidden
	levelNum = hunShiLevelUpPanel:GetLogicChild('wingImg'):GetLogicChild('levelNum')
	levelUpBg = hunShiLevelUpPanel:GetLogicChild('bg')
	levelUpBg.Visibility = Visibility.Hidden
	sureBtn = hunShiLevelUpPanel:GetLogicChild('sureBtn')
	sureBtn:SubscribeScriptedEvent('Button::ClickEvent','HunShiLevelUpPanel:onClose')
	
	--属性信息
	bottomPanel = hunShiLevelUpPanel:GetLogicChild('bottomPanel')
	roleImg = bottomPanel:GetLogicChild('roleImg')
	local role = ActorManager:GetRole(0)
	local resid = 0;
	if role.lvl.lovelevel == LovePanel.MAX_LOVE_TASK_LEVEL then
		resid = role.resid + 10000
	else
		resid = role.resid
	end
	local imgPath = resTableManager:GetValue(ResTable.navi_main,tostring(resid),'role_path')
	roleImg.Image = GetPicture('navi/'..imgPath..'.ccz')
	
	for i = 1 ,4 do
		local attPanel = bottomPanel:GetLogicChild('att'..i):GetLogicChild(0)
		attPanelList[i] = attPanel
		local attImg = attPanel:GetLogicChild('attImage')
		attImg.Image = GetPicture(attImages[i])
		if 3 ~= i then
			attImg:SetScale(0.8,0.8)
		end
	end
	
end
function HunShiLevelUpPanel:refreshData()
	levelNum.Text = tostring(ActorManager.user_data.counts.soulranknum)
	for i = 1 , 4 do 
		local attPanel = attPanelList[i]
		for j = 1 , 5 do
			local att = attPanel:GetLogicChild('att'..j)
			local rightPanel = att:GetLogicChild('rightPanel')
			local oldValue = rightPanel:GetLogicChild('oldValue')
			local upValue  = rightPanel:GetLogicChild('upValue')
			local nowValue = att:GetLogicChild('nowValue')
			att:GetLogicChild('bgBrush').Visibility = Visibility.Hidden
			nowValue.Visibility = Visibility.Hidden
			rightPanel.Visibility = Visibility.Visible
			if ActorManager.user_data.counts.soulid == 0 then
				oldValue.Text = '0'
				upValue.Text  = '0'
			else
				if ActorManager.user_data.counts.soul_node_infos then
					if ActorManager.user_data.counts.soul_node_infos[attNum[i]] 
					and ActorManager.user_data.counts.soul_node_infos[attNum[i]]['soul_node_point'][''..j] then
						upValue.Text  = tostring(ActorManager.user_data.counts.soul_node_infos[attNum[i]]['soul_node_point'][''..j])
					else
						upValue.Text = '0'
					end
				end
				if HunShiPanel.old_soul_node_infos then
					if HunShiPanel.old_soul_node_infos[attNum[i]] 
					and HunShiPanel.old_soul_node_infos[attNum[i]]['soul_node_point'][''..j] then
						oldValue.Text = tostring(HunShiPanel.old_soul_node_infos[attNum[i]]['soul_node_point'][''..j])
					else
						oldValue.Text = '0'
					end
				end
			end
		end
	end
end
--销毁
function HunShiLevelUpPanel:Destroy()
	-- panel:DecRefCount();
	-- panel = nil;
	hunShiLevelUpPanel:DecRefCount()
	hunShiLevelUpPanel = nil
end

--显示
function HunShiLevelUpPanel:Show()

	hunShiLevelUpPanel:GetLogicChild('wingImg').Image = GetPicture('common/hunshi_levelup.ccz');


	if armature then
		armature:Destroy()
	end

	--显示特效

	armature = PlayEffect('zhandoushengli_output/', Rect(0,100, 0, 90), 'guang',hunShiLevelUpPanel)
	armature.ZOrder = -10
	armature.Translate = Vector2(0, -200)
	--显示数值
	self:refreshData()
	mainDesktop:DoModal(hunShiLevelUpPanel)
	levelUpBg.Visibility = Visibility.Visible
	hunShiLevelUpPanel.Visibility = Visibility.Visible
	StoryBoard:ShowUIStoryBoard(hunShiLevelUpPanel,StoryBoardType.ShowUI1)

end

--隐藏
function HunShiLevelUpPanel:Hide()

	if armature then
		armature:Destroy()
	end
	
	levelUpBg.Visibility = Visibility.Hidden
	hunShiLevelUpPanel.Visibility = Visibility.Hidden
	mainDesktop:UndoModal()
	StoryBoard:HideTopUIStoryBoard(hunShiLevelUpPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopTopUI')

end

--返回
function HunShiLevelUpPanel:onClose()
	self:Hide()	
	
end
