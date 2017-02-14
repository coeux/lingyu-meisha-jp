--cardDetailPanel.lua
--========================================================================
--驴篓脜脝脕脨卤铆脙忙掳氓

CardDetailPanel =
	{
	};
	
--鲁拢脕驴
local colorList = 
{
	['1'] = QuadColor(Color(38,16,0,255));
	['2'] = QuadColor(Color(60,137,11,255));
	['3'] = QuadColor(Color(60,137,11,255));
	['4'] = QuadColor(Color(0,66,255,255));
	['5'] = QuadColor(Color(0,66,255,255));
	['6'] = QuadColor(Color(0,66,255,255));
	['7'] = QuadColor(Color(206,16,190,255));
	['8'] = QuadColor(Color(206,16,190,255));
	['9'] = QuadColor(Color(206,16,190,255));
	['10'] = QuadColor(Color(227,113,20,255));
	['11'] = QuadColor(Color(227,113,20,255));
	['12'] = QuadColor(Color(227,113,20,255));
	['13'] = QuadColor(Color(227,113,20,255));
	['14'] = QuadColor(Color(255, 0, 0, 255));
	['15'] = QuadColor(Color(255, 0, 0, 255));
	['16'] = QuadColor(Color(255, 0, 0, 255));
	['17'] = QuadColor(Color(255, 0, 0, 255));
}
--卤盲脕驴
local currentRole;

--驴脴录镁
local mainDesktop;
local cardDetailPanel;
local otherPanel;
local btnReturn;
local labelName;
local imgRank;
local fpLable;
local actRole;
local navi;
local imgEquipList = {};
local imgSkillList = {};
local loveList = {};
local btnLove;

local gemBtn;
local wingBtn;
local tipsBtn;
local typeNameLabel;
local typeLable;
local typeIcon;
local lvPro;
local getBtn;

local equipPanel;
local lovePanel;
local rewardPanel;
local skillPanel;

local getRolePanel;
local getPiecePanel;
local nameLabel;
local countLabel;
local countPro
local taskBtn1;
local taskBtn2;
local taskBtn3;
local taskList;
local closeBtn;
local haveLabel;
local totalLabel;
local bgImg;
local getRoleBtn;
local pieceImg;
local propertyBonusesbtn;

local scrollPanel   --  鐢ㄤ簬鏀炬墍鏈夎幏鍙栨柟寮忕殑scrollview
local stackPanel

local nohavePanel

local peiyangtbtn;
local changeroleBtn;
local commentCardBtn;

local peiyangtip;

local skillEnum = 
{
	'active1',  --无用项
	'active2',	--无用项
	'active3',	--无用项
	'active1',
	'active2',
	'passive1',
	'passive2',
	'passive3',
}

