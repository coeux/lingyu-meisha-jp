--thirtyDaysNotLoginRewardPanel.lua

--========================================================================
--thirtyDaysNotLoginRewardPanel

ThirtyDaysNotLoginRewardPanel =
{
	enterFromRoleLevelUp = false;
};


--初始化
function ThirtyDaysNotLoginRewardPanel:InitPanel( desktop )
	self.enterFromRoleLevelUp = false;

	self.mainDesktop 	= desktop;
	self.thirtyDaysNotLoginRewardPanel = Panel( desktop:GetLogicChild('thirtyDaysNotLoginRewardPanel') );
	self.thirtyDaysNotLoginRewardPanel:IncRefCount();
	self.thirtyDaysNotLoginRewardPanel.ZOrder = PanelZOrder.thirtyDaysNotLoginRewardPanel;
	self.bgPanel = self.thirtyDaysNotLoginRewardPanel:GetLogicChild('bgPanel');
	self.bgPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent','ThirtyDaysNotLoginRewardPanel:Hide');
	self.bgPanel.Background = CreateTextureBrush('qiandao/thirty_reward_bg.ccz', 'godsSenki');
end

--销毁
function ThirtyDaysNotLoginRewardPanel:Destroy()
	self.thirtyDaysNotLoginRewardPanel:DecRefCount();
	self.thirtyDaysNotLoginRewardPanel = nil;
end
function ThirtyDaysNotLoginRewardPanel:firstShow()
	self.enterFromRoleLevelUp = true;
	self:onShow();
end
function ThirtyDaysNotLoginRewardPanel:onShow()
	if UserGuidePanel:GetInGuilding() then
		self.enterFromRoleLevelUp = false;
		return                   
    end
	Network:Send(NetworkCmdType.req_get_thirtydays_notlogin_reward_t,{});
end
function ThirtyDaysNotLoginRewardPanel:getRewardReturn(msg)
	if msg.is_get_notlogin_reward then
		ActorManager.user_data.extra_data.is_get_notlogin_reward = msg.is_get_notlogin_reward;
		print('is_get_notlogin_reward->'..tostring(msg.is_get_notlogin_reward));
	end
	if msg.thirtydays_notlogin_reward then
		ActorManager.user_data.extra_data.thirtydays_notlogin_reward = msg.thirtydays_notlogin_reward;
		print('thirtydays_notlogin_reward->'..tostring(msg.thirtydays_notlogin_reward));
	end
	local reward = ActorManager.user_data.extra_data.thirtydays_notlogin_reward;
	for i = 1 , 7 do
		self.bgPanel:GetLogicChild(tostring(i)).Visibility = Visibility.Hidden;
	end
	local index = 0;
	for i = 1 , 7 do 
		local curState = string.sub(reward,i,i);
		if curState == '2' then
			if string.sub(reward,i+1,i+1) then
				local nextState = string.sub(reward,i+1,i+1)
				if nextState == '2' then
					self.bgPanel:GetLogicChild(tostring(i)).Visibility = Visibility.Visible;
				else
					self:playerGetEffect(i);
				end
			else
				self:playerGetEffect(i);
			end
			index = i;
		end
	end
	if index == 7 then
		ActorManager.user_data.extra_data.thirtydays_notlogin_reward = "";
	end
	self:Show();
end
function ThirtyDaysNotLoginRewardPanel:playerGetEffect(index)
	local effectArmature = ArmatureUI(uiSystem:CreateControl('ArmatureUI'))
	effectArmature.pick = false
	effectArmature.Horizontal = ControlLayout.H_CENTER
	effectArmature.Vertical = ControlLayout.V_CENTER
	effectArmature.Margin = Rect(-10,10,0,0);
	if tonumber(index) < 7 then
		effectArmature:SetScale(2.2,2.2);
		effectArmature:LoadArmature('putong1')
	else
		effectArmature:SetScale(2,2);
		effectArmature:LoadArmature('zuizhong1')
	end
	effectArmature:SetAnimation('play2')
	effectArmature:SetScriptAnimationCallback('ThirtyDaysNotLoginRewardPanel:playEffectEnd', index)
	self.bgPanel:GetLogicChild('a'..index).Visibility = Visibility.Visible;
	self.bgPanel:GetLogicChild('a'..index):RemoveAllChildren();
	self.bgPanel:GetLogicChild('a'..index):AddChild(effectArmature)
end
function ThirtyDaysNotLoginRewardPanel:playEffectEnd(armature, index)
	--self.bgPanel:GetLogicChild('a'..index).Visibility = Visibility.Hidden;
	--self.bgPanel:GetLogicChild(tostring(index)).Visibility = Visibility.Visible;
end
--显示
function ThirtyDaysNotLoginRewardPanel:Show()
	self.thirtyDaysNotLoginRewardPanel.Visibility = Visibility.Visible;
end

--隐藏
function ThirtyDaysNotLoginRewardPanel:Hide()
	self.thirtyDaysNotLoginRewardPanel.Visibility = Visibility.Hidden;
	if self.enterFromRoleLevelUp then
		TomorrowRewardPanel:showTomorrowReward()
	elseif not TomorrowRewardPanel:isGetAllReward() then
		TomorrowRewardPanel:firstShow();
	else
		DailySignPanel:firstEnterFromTomm();
	end
	self.enterFromRoleLevelUp = false;
end

