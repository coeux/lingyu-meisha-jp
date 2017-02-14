--WorldScufflePanel.lua
WorldScufflePanel =
{
};
local mainDesktop;
local panel;
local bg; 		
local leftPanel; 
local rightPanel;
local topPanel;	
local explainBG; 
local returnBtn; 
local explainBtn;
local bottomPanel;	
local rewardBtn;	   	
local registerBtn;	
local img;			
local rewardPanel;	
local timeTipPanel;	
local timeLabel;
local explainBG;
local ruleExplain; 
local explainLabel;
local rewardTouchPanel;	
local rewardStackPanel;

local scuffleStartTimer


function WorldScufflePanel:InitPanel(desktop)
  
	scuffleStartTimer = 0;
	
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('worlScufflePanel'));
	panel.ZOrder = 1300;
	panel:IncRefCount();
	
	--背景及图片
	bg 		= panel:GetLogicChild('bg');
	leftPanel = panel:GetLogicChild('leftPanel');
	rightPanel= panel:GetLogicChild('rightPanel');
	topPanel	= panel:GetLogicChild('topPanel');
	explainBG = panel:GetLogicChild('explainBG');
	
	--按钮
	returnBtn = panel:GetLogicChild('returnBtn');
	explainBtn= panel:GetLogicChild('explainBtn');
	
	--底部
	bottomPanel	= panel:GetLogicChild('bottomPanel');
	rewardBtn	= bottomPanel:GetLogicChild('rewardBtn');
	registerBtn	= bottomPanel:GetLogicChild('registerBtn');
	img			= bottomPanel:GetLogicChild('img');
	rewardPanel	= bottomPanel:GetLogicChild('rewardPanel');
	timeTipPanel	= bottomPanel:GetLogicChild('timeTipPanel');
	timeLabel		= timeTipPanel:GetLogicChild('timeLabel');
	rewardTouchPanel = rewardPanel:GetLogicChild('rewardTouchPanel');
	rewardStackPanel = rewardTouchPanel:GetLogicChild('rewardStackPanel');
	returnBtn:SubscribeScriptedEvent('Button::ClickEvent','WorldScufflePanel:onReturn');
	explainBtn:SubscribeScriptedEvent('Button::ClickEvent','WorldScufflePanel:showRule');
	rewardBtn:SubscribeScriptedEvent('Button::ClickEvent','WorldScufflePanel:showReward');
	registerBtn:SubscribeScriptedEvent('Button::ClickEvent','WorldScufflePanel:registerName');
	
	--说明
	explainBG = panel:GetLogicChild('explainBG');
	ruleExplain = panel:GetLogicChild('ruleExplain');
	explainLabel = ruleExplain:GetLogicChild('content'):GetLogicChild('explainLabel');
	explainLabel.Text = LANG_scuffle_Explain;
	explainLabel.Size = Size(600,800);
	ruleExplain:SubscribeScriptedEvent('UIControl::MouseClickEvent','WorldScufflePanel:hidRule');
	explainBG:SubscribeScriptedEvent('UIControl::MouseClickEvent','WorldScufflePanel:hidRule');
end

function WorldScufflePanel:showRegisterNamePanel()
	img.Image = GetPicture('union/zk_03.ccz');
	bgImg.Image = GetPicture('background/scuffle_register_bg.ccz');
	bgImg.Size = Size(795, 400)
	registerNamePanel.Visibility = Visibility.Visible
end
function WorldScufflePanel:hideRegisterNamePanel()
	self:hidReward()
	registerNamePanel.Visibility = Visibility.Hidden
end
function WorldScufflePanel:showRule()
	self:hidReward()
	ruleExplain.Visibility = Visibility.Visible
	explainBG.Visibility = Visibility.Visible
end
function WorldScufflePanel:hidRule()
	ruleExplain.Visibility = Visibility.Hidden
	explainBG.Visibility = Visibility.Hidden
end