--鲁玫脢录禄炉脙忙掳氓
function CardDetailPanel:InitPanel( desktop )
	--卤盲脕驴鲁玫脢录禄炉

	--陆莽脙忙鲁玫脢录禄炉
	mainDesktop = desktop;	
	--cardDetailPanel = Panel(desktop:GetLogicChild('cardInfoPanel'));	
	cardDetailPanel = Panel(desktop:GetLogicChild('CardInfoPanel1'));
	cardDetailPanel.ZOrder = PanelZOrder.cardinfo;
	cardDetailPanel.Visibility = Visibility.Hidden;

	self.lovePanelSound = nil
	self.roleAnimationSound = nil
	

	otherPanel = cardDetailPanel:GetLogicChild('otherPanel');

	lovePanel = otherPanel:GetLogicChild('lovePanel');
	panel	= otherPanel:GetLogicChild('Panel');

	btnReturn = otherPanel:GetLogicChild('returnBtn');
	labelName = otherPanel:GetLogicChild('topPanel'):GetLogicChild('infoPanel'):GetLogicChild('cardName');
	imgRank = otherPanel:GetLogicChild('Panel'):GetLogicChild('lvPanel'):GetLogicChild('lv');
	fpLable = otherPanel:GetLogicChild('Panel'):GetLogicChild('contentPanel'):GetLogicChild('fightPowerPanel'):GetLogicChild('fightLable');
	actRole	= otherPanel:GetLogicChild('Panel'):GetLogicChild('armature');
	btnLove = otherPanel:GetLogicChild('lovePanel'):GetLogicChild('loveStrengthBtn');
    
    local s_train = otherPanel:GetLogicChild('Panel'):GetLogicChild('ShuxingBtn');          --脢么脨脭
	changeroleBtn = otherPanel:GetLogicChild('Panel'):GetLogicChild('changeroleBtn'); 
    s_train:SubscribeScriptedEvent('Button::ClickEvent', 'CardDetailPanel:onClickAttribute');
    commentCardBtn = otherPanel:GetLogicChild('Panel'):GetLogicChild('commentCardBtn');
    commentCardBtn:SubscribeScriptedEvent('Button::ClickEvent', 'CardDetailPanel:onClickComment');
    commentCardBtn.Visibility = Visibility.Hidden;

	peiyangtbtn = otherPanel:GetLogicChild('Panel'):GetLogicChild('PeiyangBtn');        --脜脿脩酶
    peiyangtbtn:SubscribeScriptedEvent('Button::ClickEvent', 'CardDetailPanel:inPutCardListPanel');
	propertyBonusesbtn = otherPanel:GetLogicChild('Panel'):GetLogicChild('propertyBonusesBtn');        --脜脿脩酶
    propertyBonusesbtn:SubscribeScriptedEvent('Button::ClickEvent', 'PropertyBonusesPanel:Show');
	propertyBonusesbtn.Text = LANG_CardDetailPanel_9;
	propertyBonusesbtn.Font = uiSystem:FindFont('huakang_24_Miaobian');
	propertyBonusesbtn.TextColor = QuadColor(Color(64, 64, 64, 255));
	
	peiyangtip = peiyangtbtn:GetLogicChild('tanhao');

	nohavePanel = otherPanel:GetLogicChild('Panel'):GetLogicChild('nohave');
  
	gemBtn = otherPanel:GetLogicChild('Panel'):GetLogicChild('gemBtn');
	gemBtn:SubscribeScriptedEvent('Button::ClickEvent', 'CardDetailPanel:onClickGem');      --卤娄脢炉
	wingBtn = otherPanel:GetLogicChild('Panel'):GetLogicChild('wingBtn');
	wingBtn:SubscribeScriptedEvent('Button::ClickEvent', 'CardDetailPanel:onClickWing'); 
	skillPanel = otherPanel:GetLogicChild('Panel'):GetLogicChild('skillPanel');
	skillPanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardDetailPanel:onClickSkill');
	lovePanel= otherPanel:GetLogicChild('lovePanel');
	lovePanel:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardDetailPanel:gotoLovePanel');
	equipPanel = otherPanel:GetLogicChild('Panel'):GetLogicChild('contentPanel');
	for i=1, 5 do
		equipPanel:GetLogicChild('itemPanel'..i):SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardDetailPanel:onClickEquip');
	end
	equipPanel:GetLogicChild('itemPanel6'):SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardDetailPanel:onClickSWeapon');
	tipsBtn = otherPanel:GetLogicChild('Panel'):GetLogicChild('tips');
	natureLabel = otherPanel:GetLogicChild('topPanel'):GetLogicChild('infoPanel'):GetLogicChild('nature');
	lvPro = otherPanel:GetLogicChild('Panel'):GetLogicChild('level');

	typeNameLabel = otherPanel:GetLogicChild('Panel'):GetLogicChild('typeName');
	typeLable	= otherPanel:GetLogicChild('Panel'):GetLogicChild('fightval');
	typeIcon	= otherPanel:GetLogicChild('Panel'):GetLogicChild('typeIcon1');
	getBtn = otherPanel:GetLogicChild('Panel'):GetLogicChild('GetBtn');

	getRolePanel = cardDetailPanel:GetLogicChild('getHeroPanel'):GetLogicChild(0)
	cardDetailPanel:GetLogicChild('getHeroPanel').Visibility = Visibility.Hidden
	getPiecePanel = getRolePanel:GetLogicChild('piecePanel');
	nameLabel = getRolePanel:GetLogicChild('name');        --  纰庣墖鍚嶅瓧
	countLabel = getRolePanel:GetLogicChild('count');
	getRoleBtn = getRolePanel:GetLogicChild('getBtn');     --  鑾峰彇鎸夐挳
	countPro = getRolePanel:GetLogicChild('countPro');     --  鑾峰彇鑻遍泟鐨勮繘搴?
	closeBtn = getRolePanel:GetLogicChild('close');
	haveLabel = getRolePanel:GetLogicChild('have');      --  宸茬粡鎷ユ湁鐨勮嫳闆勭殑纰庣墖鏁伴噺
	totalLabel = getRolePanel:GetLogicChild('total');    --  鑾峰緱鑻遍泟闇€瑕佺殑鑻遍泟鐨勭鐗囨暟閲?
	scrollPanel = getRolePanel:GetLogicChild('scrollPanel')
	stackPanel = scrollPanel:GetLogicChild('getWayList')
	closeBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardDetailPanel:roleCloseClick');
	
	otherPanelBg = panel:GetLogicChild('bg');
	loveImg 	 = lovePanel:GetLogicChild('loveImg');
	otherPanelBg.Background = CreateTextureBrush('home/home_card_info_bg.ccz','godsSenki');
	lovePanel.Background = CreateTextureBrush('love/love_btn_bg.ccz','godsSenki');
	skillPanel.Background = CreateTextureBrush('home/home_card_skill_bg.ccz','godsSenki');

	bgImg = cardDetailPanel:GetLogicChild('bg');
	bgImg.Visibility = Visibility.Hidden;
	taskList = {};
	
	for i=1, 6 do
		local t = otherPanel:GetLogicChild('Panel'):GetLogicChild('contentPanel'):GetLogicChild('itemPanel' .. i);
		
		imgEquipList[i] = t;
	end
	for i=1, 5 do
		local t2 = otherPanel:GetLogicChild('Panel'):GetLogicChild('skillPanel'):GetLogicChild('skill' .. i);
		imgSkillList[i] = t2;
	end
	
	btnReturn:SubscribeScriptedEvent('Button::ClickEvent', 'CardDetailPanel:onBack');
	btnLove:SubscribeScriptedEvent('Button::ClickEvent', 'CardDetailPanel:gotoLovePanel');
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		cardDetailPanel:SetScale(factor,factor);
		cardDetailPanel.Translate = Vector2(532*(1-factor)/2,447*(1-factor)/2);
	end
end

--脧煤禄脵
function CardDetailPanel:Destroy()
	cardDetailPanel = nil;
end

function CardDetailPanel:HideSelfPanel()
	 return cardDetailPanel;
