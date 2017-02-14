--cardListPanel.lua
--========================================================================
--卡牌列表面板

CardListPanel =
	{
	};
	
--变量
local tagList =
	{
		lvlup = 1;
		upStar = 2;
		latent = 3;
		tianfu = 4; --104
	}
local clickEvent = 
	{
		'lvlup',
		'upStar',
		'latent',
		'tianfu',
	}
	
local allPanel;
--控件
local mainDesktop;

local radioButtonList = {}
local cardPanels = {};
local cardListPanel;
local cardList = {};
local hideDetail;
local worldLine2;
local Roleindex
local lvlupLabel, upStarLabel, latentLabel, tianfuLabel;

--初始化面板
function CardListPanel:InitPanel( desktop )
	--界面初始化
	mainDesktop = desktop;	
	cardListPanel = Panel(desktop:GetLogicChild('cardListPanel'));
	cardListPanel.ALwaysTop = false;
	cardListPanel:IncRefCount();
	cardListPanel.ZOrder = PanelZOrder.cardlist;
	cardListPanel.Visibility = Visibility.Hidden;
	local s_banzi1 = cardListPanel:GetLogicChild('banzi1');
	s_banzi1.Margin = Rect(594, 54, 0, 0);
	s_banzi1.Size = Size(462,571);
	s_banzi1.Background = CreateTextureBrush('home/home_cardLsit_bg.ccz','godsSenki');  
	local s_banzi2 = cardListPanel:GetLogicChild('banzi2');  
	local btnPanel = cardListPanel:GetLogicChild('btnPanel');
	local  closebtn = cardListPanel:GetLogicChild('closebanzi'); 
	radioButtonList.lvlup  =  btnPanel:GetLogicChild('upGradeBtn');                        --升级
	lvlupLabel = btnPanel:GetLogicChild('upGradeBtn'):GetLogicChild('UpGradeLabel');
	radioButtonList.upStar  = btnPanel:GetLogicChild('upStarBtn');                         --升星
    upStarLabel = radioButtonList.upStar:GetLogicChild('UpStarLabel');
    worldLine2 = cardListPanel:GetLogicChild('worldLine2');  
	radioButtonList.latent  = btnPanel:GetLogicChild('latentBtn');                          --潜力
	latentLabel = radioButtonList.latent:GetLogicChild('LatentLabel'); 
	radioButtonList.tianfu  = btnPanel:GetLogicChild('talentBtn');                          --天赋
	tianfuLabel = radioButtonList.tianfu:GetLogicChild('TalentLabel');

	cardPanels = {s_banzi1, s_banzi2, closebtn, btnPanel};
	closebtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardListPanel:closeCardPanel');	
	--点击事件绑定
	for name, btn in pairs(radioButtonList) do
		btn.Tag = tagList[name];
		btn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardListPanel:onChangeRadio');
	end
end

--销毁
function CardListPanel:Destroy()
	cardListPanel:DecRefCount();
end

function CardListPanel:getAllPanel(resid, roleinfo)
	self.resid = resid;
	self.roleinfo = roleinfo;
	local allPanel = {CardLvlupPanel,   --升级panel  
	                  CardRankupPanel,  --升星panel
	                  QianliPanel,      --潜力panel
	                  XinghunPanel};    --天赋panel   
	return allPanel;
end

function CardListPanel:IsShow()
	return cardListPanel.Visibility == Visibility.Visible;
end

--关闭当前panel
function CardListPanel:closeCardPanel()
	CardLvlupPanel:destoryLevelupSound()
	CardRankupPanel:destroyStarUpgradeSound()
	 HomePanel:RoleShow();
	 if hideDetail then 
	 	 CardDetailPanel:HideSelfPanel().Visibility = Visibility.Hidden;
	 end;
	 if self.roleinfo then
		 CardDetailPanel:Show(self.roleinfo.pid, self.roleinfo.resid);
	 end
	 cardListPanel.Visibility = Visibility.Hidden;	 
	 if  HomePanel:rolePanelInfo() then HomePanel:ListClick() end
     self:allPanelIsHidde();
end

--隐藏所有panel
function CardListPanel:allPanelIsHidde()
	local allPanel = CardListPanel:getAllPanel(self.resid,self.roleinfo);
     for i = 1, 4 do
     	if( allPanel[i].isShow)  then
           allPanel[i]:Hide();
     	end    
     end