function WorldScufflePanel:showReward()
	if rewardPanel.Visibility == Visibility.Visible then
		self:hidReward()
	else
		rewardTouchPanel:VScrollBegin();
		rewardStackPanel:RemoveAllChildren();
		local rewardList = {}
		local scuffleRewardNum = resTableManager:GetRowNum(ResTable.kof_reward)
		for i = 1 , scuffleRewardNum - 1 do
			local scuffleReward = resTableManager:GetRowValue(ResTable.kof_reward,i)
			if scuffleReward['reward'] then
				local rewardItem = scuffleReward['reward'];
				local itemNum = 1;
				while rewardItem[itemNum] do
					rewardList[tostring(rewardItem[itemNum][1])] = 0;
					itemNum = itemNum + 1;
				end
			end
		end
		local rList = {};
		for id,_ in pairs(rewardList) do
			table.insert(rList,tonumber(id));
		end
		local sortFunc = function(a, b)
			return a > b;
		end
		table.sort(rList,sortFunc);
		for _,id in pairs(rList) do
			local panel = uiSystem:CreateControl('Panel');
			panel.Size = Size(65, 65);
			local ctrl = customUserControl.new(panel, 'itemTemplate');
			ctrl.initWithInfo(tonumber(id), -1, 65, true);
			--print('rewardId->'..tostring(id));
			rewardStackPanel:AddChild(panel);
		end
		rewardPanel.Visibility = Visibility.Visible;
	end
end
function WorldScufflePanel:hidReward()
	rewardPanel.Visibility = Visibility.Hidden
end
function WorldScufflePanel:registerName()
	self:hidReward()
	local level = Hero:GetLevel();
	if level < FunctionOpenLevel.scuffle then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_scufflePanel_7);
		return;
	end
	
	if ScufflePanel.scuffleState == 1 then
		if ScufflePanel.selfState == 0 then
			ScufflePanel:reqScuffleRegist()
			--[[
		else
			ScufflePanel:onClickScuffleBtn();
			]]
		end
	elseif ScufflePanel.scuffleState == 2 then
		if ScufflePanel.selfState == 0 then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_scufflePanel_19);
		else
			ScufflePanel:onClickScuffleBtn()
		end
	else
		
	end

end
function WorldScufflePanel:enableRegistBtn()
	--print('enableRegistBtn->')
	registerBtn.Enable = false;
	registerBtn.Text = LANG_scufflePanel_14;
end

function WorldScufflePanel:Show()
	local img1 = leftPanel:GetLogicChild('img')
	img1.Image  =  GetPicture('navi/H011_navi_01.ccz');
	img1:SetScale(0.9,0.9)
	local img2 = rightPanel:GetLogicChild('img')
	img2.Image =  GetPicture('navi/H004_navi_01.ccz');
	img2:SetScale(0.9,0.9)
	--img.Image = GetPicture('union/zk_03.ccz');
	bg.Background = CreateTextureBrush('background/default_bg.jpg', 'background');
	
  --屏幕适配
  if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
    local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
    leftPanel:SetScale(factor,factor);
    rightPanel:SetScale(factor,factor);
    --间距也要相应的改变
    leftPanel.Translate = Vector2(250*(1-factor),0);
    rightPanel.Translate = Vector2(250*(factor-1),0);
    --roundPanel:SetScale(factor,factor);
	bottomPanel:SetScale(factor,factor);
	topPanel:SetScale(factor,factor);
  end
  panel.Visibility = Visibility.Visible;
end

function WorldScufflePanel:refreshRegisterBtn()
	registerBtn.Enable = true;
	if ScufflePanel.scuffleState == 0 then
		registerBtn.Text = LANG_scufflePanel_12;									
		registerBtn.Enable = false;                 
	elseif ScufflePanel.scuffleState == 1 then
		if ScufflePanel.selfState == 0 then
			registerBtn.Text = LANG_scufflePanel_13;
		else
			registerBtn.Text = LANG_scufflePanel_14;
			registerBtn.Enable = false;
		end											
	elseif ScufflePanel.scuffleState == 2 then
		registerBtn.Text = LANG_scufflePanel_15;
	elseif ScufflePanel.scuffleState == 3 then
		registerBtn.Text = LANG_scufflePanel_12;									
		registerBtn.Enable = false; 
	end