end

function CardDetailPanel:inPutCardListPanel()     --脜脿脩酶脧碌脥鲁
	if(self.rolePid) then
		if not HomePanel:rolePanelInfo() then 
			HomePanel:ListClick() 
		end
        CardListPanel:Show(self.rolePid);	
        CardListPanel.cardListPanel:SetUIStoryBoard("storyboard.showUIBoard2");
        CardLvlupPanel:getSelfPanel():SetUIStoryBoard("storyboard.showUIBoard2");
	end 
end

function CardDetailPanel:getUserGuideBtn()
	return getBtn;
end

function CardDetailPanel:getUserGuideRoleBtn()
	return getRoleBtn;
end

function CardDetailPanel:setBtn(flag)
	if flag then
		getRoleBtn.Pick = false;
	else
		getRoleBtn.Pick = true;
	end
end

function CardDetailPanel:getUserGuideSkillupBtn()
	return skillPanel;
end

function CardDetailPanel:getUserGuidePropertyBonusesBtn()
	return propertyBonusesbtn;
end

function CardDetailPanel:onClickAttribute()       --驴篓脜脝脢么脨脭
	HomePanel:destroyRoleSound()
    if not HomePanel:rolePanelInfo() then HomePanel:ListClick() end
    local roleInfo;
	if ActorManager:IsHavePartner(self.resid ) or self.rolePid == 0 then
		roleInfo = ActorManager:GetRole(self.rolePid);
	else
	    roleInfo = ResTable:createRoleNoHave(self.rolePid);
	end
	cardPropertyPanel:Show(self.resid, roleInfo);
end

function CardDetailPanel:onClickComment()
	HomePanel:destroyRoleSound()
	local roleInfo;
	if ActorManager:IsHavePartner(self.resid) or self.rolePid == 0 then
		roleInfo = ActorManager:GetRole(self.rolePid);
		print("have role");
	else
		roleInfo = ResTable:createRoleNoHave(self.rolePid);
		print("dont have role");
	end
	
	CardCommentPanel:onReqCommentPanel(roleInfo);
end

function CardDetailPanel:onClickGem()
	GemPanel:onShow();
	--HomePanel:hideRolePanel();
end

function CardDetailPanel:onClickWing()
	--Toast:MakeToast(Toast.TimeLength_Long, '功能暂未开放,敬请期待');
	WingPanel:onShow();
	HomePanel:hideRolePanel();
end

--脧脭脢戮
function CardDetailPanel:Show(roleindex, resid)
	local roleImg = otherPanel:GetLogicChild('Panel'):GetLogicChild(0);
	roleImg.Image = GetPicture('home/home_rolediban.ccz');

	local roleindex = roleindex or 0;
    self.rolePid = roleindex;
    self.resid = resid or ActorManager.user_data.role.resid;

	if self.resid == ActorManager.user_data.role.resid and ActorManager.user_data.role.lvl.level >= 50 then
		changeroleBtn.Visibility = Visibility.Visible;
	else
		changeroleBtn.Visibility = Visibility.Hidden;
	end
	if not ActorManager:IsHavePartner(resid)and roleindex ~= 0  then
		currentRole = ResTable:createRoleNoHave(roleindex);
		getBtn.Visibility = Visibility.Visible;
		peiyangtbtn.Visibility = Visibility.Hidden;
		--propertyBonusesbtn.Visibility = Visibility.Hidden;
		getBtn.Tag = roleindex;
		equipPanel.Visibility = Visibility.Hidden;
		CardDetailPanel:ShowNohavePanel()
		nohavePanel.Visibility = Visibility.Visible;	
	else
		currentRole = ActorManager:GetRole(roleindex);
		if not currentRole then
			currentRole = ActorManager:GetRoleFromResid(resid);
		end
		if not currentRole then
			Debug.print("Error! there's no currentRole");
			Debug.print('currentRole error :resid = '  .. resid);
			Debug.print('currentRole error :pid = '  .. roleindex)
			Debug.print(debug.traceback());
		end
		getBtn.Visibility = Visibility.Hidden;
		peiyangtbtn.Visibility = Visibility.Visible;
		--propertyBonusesbtn.Visibility = Visibility.Visible;
		self:ShowEquip();
		equipPanel.Visibility = Visibility.Visible;	
		nohavePanel.Visibility = Visibility.Hidden;
	end
	--[[
	if roleindex == 0 then
		tipsBtn.Visibility = Visibility.Hidden;
		gemBtn.Visibility = Visibility.Visible;
		wingBtn.Visibility = Visibility.Visible;
	else
		tipsBtn.Visibility = Visibility.Visible;
		gemBtn.Visibility = Visibility.Hidden;
		wingBtn.Visibility = Visibility.Hidden;
	end
	]]
	typeLable.Text = tostring(currentRole.pro.fp); 
	if not currentRole.quality then
		currentRole.quality = currentRole.rank;
	end
	natureLabel.Image = GetPicture('cardRelated/home_quality_'.. currentRole.quality - 1 .. '.ccz')
	natureLabel.Size = Size(95,44);
	self:ShowSkill();
	CardDetailPanel:ShowInfo()

	--赂霉戮脻脳掳卤赂脳麓驴枚脣垄脨脗驴篓脜脝脙没鲁脝
	local equip_lvl = 100;
	for i=1, 5 do
		local equip_resid = currentRole.equips[tostring(i)].resid;
		local equip_rank = resTableManager:GetValue(ResTable.equip, tostring(equip_resid), 'rank');
		if equip_rank < equip_lvl then
			equip_lvl = equip_rank;
		end
	end
	local plus = 0;
	if equip_lvl <= 1 then
		plus = 0;
	elseif equip_lvl <= 3 then
		plus = equip_lvl - 2;
	elseif equip_lvl <= 6 then
		plus = equip_lvl - 4;
	elseif equip_lvl <= 9 then
		plus = equip_lvl - 7;
	elseif equip_lvl <= 13 then
		plus = equip_lvl - 10;
	elseif equip_lvl <= 17 then
		plus = equip_lvl - 14;
	end
	--print('name-->'..tostring(currentRole.name));
	local name = resTableManager:GetValue(ResTable.actor,tostring(self.resid),'name');
	labelName.Text = tostring(name or '').. ((plus==0) and '' or ('+' .. tostring(plus)));
	labelName.TextColor = colorList[tostring(equip_lvl)];

	imgRank.Text = tostring(currentRole.lvl.level);
	actRole:Destroy();
	local path = GlobalData.AnimationPath .. resTableManager:GetValue(ResTable.actor, tostring(currentRole.resid), 'path') .. '/';
	AvatarManager:LoadFile(path);
	actRole:LoadArmature(currentRole.actorForm);
	actRole:SetAnimation(AnimationType.f_idle);
	if currentRole.wingid ~= nil then
		actRole:SetAnimation(AnimationType.fly_idle);
		AddWingsToUIActor(actRole, wingid);
	end
	
	--脧脭脢戮脮没赂枚脙忙掳氓
	cardDetailPanel.Visibility = Visibility.Visible;

	if UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and UserGuidePanel.isPropertyBegin then
		timerManager:CreateTimer(0.1, 'CardDetailPanel:onEnterUserGuilde', 0, true)
	end
	HomePanel:UpdateCurentRole(resid, roleindex)

	if (CardRankupPanel:isRoleCanAdvance( currentRole ) or XinghunPanel:IsRoleStarTipShow(currentRole)) and (ActorManager:IsHavePartner(resid) or roleindex == 0) then
		peiyangtip.Visibility = Visibility.Visible;
	else
		peiyangtip.Visibility = Visibility.Hidden;
	end
	-- 适配
	if (appFramework.ScreenWidth/appFramework.ScreenHeight) < (960/640) then
		local factor = (appFramework.ScreenWidth*2)/(appFramework.ScreenHeight*3);
		cardDetailPanel:SetScale(factor,factor);
		cardDetailPanel.Translate = Vector2(532*(1-factor)/2,447*(1-factor)/2);
	end
