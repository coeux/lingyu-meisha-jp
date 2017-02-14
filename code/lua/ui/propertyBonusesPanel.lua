--propertyBonusesPanel.lua
--=============================================================================================
--捐献界面

PropertyBonusesPanel =
{
	
};
local mainDesktop;
local panel;

local pbPanel; 	
local wingBtn;	
local petBtn;  	
local soulBtn;		
local gemBtn;		
local atrifactBtn;	
local runeBtn;
local closeBtn;		


--初始化
function PropertyBonusesPanel:InitPanel(desktop)
	--控件初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('propertyBonusesPanel'));
	panel.ZOrder = PanelZOrder.propertyBounses;
	panel.Visibility = Visibility.Hidden;
	panel:IncRefCount();
	
	pbPanel 	= panel:GetLogicChild('panel');
	wingBtn 	= pbPanel:GetLogicChild('wingBtn');
	petBtn  	= pbPanel:GetLogicChild('petBtn');
	soulBtn		= pbPanel:GetLogicChild('soulBtn');
	gemBtn		= pbPanel:GetLogicChild('gemBtn');
	atrifactBtn	= pbPanel:GetLogicChild('artifactBtn');
	runeBtn		= pbPanel:GetLogicChild('runeBtn');
	closeBtn	= pbPanel:GetLogicChild('closeBtn');
	wingBtn:SubscribeScriptedEvent('Button::ClickEvent', 'CardDetailPanel:onClickWing');
	petBtn:SubscribeScriptedEvent('Button::ClickEvent', 'PropertyBonusesPanel:showPet');
	soulBtn:SubscribeScriptedEvent('Button::ClickEvent', 'SoulPanel:onShow');		
	gemBtn:SubscribeScriptedEvent('Button::ClickEvent', 'CardDetailPanel:onClickGem');		
	atrifactBtn:SubscribeScriptedEvent('Button::ClickEvent', 'CuriosityPanel:onShow');	
	runeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'RuneHuntPanel:onShow');
	closeBtn:SubscribeScriptedEvent('Button::ClickEvent', 'PropertyBonusesPanel:onClose');
end
function PropertyBonusesPanel:showPet()
	if not PetModule.have_pet then
		Toast:MakeToast(Toast.TimeLength_Long, LANG_have_no_pet);
	else
		PetPanel:onShow();
		HomePanel:hideRolePanel();
	end
end
--销毁
function PropertyBonusesPanel:Destroy()
	panel:DecRefCount();
	panel = nil;
end

--显示
function PropertyBonusesPanel:Show()
	--if UserGuidePanel:IsInGuidence(UserGuideIndex.task11, 3) then
	--	UserGuidePanel:ShowGuideShade(PropertyBonusesPanel:getUserGuideGemBtn(), GuideEffectType.hand, GuideTipPos.right, '');
	--end
	panel.Visibility = Visibility.Visible;
end
function PropertyBonusesPanel:getUserGuideGemBtn()
	return gemBtn;
end
--隐藏
function PropertyBonusesPanel:Hide()
	panel.Visibility = Visibility.Hidden;
end

function PropertyBonusesPanel:onClose()
	self:Hide();
end
