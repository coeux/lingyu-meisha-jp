--loveMaxPanel.lua
--=============================================
--个人信息面板
LoveMaxPanel = 
{
	roleList = {};		--爱恋满的英雄列表
	isGotoLovePanel = false;
	isRefreshLovePic = false;
	isInLoveGuide = true;
	flwRotateTimer = 0;
};

local loveSound;
local bigAngle;
local smallAngle;

function LoveMaxPanel:InitPanel(desktop)
	self.roleList = {};
	self.mainDesktop = desktop;
	loveSound = nil
	self.flwRotateTimer = 0;
	bigAngle = 0;
	smallAngle = 0;
	self.loveMaxPanel = desktop:GetLogicChild('loveMaxPanel');
	self.loveMaxPanel:IncRefCount();
	self.loveMaxPanel.Visibility = Visibility.Hidden;
	self.loveMaxPanel.ZOrder = PanelZOrder.loveMax;

	self.bgPic = self.loveMaxPanel:GetLogicChild('bgPic');
	self.bottomLabel = self.bgPic:GetLogicChild('bottomLabel');
	self.loveMaxPic = self.bgPic:GetLogicChild('loveMaxPic');
	self.closeBtn = self.bgPic:GetLogicChild('closeBtn');
	self.gotoBtn = self.loveMaxPanel:GetLogicChild('gotoBtn');
	self.rolePanel = self.bgPic:GetLogicChild('rolePanel');
	self.roleInfoPanel = customUserControl.new(self.rolePanel, 'cardHeadTemplate')
	self.bg = self.loveMaxPanel:GetLogicChild('bg');
	self.loveMaxPic.Visibility = Visibility.Hidden;
	self.bg.Visibility = Visibility.Hidden;
	--self.loveMaxPic.Image = GetPicture('dynamicPic/love_max.ccz');
	self.bgPic.Image = GetPicture('dynamicPic/love_background.ccz');
	self.closeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'LoveMaxPanel:onClose');
	self.gotoBtn:SubscribeScriptedEvent('Button::ClickEvent', 'LoveMaxPanel:onGotoLove');

	self.leftBigFlw  	= self.bgPic:GetLogicChild('leftBigFlw');
	self.leftSmallFlw 	= self.bgPic:GetLogicChild('leftSmallFlw');
	self.rightBigFlw	= self.bgPic:GetLogicChild('rightBigFlw');
	self.rightSmallFlw	= self.bgPic:GetLogicChild('rightSmallFlw');
end

function LoveMaxPanel:Destroy()
	if self.flwRotateTimer ~= 0 then
		timerManager:DestroyTimer(self.flwRotateTimer);
		self.flwRotateTimer = 0;
	end
	self.loveMaxPanel:DecRefCount();
	self.loveMaxPanel = nil;
end
function LoveMaxPanel:flwRotateUpdate()
	if bigAngle <= -360 then
		bigAngle = 0;
	end
	if smallAngle >= 360 then
		smallAngle = 0;
	end

	bigAngle = bigAngle - 3;
	smallAngle = smallAngle + 9;

	self.leftBigFlw.Skew = Vector2(bigAngle,bigAngle);
	self.leftSmallFlw.Skew = Vector2(smallAngle,smallAngle); 
	self.rightBigFlw.Skew = Vector2(bigAngle,bigAngle);	
	self.rightSmallFlw.Skew = Vector2(smallAngle,smallAngle);
end
function LoveMaxPanel:Show()
	self.isInLoveGuide = true;
	bigAngle = 0;
	smallAngle = 0;
	if self.flwRotateTimer ~= 0 then
		timerManager:DestroyTimer(self.flwRotateTimer);
		self.flwRotateTimer = 0;
	end
	self.flwRotateTimer = timerManager:CreateTimer(0.1 , 'LoveMaxPanel:flwRotateUpdate' , 0);
	if self.roleList and #self.roleList > 0 then
		self.roleInfoPanel.initWithPid(self.roleList[1].pid, 80);
		if self.roleList[1].pid == 0 then
			self.bottomLabel.Text = tostring(ActorManager.user_data.name);
		else
			local name = resTableManager:GetValue(ResTable.actor, tostring(self.roleList[1].resid), 'name');
			self.bottomLabel.Text = tostring(name);
		end
		self.loveMaxPanel.Visibility = Visibility.Visible;
		self.bg.Visibility = Visibility.Visible;
		self:loveMaxSound()
		if UserGuidePanel:IsInGuidence(UserGuideIndex.love, 2) and self.isInLoveGuide then
			self.isInLoveGuide = false;
			UserGuidePanel:ShowGuideShade(self.gotoBtn,GuideEffectType.hand,GuideTipPos.right,'', 0.3);
		end
		if UserGuidePanel:IsInGuidence(UserGuideIndex.love2, 1) and self.isInLoveGuide and LovePanel:IsRoleCanAttack(ActorManager:GetRoleFromResid(16)) then
			self.isInLoveGuide = false;
			UserGuidePanel:ShowGuideShade(self.gotoBtn,GuideEffectType.hand,GuideTipPos.right,'', 0.3);
		end
		UserGuidePanel:SetIsequipguide(false);
	end
end

function LoveMaxPanel:GetLoveGuide()
	return self.isInLoveGuide;
end

function LoveMaxPanel:onClose()
	table.remove(self.roleList, 1);
	if loveSound then
		soundManager:DestroySource(loveSound);
		roleSound = nil
	end
	if self.roleList and #self.roleList >0 then
		self.roleInfoPanel.initWithPid(self.roleList[1].pid, 80);
		if self.roleList[1].pid == 0 then
			self.bottomLabel.Text = tostring(ActorManager.user_data.name);
		else
			local name = resTableManager:GetValue(ResTable.actor, tostring(self.roleList[1].resid), 'name');   --partner.lvl.lovelevel + 1
			self.bottomLabel.Text = tostring(name);
		end
	else
		self.loveMaxPanel.Visibility = Visibility.Hidden;
		self.bg.Visibility = Visibility.Hidden;
	end
end

function LoveMaxPanel:onGotoLove()
	self:DestroyLoveSound()
	if self.roleList and #self.roleList > 0 then
		if not ActorManager:IsHavePartner(self.roleList[1].resid) then
			return 
		end
		self.isGotoLovePanel = true;
		self.isRefreshLovePic = true;
		self.loveMaxPanel.Visibility = Visibility.Hidden;
		self.bg.Visibility = Visibility.Hidden;
		-- FightOverUIManager:OnTryAgain();
		-- PveBarrierPanel:Hide()
		FightOverUIManager:OnBackToCity();
		HomePanel:onEnterHomePanel(false, self.roleList[1].resid);
		--设置人物详情及背景
		HomePanel:setPartnerInfo(self.roleList[1])
		HomePanel:HideRight();
		LovePanel:onShow(self.roleList[1].pid, function() HomePanel:ShowRight() end);
		table.remove(self.roleList, 1);
	end
end
function LoveMaxPanel:DestroyLoveSound()
	if loveSound then
		soundManager:DestroySource(loveSound);
		roleSound = nil
	end
end
function LoveMaxPanel:loveMaxSound()
	local loveSoundNum = resTableManager:GetValue(ResTable.actor,tostring(self.roleList[1].resid),'love_voice')
	self:DestroyLoveSound()
	if loveSoundNum then
		loveSound = SoundManager:PlayVoice( tostring(loveSoundNum))
	end
end