end

function CardDetailPanel:onEnterUserGuilde(  )
	if UserGuidePanel:IsInGuidence(UserGuideIndex.propertyTask, 2) and UserGuidePanel.isPropertyBegin then
		UserGuidePanel:ShowGuideShade( peiyangtbtn,GuideEffectType.hand,GuideTipPos.right,'', 0)
	end
end

function CardDetailPanel:ShowInfo()
	local resid = currentRole.resid;
	if resid == 0 then
		resid = ActorManager.user_data.role.resid;
	end

	local dataInfo = resTableManager:GetValue(ResTable.actor, tostring(resid), {'hit_area','attribute','petphrase'});

	if not dataInfo then
		print('pid = ' .. resid .. ' has no data info from actor!')
		return;
	end
	if tonumber(dataInfo['hit_area']) == 15 then
		typeNameLabel.Text = LANG_CardDetailPanel_1;
	elseif tonumber(dataInfo['hit_area']) == 130 then
		typeNameLabel.Text = LANG_CardDetailPanel_2;
	elseif tonumber(dataInfo['hit_area']) == 260 then
		typeNameLabel.Text = LANG_CardDetailPanel_3;
	end
	lvPro.MaxValue =  currentRole.lvl.levelUpExp;
	lvPro.CurValue =  currentRole.lvl.curLevelExp;
	local lovelabel = otherPanel:GetLogicChild('lovePanel'):GetLogicChild('loveText');
	--lovelabel.Text = LANG_CardDetailPanel_Love[currentRole.lvl.lovelevel];
	lovelabel.Visibility = Visibility.Hidden;
	loveImg.Visibility = Visibility.Visible;
	loveImg.Image = GetPicture('love/love_btn_'..(currentRole.lvl.lovelevel == 0 and 1 or currentRole.lvl.lovelevel)..'.ccz');
	typeIcon.Image = GetPicture('login/login_icon_' .. dataInfo['attribute'] .. '.ccz');

	tipsBtn.Text = dataInfo['petphrase'];

	--是否攻略tips显示判断
	if LovePanel:IsRoleCanAttack(currentRole) then
		otherPanel:GetLogicChild('lovePanel'):GetLogicChild('tip').Visibility = Visibility.Visible;
	else
		otherPanel:GetLogicChild('lovePanel'):GetLogicChild('tip').Visibility = Visibility.Hidden;
	end
end
function CardDetailPanel:destroyRoleAnimationSound()
	if self.roleAnimationSound then
		soundManager:DestroySource(self.roleAnimationSound);
		self.roleAnimationSound = nil
	end