end

function CardListPanel:setFontCheck()
	local worldTable = {lvlupLabel, upStarLabel, latentLabel, tianfuLabel};
	for i = 1, 4 do  
       worldTable[i].TextColor =  QuadColor(Color(0, 0, 0, 250));
       worldTable[i]:SetFont('huakang_30_miaobian');
	end
end

function CardListPanel:Show(showArg, s)
	HomePanel:destroyRoleSound()
	hideDetail = s;
	Roleindex = showArg; 
	self.roleinfo = ActorManager:GetRole(Roleindex);

	--判空
	if not self.roleinfo then
		return
	end
	self.resid = self.roleinfo.resid;
	radioButtonList['lvlup'].Selected = true;
	CardDetailPanel:HideSelfPanel().Visibility = Visibility.Hidden;
	cardListPanel.Visibility = Visibility.Visible;	
	if(not CardLvlupPanel.isShow) then
      	CardLvlupPanel:Show(self.resid, self.roleinfo); 
	end
	self.cardListPanel = cardListPanel;
	--  潜力
	if ActorManager.user_data.role.lvl.level < SystemTaskId[UserGuideIndex.propertyTask] then
		radioButtonList.latent.SelectedBrush = uiSystem:FindResource('cardlist_btn_duanlian_hui_0', 'godsSenki');
		radioButtonList.latent.UnSelectedBrush = uiSystem:FindResource('cardlist_btn_duanlian_hui_0', 'godsSenki');
		--radioButtonList.latent.ShaderType = IRenderer.Scene_GrayShader;
	else
		radioButtonList.latent.SelectedBrush = uiSystem:FindResource('cardlist_btn_duanlian_1', 'godsSenki');
		radioButtonList.latent.UnSelectedBrush = uiSystem:FindResource('cardlist_btn_duanlian_0', 'godsSenki');
		--radioButtonList.latent.ShaderType = IRenderer.Scene_NormalShader;
	end
	if UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and UserGuidePanel.isPropertyBegin then
		timerManager:CreateTimer(0.1, 'CardListPanel:onEnterUserGuilde', 0, true)
	elseif UserGuidePanel:IsInGuidence(UserGuideIndex.upstar, 1) then
		timerManager:CreateTimer(0.2, 'CardListPanel:GuideUpstarBtn', 0, true);
	end
	if UserGuidePanel:IsInGuidence(UserGuideIndex.talent, 1) then
		timerManager:CreateTimer(0.2, 'CardListPanel:GuideTalentBtn', 0, true);
	elseif ActorManager.user_data.userguide.isnew < UserGuideIndex['talent'] - 1 then 
		radioButtonList.tianfu.SelectedBrush = uiSystem:FindResource('cardlist_btn_gexing_hui_0', 'godsSenki');
		radioButtonList.tianfu.UnSelectedBrush = uiSystem:FindResource('cardlist_btn_gexing_hui_0', 'godsSenki');
		radioButtonList.tianfu.ShaderType = IRenderer.Scene_GrayShader;
	else
		radioButtonList.tianfu.SelectedBrush = uiSystem:FindResource('cardlist_btn_gexing_1', 'godsSenki');
		radioButtonList.tianfu.UnSelectedBrush = uiSystem:FindResource('cardlist_btn_gexing_0', 'godsSenki');
		radioButtonList.tianfu.ShaderType = IRenderer.Scene_NormalShader;
	end

	--更新角色进阶提示信息
	CardListPanel:UpdateRankUpTip();
	--更新角色天赋提示信息
	XinghunPanel:IsRoleStarTipShow(self.roleinfo)

	--更新角色潜力提示信息
	if QianliPanel:IsRoleCanAttributeUp(self.roleinfo) then
		CardListPanel:SetAttritubeState(true);
	else
		CardListPanel:SetAttritubeState(false);
	end	
end

function CardListPanel:onEnterUserGuilde(  )
	if UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and UserGuidePanel.isPropertyBegin then
		UserGuidePanel:ShowGuideShade( radioButtonList.latent,GuideEffectType.hand,GuideTipPos.right,'', 0)
	end