end

function WorldScufflePanel:isShow()
  return panel.Visibility == Visibility.Visible
end
function WorldScufflePanel:destroyScuffleStartTimer()
	if scuffleStartTimer ~= 0 then
		timerManager:DestroyTimer(scuffleStartTimer);
		scuffleStartTimer = 0;
	end
end
--刷新
function WorldScufflePanel:onShow()
	--print('worldScufflePanel->')
	
	if ScufflePanel.scuffleTime > 0 then
		if scuffleStartTimer ~= 0 then
			timerManager:DestroyTimer(scuffleStartTimer);
			scuffleStartTimer = 0;
		end
		WorldScufflePanel:refreshStartTime()
		scuffleStartTimer = timerManager:CreateTimer(1, 'WorldScufflePanel:refreshStartTime', 0);
	else
		if ScufflePanel.scuffleState == 0 then
			timeLabel.Text = tostring(LANG_scufflePanel_21);
		elseif ScufflePanel.scuffleState == 3 then
			timeLabel.Text = tostring(LANG_scufflePanel_22);
			ScufflePanel:scuffleEndTimeTip();
		else
			ScufflePanel:reqScuffleState()
		end
	end
	WorldScufflePanel:refreshRegisterBtn();
	--if not ScufflePanel:isScuffleShow() then
		--self:Show();
	--end
	
end

function WorldScufflePanel:onDestroy()
  panel:GetLogicChild("bg").Background = nil;
  DestroyBrushAndImage('background/default_bg.jpg', 'background');
  StoryBoard:OnPopUI();
end

function WorldScufflePanel:onClose()
  panel.Visibility = Visibility.Hidden;
end

function WorldScufflePanel:Destroy()
  panel:DecRefCount();
  panel = nil;
end


function WorldScufflePanel:onReturn()
	self:destroyScuffleStartTimer()
    self:onClose();
end

function WorldScufflePanel:refreshStartTime()
	if ScufflePanel.scuffleTime > 0 then
		if ScufflePanel.scuffleState == 0 then
			timeLabel.Text = tostring(LANG_scufflePanel_16..' '..Time2HMSStr(ScufflePanel.scuffleTime));
		elseif ScufflePanel.scuffleState == 1 then	--报名时间段
			timeLabel.Text = tostring(LANG_scufflePanel_20..' '..Time2HMSStr(ScufflePanel.scuffleTime));
		elseif ScufflePanel.scuffleState == 2 then
			timeLabel.Text = tostring(LANG_scufflePanel_17..' '..Time2HMSStr(ScufflePanel.scuffleTime));
			ScufflePanel:refreshTime(ScufflePanel.scuffleTime);
		end
		ScufflePanel.scuffleTime = ScufflePanel.scuffleTime - 1;
	else
		if scuffleStartTimer ~= 0 then
			timerManager:DestroyTimer(scuffleStartTimer);
			scuffleStartTimer = 0;
		end
		--if ScufflePanel.scuffleState ~= 2 then
			ScufflePanel:reqScuffleState()
		--end
	end
end
--[[
function WorldScufflePanel:refreshTimeLabel(curTime)
	if curTime <= 17*3600 then
		if curTime < 16*3600 then
			timeLabel.Text = tostring(LANG_scufflePanel_16..' '..Time2HMSStr(16*3600 - curTime));
		else
			timeLabel.Text = tostring(LANG_scufflePanel_17..' '..Time2HMSStr(17*3600 - curTime));
		end
	else
		timeLabel.Text = LANG_scufflePanel_18;
	end
end
]]