end
function CardDetailPanel:playAcotor()
	HomePanel:destroyRoleSound()
	local r = math.random(1, 5)
	local acotrInfo = 
	{
		AnimationType.attack,
		AnimationType.skill,
		AnimationType.skill2,
		AnimationType.chant,
		AnimationType.run,
	}
	if self.roleAnimationSound then
		soundManager:DestroySource(self.roleAnimationSound);
		self.roleAnimationSound = nil
	end
	local naviInfo = resTableManager:GetRowValue(ResTable.navi_main, tostring(currentRole.resid));
	if naviInfo['soundlist'] then
		local voiceNum = math.random(1,#naviInfo['soundlist'])
		self.roleAnimationSound = SoundManager:PlayVoice(naviInfo['soundlist'][voiceNum]);
	end
	actRole:LoadArmature(currentRole.actorForm);
	actRole:SetAnimation(tostring(acotrInfo[r]));
	actRole:SetScriptAnimationCallback('CardDetailPanel:actorEnd', 0);	
end

function CardDetailPanel:actorEnd()
	actRole:LoadArmature(currentRole.actorForm);
	actRole:SetAnimation(AnimationType.f_idle);
end

--Òþ²Ø
function CardDetailPanel:Hide()
	
	--Ïú»ÙÉú³ÉµÄ×Ô¶¨Òå¿Ø¼þ
	
	cardDetailPanel.Visibility = Visibility.Hidden;	
end

--ÏÔÊ¾×°±¸
function CardDetailPanel:ShowEquip()
	for i=1,5 do
		if currentRole.equips[tostring(i)] then
			local iconImg = imgEquipList[i]:GetLogicChild('img');
			iconImg.Image = GetPicture('icon/' .. currentRole.equips[tostring(i)].resid ..'.ccz');
			local equipsQua = resTableManager:GetValue(ResTable.equip, tostring(currentRole.equips[tostring(i)].resid), 'rank');
			imgEquipList[i].Image = GetPicture('home/head_frame_' .. equipsQua .. '.ccz');
			if EquipStrengthPanel:isCanAdvance(currentRole.equips[tostring(i)]) then
				imgEquipList[i]:GetLogicChild('tip').Visibility = Visibility.Visible;
			else
				imgEquipList[i]:GetLogicChild('tip').Visibility = Visibility.Hidden;
			end
		end	
	end
	imgEquipList[6]:RemoveAllChildren();
	imgEquipList[6].Image = GetPicture('home/sweapon_icon.ccz');
	local find_w = false;
	for id, weapon in pairs(ActorManager.user_data.functions.sweapon) do
		if weapon.pid == currentRole.pid then
			local img = ImageElement(uiSystem:CreateControl('ImageElement'));
			img.Horizontal = ControlLayout.H_CENTER;
			img.Vertical = ControlLayout.V_CENTER;
			img.Size = Size(60,60);
			img.AutoSize = false;
			local itemWeaponData = resTableManager:GetRowValue(ResTable.item, tostring(weapon.resid));
			img.Image = GetPicture('icon/'..itemWeaponData['icon']..'.ccz');
			imgEquipList[6]:AddChild(img);
			find_w = true;
			break;
		end
	end
	if not find_w then
		local brush = BrushElement(uiSystem:CreateControl('BrushElement'));
		brush.Horizontal = ControlLayout.H_CENTER;
		brush.Vertical = ControlLayout.V_CENTER;
		brush.Size = Size(30, 30);
		brush.Background = CreateTextureBrush('home/sweapon_blank.ccz', 'home');
		imgEquipList[6]:AddChild(brush);
	end
end

function CardDetailPanel:UpdateSWeapon()
	imgEquipList[6]:RemoveAllChildren();
	imgEquipList[6].Image = GetPicture('home/sweapon_icon.ccz');
	local find_w = false;
	for id, weapon in pairs(ActorManager.user_data.functions.sweapon) do
		if weapon.pid == currentRole.pid then
			local img = ImageElement(uiSystem:CreateControl('ImageElement'));
			img.Horizontal = ControlLayout.H_CENTER;
			img.Vertical = ControlLayout.V_CENTER;
			img.Size = Size(60,60);
			img.AutoSize = false;
			local itemWeaponData = resTableManager:GetRowValue(ResTable.item, tostring(weapon.resid));
			img.Image = GetPicture('icon/'..itemWeaponData['icon']..'.ccz');
			imgEquipList[6]:AddChild(img);
			find_w = true;
			break;
		end
	end
	if not find_w then
		local brush = BrushElement(uiSystem:CreateControl('BrushElement'));
		brush.Horizontal = ControlLayout.H_CENTER;
		brush.Vertical = ControlLayout.V_CENTER;
		brush.Size = Size(30, 30);
		brush.Background = CreateTextureBrush('home/sweapon_blank.ccz', 'home');
		imgEquipList[6]:AddChild(brush);
	end
end


function CardDetailPanel:ShowNohavePanel()
	local chipPro = nohavePanel:GetLogicChild('countPro');
	local curChipNum = nohavePanel:GetLogicChild('have');
	local allChipNum = nohavePanel:GetLogicChild('total');
	local piecePanel = nohavePanel:GetLogicChild('piecePanel');

	local it = customUserControl.new(piecePanel, 'itemTemplate');
	it.initWithInfo(currentRole.resid + 30000, -1, 75);
	local dataInfo = resTableManager:GetRowValue(ResTable.actor, tostring(currentRole.pid));
	local totalCount = dataInfo['hero_piece'];
	local chipId = 30000 + currentRole.pid;
	local chipItem = Package:GetChip(tonumber(chipId));
	if chipItem then
		allChipNum.Text = tostring(totalCount);
		curChipNum.Text = tostring(chipItem.count);
		chipPro.MaxValue = totalCount;
		chipPro.CurValue =  chipItem.count;
	else
		curChipNum.Text = tostring(0);
		allChipNum.Text = tostring(totalCount);
		chipPro.MaxValue = totalCount;
		chipPro.CurValue = 0;
	end
	chipPro.MaxValue =  totalCount;
	if not chipItem or chipItem.count < totalCount then
		curChipNum.TextColor = QuadColor( Color(232, 37, 74,255) );
	else
		curChipNum.TextColor = QuadColor( Color(146, 227, 0, 255) );
	end

end

--ÏÔÊ¾¼¼ÄÜ
function CardDetailPanel:ShowSkill()
	local i = 1;
	for _,skill in ipairs(currentRole.skls) do
		local requireRank = 5;
		if i <= 5 then
			local index = 1;
			while(currentRole.skls[index] and currentRole.skls[index].resid ~= skill.resid) do
				index = index + 1;
			end

			local isfindrank = false;
			for rank=1, 5 do
				if not isfindrank then
					local skillinfo = resTableManager:GetRowValue(ResTable.qualityup_attribute, tostring(currentRole.resid * 100 + rank));
					for _,typeindex in ipairs (skillEnum) do	
						if skillinfo[typeindex] == skill.resid then
							requireRank = rank;
							isfindrank = true;
							break;
						end
					end
				end
			end
			local skillLabel = imgSkillList[i]:GetLogicChild('img');
			local skillsuo = imgSkillList[i]:GetLogicChild('suo');
			local skilltip = imgSkillList[i]:GetLogicChild('tip');
			skillsuo.Visibility = Visibility.Hidden;
			skilltip.Visibility = Visibility.Hidden;
			if skill.resid == 0 then
				skillLabel.Visibility = Visibility.Hidden;
			else
				local skillInfo = resTableManager:GetRowValue(ResTable.skill, tostring(skill.resid));
				if not skillInfo then
					skillInfo = resTableManager:GetRowValue(ResTable.passiveSkill, tostring(skill.resid));
				end
				if currentRole.rank < requireRank and (ActorManager:IsHavePartner(currentRole.resid) or currentRole.pid == 0) and skillInfo['next_skill'] ~= 0 then 
					skillsuo.Visibility = Visibility.Visible;
				elseif SkillStrPanel:IsCanAdv(skill.resid, currentRole) and (ActorManager:IsHavePartner(currentRole.resid) or currentRole.pid == 0) then 
					skilltip.Visibility = Visibility.Visible;
				end
				
				skillLabel.Image = GetIcon(skillInfo['icon']);
				skillLabel.Visibility = Visibility.Visible;
				imgSkillList[i].Image = GetPicture('home/home_dikuang' .. skillInfo['quality'] - 1 .. '.ccz');
				i = i + 1;
			end
		end
	end
end

--ÏÔÊ¾°®Áµ¶È½ø¶È
function CardDetailPanel:ShowLove()
	for i=1, 4 do
		loveList[i].initWithRole(currentRole, i);
		loveList[i].setBtnTag(currentRole.pid);
	end
end

--ÊÂ¼þ
function CardDetailPanel:onBack()
	self:Hide();
--	CardListPanel:Show();
--	HomePanel:Show();
end

function CardDetailPanel:refreshFp()
	typeLable.Text = tostring(currentRole.pro.fp); 
end

function CardDetailPanel:onClickLovePhase(Arg)
	local arg = UIControlEventArgs(Arg);	
	local pid = arg.m_pControl.Tag;
	
	otherPanel.Visibility = Visibility.Hidden;
	navi.setRoleVisible(false);
	LovePanel:SetPid(pid);
	local role = ActorManager:GetRole(pid);
	local plot_id = resTableManager:GetValue(ResTable.love_task, tostring(role.resid * 100 + role.lvl.lovelevel), 'plot_id');
	TaskDialogPanel:LoveTaskDialogFromCardPanel(plot_id);	
end

function CardDetailPanel:backToPanel()
	otherPanel.Visibility = Visibility.Visible;
	navi.setRoleVisible(true);
end

function CardDetailPanel:gotoLovePanel()
	if not ActorManager:IsHavePartner(currentRole.resid) then
		return 
	end
	self.lovePanelSound = SoundManager:PlayEffect( 'v1100' )
	HomePanel:HideRight();
	LovePanel:onShow(currentRole.pid, function() HomePanel:ShowRight() end);	
end

function CardDetailPanel:setKanban()
	if ActorManager:IsHavePartner(NaviLogic:getResid()%10000) then
		if ActorManager.user_data.userguide.isnew >= UserGuideIndex.equip then
			local msg = {};
			msg.uid = ActorManager.user_data.uid;
			msg.resid = NaviLogic:getResid();
			msg.type = 1;
			Network:Send(NetworkCmdType.req_set_kanban_role, msg);

			local name = ActorManager:GetRoleFromResid(NaviLogic:getResid()%10000).name;
			Toast:MakeToast(Toast.TimeLength_Long, name .. LANG_CardDetailPanel_6);
		else
			Toast:MakeToast(Toast.TimeLength_Long, LANG_CardDetailPanel_8);
		end
	else
		Toast:MakeToast(Toast.TimeLength_Long, LANG_CardDetailPanel_7);
	end
--	ActorManager:setKanbanRole(ActorManager:getIndexFromRole(currentRole));
	--[[
	if ActorManager:IsHavePartner(currentRole.resid) then
		ActorManager:setKanbanRole(currentRole.resid);
		local msg = {};
		msg.uid = ActorManager.user_data.uid;
		msg.resid = currentRole.resid;
		if HomePanel.changeNaviTimes == 0 then
			--1表示未婚，2表示已婚
			msg.type = (currentRole.lvl.lovelevel == 4) and 2 or 1;
		else
			if math.mod(HomePanel.changeNaviTimes,2) == 0 then
				msg.type = 2;
			else
				msg.type = 1;
			end
		end
		Network:Send(NetworkCmdType.req_set_kanban_role, msg);

		Toast:MakeToast(Toast.TimeLength_Long, currentRole.name .. LANG_CardDetailPanel_6);
	end
	--]]
end

function CardDetailPanel:onRetKanbanInfo(msg)
	ActorManager:setKanbanRole(msg);
end
	
function CardDetailPanel:HideRight()
	lovePanel.Visibility = Visibility.Hidden;
	panel.Visibility = Visibility.Hidden;
end

function CardDetailPanel:ShowRight()
	lovePanel.Visibility = Visibility.Visible;
	panel.Visibility = Visibility.Visible;
end

function CardDetailPanel:isShow()
	return cardDetailPanel.Visibility == Visibility.Visible;
end

function CardDetailPanel:roleClick(arg, aim_role)
	local cur_role = aim_role or currentRole;
	HomePanel:destroyRoleSound()
	if  cur_role.pid == GuidePartner.hire and UserGuidePanel:IsInGuidence(UserGuideIndex.hire, 1) then
		UserGuidePanel:refreshUserGuideTask(4)
		--记录新手引导流失点
		NetworkMsg_GodsSenki:SendStatisticsData(UserGuideIndex.hire, 3);
	elseif  cur_role.pid == GuidePartner.hire1 and UserGuidePanel:IsInGuidence(UserGuideIndex.hire1, 2) then
		UserGuidePanel:refreshUserGuideTask(4)
		--记录新手引导流失点
		NetworkMsg_GodsSenki:SendStatisticsData(UserGuideIndex.hire1, 3);
	end
	local pidId = arg.m_pControl.Tag;
	bgImg.Visibility = Visibility.Visible;
	stackPanel:RemoveAllChildren()
	cardDetailPanel:GetLogicChild('getHeroPanel').Visibility = Visibility.Visible;
	cardDetailPanel.ZOrder = 2001;
	
	local it = customUserControl.new(getPiecePanel, 'itemTemplate');
	it.initWithInfo(cur_role.resid + 30000, -1, 80);

	local dataInfo = resTableManager:GetRowValue(ResTable.actor, tostring(pidId));
	local totalCount = dataInfo['hero_piece'];
	nameLabel.Text = dataInfo['name'];
	local chipId = 30000 + pidId;
	local taskBtnList = {}
	local taskInfo = resTableManager:GetRowValue(ResTable.item_path, tostring(chipId));
	local count = 1    --  统计所有获得碎片的途径
	while (taskInfo and taskInfo['path' .. count]) do
		count = count  + 1
	end
	count = count - 1
	for i=1,count do
		
		local btn = uiSystem:CreateControl('Button')
		btn.Size = Size(270, 40)
		taskBtnList[i] = btn
		stackPanel:AddChild(taskBtnList[i])
	end

	for index = 1, 3 do
		getRolePanel:GetLogicChild('point'):GetLogicChild(tostring(index)).Visibility = Visibility.Hidden;
	end

	for index = 1,count do
		if taskInfo['path' .. index] ~= nil then
			getRolePanel:GetLogicChild('point'):GetLogicChild(tostring(index)).Visibility = Visibility.Visible;
	     	local typeCount = taskInfo['path' .. index][1]
	      	if typeCount == 1 then
				if taskInfo['path' .. index][2] <= 10 then
					taskBtnList[index].Pick = true
					taskBtnList[index].Font = uiSystem:FindFont('huakang_20_noborder_underline')
					taskBtnList[index].TextColor = QuadColor( Color(19, 169, 164,255)  )
					taskBtnList[index]:RemoveAllEventHandler()
					taskBtnList[index].Tag = taskInfo['path' .. index][2];
					taskBtnList[index]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardDetailPanel:GetMaterialPathItem')
				else
					--  通过关卡判断是否开启获取，需要获取所有掉落该英雄碎片的关卡，然后判断
					if taskInfo['path' .. index][2] > 1000 and taskInfo['path' .. index][2] < 5000 then     --普通关卡
						if ActorManager.user_data.round.openRoundId < taskInfo['path' .. index][2] then
							taskBtnList[index].Font = uiSystem:FindFont('huakang_20_noborder')
							taskBtnList[index].TextColor = QuadColor( Color(19, 169, 164,255)  )
							taskBtnList[index]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardDetailPanel:roundNotOpen')
						else
							taskBtnList[index].Tag = index
							taskBtnList[index]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardDetailPanel:TaskClick')
							taskList[index] = taskInfo['path' .. index][2]
						end
					elseif taskInfo['path' .. index][2] > 5000 then   --  精英关卡
						if ActorManager.user_data.round.elite_roundid < taskInfo['path' .. index][2] then
							taskBtnList[index].Font = uiSystem:FindFont('huakang_20_noborder')
							taskBtnList[index].TextColor = QuadColor( Color(19, 169, 164,255)  )
							taskBtnList[index]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardDetailPanel:roundNotOpen')
						else
							taskBtnList[index].Tag = index
							taskBtnList[index]:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardDetailPanel:TaskClick')
							taskList[index] = taskInfo['path' .. index][2]
						end
					end
		        end
		    elseif typeCount == 0 then
		    	taskBtnList[index].Pick = false
		        taskBtnList[index].Font = uiSystem:FindFont('huakang_20_noborder')
		        taskBtnList[index].TextColor = QuadColor(Color(0, 0, 0,255))
	      	end
	      	taskBtnList[index].Text = taskInfo['path_description' .. index]
	      	taskBtnList[index].Visibility = Visibility.Visible
    	else
      		taskBtnList[index].Visibility = Visibility.Hidden
    	end
	end
	stackPanel.VScrollPos = 0
	local chipItem = Package:GetChip(tonumber(chipId));
	if chipItem then
		totalLabel.Text = tostring(totalCount);
		haveLabel.Text = tostring(chipItem.count);
		countPro.CurValue =  chipItem.count;
	else
		totalLabel.Text = tostring(totalCount);
		haveLabel.Text = tostring(0);
		countPro.CurValue = 0;
	end
	countPro.MaxValue =  totalCount;
	getRoleBtn.Tag = cur_role.resid;
	getRoleBtn:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'CardDetailPanel:getRoleClick');
	if not ActorManager:IsHavePartner(cur_role.resid) then
		if not chipItem or chipItem.count < totalCount then
			haveLabel.TextColor = QuadColor( Color(232, 37, 74,255) );
			getRoleBtn.Enable = false;
		else
			haveLabel.TextColor = QuadColor( Color(146, 227, 0, 255) );
			getRoleBtn.Enable = true;
		end
	end