end

--更新进阶提示信息
function CardListPanel:UpdateRankUpTip()
	if CardRankupPanel:isRoleCanAdvance( self.roleinfo ) then
		cardListPanel:GetLogicChild('btnPanel'):GetLogicChild('upStarBtn'):GetLogicChild('tanhao').Visibility = Visibility.Visible;
	else
		cardListPanel:GetLogicChild('btnPanel'):GetLogicChild('upStarBtn'):GetLogicChild('tanhao').Visibility = Visibility.Hidden;
	end
end

--升阶引导按钮
function CardListPanel:GuideUpstarBtn()
	UserGuidePanel:ShowGuideShade( cardListPanel:GetLogicChild('btnPanel'):GetLogicChild('upStarBtn'),GuideEffectType.hand,GuideTipPos.right,'');
end

--天赋引导按钮
function CardListPanel:GuideTalentBtn()
	UserGuidePanel:ShowGuideShade(cardListPanel:GetLogicChild('btnPanel'):GetLogicChild('talentBtn'),GuideEffectType.hand,GuideTipPos.right,'');
end

--隐藏界面
function CardListPanel:Hide()		
	cardListPanel.Visibility = Visibility.Hidden;
end

--点击切换界面
function CardListPanel:onChangeRadio(Arg)
	local arg = UIControlEventArgs(Arg);	
	local tag = arg.m_pControl.Tag;
	CardListPanel:onChangePanel(tag)
end

function CardListPanel:onChangePanel(typeNum)
	if typeNum == tagList.tianfu and ActorManager.user_data.role.lvl.level < FunctionOpenLevel.talent then 
		local msId = MessageBox:ShowDialog(MessageBoxType.Ok, 'この機能はLv32で開放されます');
		MessageBox:SetQuedingShowName(msId,'OK');
		return 
	elseif typeNum == tagList.latent and ActorManager.user_data.role.lvl.level < SystemTaskId[UserGuideIndex.propertyTask] then 
		local msId = MessageBox:ShowDialog(MessageBoxType.Ok, 'この機能はLv27で開放されます');
		MessageBox:SetQuedingShowName(msId,'OK');
		return 
	end
	radioButtonList[tostring(clickEvent[typeNum])].Selected = true;
	self:allPanelIsHidde();                                  --先把所有关联的panel关闭
    if not HomePanel:rolePanelInfo() then HomePanel:ListClick() end                      
	if typeNum == tagList.lvlup then                             --升级
		CardLvlupPanel:Show(self.resid, self.roleinfo);    
		worldLine2.Visibility = Visibility.Visible;  
	elseif typeNum == tagList.upStar then                        --升星   
        worldLine2.Visibility = Visibility.Hidden;
        CardRankupPanel:Show(self.resid, self.roleinfo);
	elseif typeNum == tagList.latent then                        --潜力       
	    worldLine2.Visibility = Visibility.Hidden;        
		QianliPanel:Show(self.resid, self.roleinfo);
	elseif typeNum == tagList.tianfu then                        --天赋 
	    worldLine2.Visibility = Visibility.Visible;    
	    XinghunPanel:Show(self.resid, self.roleinfo);
	end
end

--设置天赋tip状态
function CardListPanel:SetTalentState(flag)
	--判断天赋功能是否开启
	if ActorManager.user_data.role.lvl.level < FunctionOpenLevel.talent then
		return 
	end

	--设置提示状态
	if flag then
		cardListPanel:GetLogicChild('btnPanel'):GetLogicChild('talentBtn'):GetLogicChild('tanhao').Visibility = Visibility.Visible;
	else
		cardListPanel:GetLogicChild('btnPanel'):GetLogicChild('talentBtn'):GetLogicChild('tanhao').Visibility = Visibility.Hidden;
	end
end

--设置潜力tip状态
function CardListPanel:SetAttritubeState(flag)
	--设置提示状态
	if flag then
		cardListPanel:GetLogicChild('btnPanel'):GetLogicChild('latentBtn'):GetLogicChild('tip').Visibility = Visibility.Visible;
	else
		cardListPanel:GetLogicChild('btnPanel'):GetLogicChild('latentBtn'):GetLogicChild('tip').Visibility = Visibility.Hidden;
	end
end
