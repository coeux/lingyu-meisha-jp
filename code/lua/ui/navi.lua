--navi.lua
NaviLogic = {}

--变量
local isNaviOn;
local isNew;
local naviControl = nil;
local role_resid = nil;
local timeEventList = {};
local role_resid;
local switch_list = {};

function NaviLogic:initWithPanel(father)
	if naviControl then
		father:RemoveChild(naviControl.child);
		naviControl = nil;
	end
	naviControl = customUserControl.new(father, 'naviTemplate');
end

function NaviLogic:init(resid)
	--设置显示的人物id
	role_resid = resid;
	if switch_list[resid%10000] then
		role_resid = switch_list[resid%10000];
	end
	
	--设置应该显示的图像
	naviControl.setResid(resid);
end

function NaviLogic:switchNavi()
	if role_resid > 10000 then
		role_resid = role_resid - 10000;
	else
		role_resid = role_resid + 10000;
	end
	local key = role_resid % 10000;
	switch_list[key] = role_resid;
	naviControl.setResid(role_resid);
	if isNaviOn then
		self:Leave();
		self:Enter();
	end
end

function NaviLogic:getResid()
	if role_resid then
		return role_resid;
	else
		return ActorManager:getKanbanRole();
	end
end
 
function NaviLogic:Destroy()
	isNaviOn = false;
	naviControl = nil;
end

function NaviLogic:clear()
	for _,event in pairs(timeEventList) do
		if event.timer then
			timerManager:DestroyTimer(event.timer);
			event.timer = 0;
		end
		event.timecount = 0;
		event = {};
	end
end

function NaviLogic:Leave()
	if naviControl then
		naviControl.leave();
	end
	--清除事件
	self:clear();
	isNaviOn = false;
end

function NaviLogic:Enter()
	if role_resid then
		naviControl.enter();
	end
	--初始化事件
	timeEventList = {};
	for _, event in pairs(naviControl.getEventList()) do
		timeEventList[event.id] = {};
		timeEventList[event.id].timecount = 0;
	end
	isNaviOn = true;
end

function NaviLogic:setNaviState(flag)
	if flag then
		self:Enter();
	else
		self:Leave();
	end
end

function NaviLogic:getNaviState()
	return isNaviOn;
end

function NaviLogic:Click(touchx, touchy)
	if naviControl then
		if naviControl.touch(touchx, touchy) then
			HomePanel:addClickCount();
			if UserGuidePanel:IsInGuidence(UserGuideIndex.love, 2) then
				UserGuidePanel:ShowGuideShade(HomePanel:GetNaviBtn(),GuideEffectType.hand,GuideTipPos.right, '', 0.2);
				HomePanel:GuideNaviFlag(false);
			end
		end
	end
end
function NaviLogic:destroyNaviSound()
	naviControl.destroyNaviSound()
end
function NaviLogic:FireEvent(event)
	if 0 == timeEventList[event].timecount then
		timeEventList[event].timer = timerManager:CreateTimer(0.5, 'NaviLogic:FireEvent', event);
	end
	if not naviControl.fireEvent(event, timeEventList[event].timecount) then
		self:clearEvent(event);
	else
	end
	timeEventList[event].timecount = timeEventList[event].timecount + 0.5;
end

function NaviLogic:clearEvent(event)
	if timeEventList[event] and timeEventList[event].timer then
		timerManager:DestroyTimer(timeEventList[event].timer);
		timeEventList[event].timer = 0;
		timeEventList[event].timecount = 0;
		naviControl.clearEvent(event);
	end
end