end

function CardDetailPanel:GetMaterialPathItem( args )
	CardDetailPanel:roleCloseClick();
	-- HomePanel:onLeaveHomePanel();
	local index = args.m_pControl.Tag;
	--  根据不同路径跳转到对应界面
	if index == 1 then  --  抽卡
		MainUI:onYingLingDian();
	elseif index == 2 then    --  远征
		ExpeditionPanel:onShow();
	elseif index == 3 then  --  神秘商店
		-- NpcShopPanel:OpenNormalClick();
		ShopSetPanel:show(ShopSetType.mysteryShop)
	elseif index == 4 then  --  远征商店
		if ActorManager.user_data.role.lvl.level >= FunctionOpenLevel.expedition then
			ShopSetPanel:show(ShopSetType.expeditionShop)
			-- ExpeditionShopPanel:onShow();
		else
			ExpeditionShopPanel:ShowUnOpenTips();
		end
	elseif index == 5 then  --  竞技场商店
		ShopSetPanel:show(ShopSetType.pvpShop)
		-- PrestigeShopPanel:onShow(Prestige_shoptype.normal);
	elseif index == 6 then  --  商城
		MainUI:onShopClick();
	elseif index == 7 then  --  探宝
		TreasurePanel:onShowTreasure();
	elseif index == 8 then  --  试炼
		PropertyRoundPanel:onShow();
	elseif index == 9 then	-- 每日任务
		PlotTaskPanel:onShow();
	elseif index == 10 then  --世界boss
		MainUI:onWorldClick();
	end
end


function CardDetailPanel:roundNotOpen(  )
	Toast:MakeToast(Toast.TimeLength_Long,LANG_FUBEN_NOT_OPEN)
end

function CardDetailPanel:TaskClick(args)
	cardDetailPanel.ZOrder = PanelZOrder.cardinfo;
	cardDetailPanel:GetLogicChild('getHeroPanel').Visibility = Visibility.Hidden;
	bgImg.Visibility = Visibility.Hidden;
	HomePanel:onLeaveHomePanel()
	local index = args.m_pControl.Tag;
	PveBarrierPanel:OpenToPage(taskList[index]);
end

function CardDetailPanel:roleCloseClick()
	cardDetailPanel.ZOrder = PanelZOrder.cardinfo;
	bgImg.Visibility = Visibility.Hidden;
	cardDetailPanel:GetLogicChild('getHeroPanel').Visibility = Visibility.Hidden;
end

function CardDetailPanel:getRoleClick(arg)
	CardDetailPanel:setBtn(true);
	local pidId = arg.m_pControl.Tag;
	local msg = {};
	msg.resid = pidId;
	Network:Send(NetworkCmdType.req_hire_partner, msg);
end

function CardDetailPanel:onClickSkill()
	SoundManager:onUIClick();
	SkillStrPanel:Show(currentRole.resid);
end

function CardDetailPanel:onClickEquip()
	if ActorManager:IsHavePartner(currentRole.resid) or currentRole.pid == 0 then
		EquipStrengthPanel:Show(currentRole.pid);
	end
end

function CardDetailPanel:onClickSWeapon()
	if ActorManager:IsHavePartner(currentRole.resid) or currentRole.pid == 0 then
		SWeaponPanel:onShow(currentRole.pid);
	end
end

function CardDetailPanel:GetPeiyangBtn()
	return peiyangtbtn;
end

function CardDetailPanel:GetEquipBtn()
	return imgEquipList[1];
end

function CardDetailPanel:GetLoveBtn()
	return lovePanel;
end

