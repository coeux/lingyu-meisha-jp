--roleInfoPanel.lua

--========================================================================
--角色属性面板

RoleInfoPanel =
	{
		role			= nil;				--当前显示属性的角色

		equipList		= {};				--属性面板里的装备面板
		canUseEquipList	= {};				--可以使用的装备位置
	};

local equipItemCount	= 6;				--一页包含的物品数量

--变量
local bindTimer		= nil;				--绑定数据计时器
local equipState		= 0;				--状态（0表示身上没有装备，1表示有装备）

--控件
local mainDesktop;
local roleInfoPanel;

local armatureUI;
local enemyArmature;
local labelName;
local labelLevel;
local labelHp;
local labelAttack;
local labelAttackType;
local labelNormalDefence;
local labelMagicDefence;
local labelStormsHit;
local labelHit;
local labelMiss;
local lvEquip;
local labelEquipList = {};
local probExp;
local huobanListClip;
local huobanList;
local imageBodyEquipList = {};
local btnLeftPage;
local btnRightPage;
local btnOnekey;
local btnChange;
local btnFire;
local labelFightPoint;
local textElementQianLi;
local textElementQianLiFenmu;
local starList;
local btnWing;

local equipPanel;
local fatePanel;
local labelFateIntro;
local fateList = {};

--初始化面板
function RoleInfoPanel:InitPanel( desktop )

	--界面初始化
	self.role				= nil;			--当前显示属性的角色
	self.equipList			= {};			--属性面板里的装备面板
	self.canUseEquipList	= {};			--可以使用的装备位置

	bindTimer				= nil;			--绑定数据计时器
	equipState				= 0;			--状态（0表示身上没有装备，1表示有装备）


	--界面初始化
	mainDesktop = desktop;
	roleInfoPanel = Panel( desktop:GetLogicChild('roleInfoPanel') );
	roleInfoPanel:IncRefCount();
	roleInfoPanel.Visibility = Visibility.Hidden;

	--获取控件引用
	armatureUI = ArmatureUI( roleInfoPanel:GetLogicChild('background1'):GetLogicChild('armaturePos') );
	enemyArmature = ArmatureUI( roleInfoPanel:GetLogicChild('enemyArmature') );
	labelName = Label( roleInfoPanel:GetLogicChild('name') );
	labelLevel = Label( roleInfoPanel:GetLogicChild('level') );
	probExp = ProgressBar( roleInfoPanel:GetLogicChild('exp') );
	huobanListClip = TouchScrollPanel( roleInfoPanel:GetLogicChild('huobanListClip') );
	huobanList = StackPanel( huobanListClip:GetLogicChild('huobanList') );

	btnChange = Button( roleInfoPanel:GetLogicChild('change') );
	btnFire = Button( roleInfoPanel:GetLogicChild('fire') );
	labelFightPoint = Label( roleInfoPanel:GetLogicChild('fightPoint') );
	btnWing = Button(roleInfoPanel:GetLogicChild('background1'):GetLogicChild('wing'));
	starList = roleInfoPanel:GetLogicChild('star'):GetLogicChild('star');

	for i = 1, 5 do
		local itemCell = roleInfoPanel:GetLogicChild('background1'):GetLogicChild('bg' .. i);
		local equipBg = itemCell:GetLogicChild('bg');
		local jia = itemCell:GetLogicChild('jia');
		table.insert(imageBodyEquipList, {cell = itemCell, bg = equipBg, jia = jia});
	end

	equipPanel = Panel( roleInfoPanel:GetLogicChild('equipPanel') );
	labelHp = Label( equipPanel:GetLogicChild('hp') );
	labelStormsHit = Label( equipPanel:GetLogicChild('baoji') );
	labelHit = Label( equipPanel:GetLogicChild('mingzhong') );
	labelMiss = Label( equipPanel:GetLogicChild('shanbi') );
	labelAttack = Label( equipPanel:GetLogicChild('attack') );
	labelAttackType = Label( equipPanel:GetLogicChild('attackType') );
	labelNormalDefence = Label( equipPanel:GetLogicChild('phDefence') );
	labelMagicDefence = Label( equipPanel:GetLogicChild('magDefence') );
	lvEquip = ListView( equipPanel:GetLogicChild('equipList') );
	btnLeftPage = Button( equipPanel:GetLogicChild('leftPage') );
	btnRightPage = Button( equipPanel:GetLogicChild('rightPage') );
	btnOnekey = Button( equipPanel:GetLogicChild('onekey') );
	local qianLi = equipPanel:GetLogicChild('qianli');
	textElementQianLi = qianLi:GetLogicChild('qianlifenzi');
	textElementQianLiFenmu = qianLi:GetLogicChild('qianlifenmu');

	fatePanel = Panel( roleInfoPanel:GetLogicChild('fatePanel') );
	local fateStackPanel = Panel( fatePanel:GetLogicChild('fateScrollPanel'):GetLogicChild('fateStackPanel') );
	for i = 1, 4 do
		local fateInfo = RichTextBox(fateStackPanel:GetLogicChild(tostring(i)));
		table.insert(fateList, fateInfo);
	end
	labelFateIntro = Label( fatePanel:GetLogicChild('intro') );
end

--销毁
function RoleInfoPanel:Destroy()
	roleInfoPanel:DecRefCount();
	roleInfoPanel = nil;
end

--是否显示
function RoleInfoPanel:IsVisible()
	return roleInfoPanel:IsVisible();
end

--显示
function RoleInfoPanel:Show()
	--默认显示装备
	equipPanel.Visibility = Visibility.Visible;
	fatePanel.Visibility = Visibility.Hidden;
	btnChange.Text = LANG_roleInfoPanel_1;

	--记录老战斗力
	ActorManager.oldFP = ActorManager.user_data.fp;

	--添加角色
	self:AddRole();

	--滚动到开始
	huobanListClip:VScrollBegin();

	--强制刷新数据
	self:updateBind();

	--添加绑定数据计时器
	bindTimer = timerManager:CreateTimer(1, 'RoleInfoPanel:updateBind', 0);

	self.equipList = Package:GetAllEquipSortByType();
	self.canUseEquipList = {};

	--刷新背包里的装备
	self:RefreshEquipInBag();

	--解雇按钮显示
	if (SystemTaskId.pub + 1) > Task:getMainTaskId() then
		btnFire.Enable = false;
		btnOnekey.Enable = false;
	else
		btnFire.Enable = true;
		btnOnekey.Enable = true;
	end

	--显示属性界面
	mainDesktop:DoModal(roleInfoPanel);

	--增加UI弹出时候的效果
	StoryBoard:ShowUIStoryBoard(roleInfoPanel, StoryBoardType.ShowUI1);
end

--隐藏
function RoleInfoPanel:Hide()

	--战斗力改变
	FightPoint:ShowFP(ActorManager.user_data.fp - ActorManager.oldFP);
	ActorManager.oldFP = ActorManager.user_data.fp;

	--删除定时器
	timerManager:DestroyTimer(bindTimer);

	--解除绑定
	self:unBind();

	--删除角色
	self:RemoveRole();

	--隐藏属性界面
	--mainDesktop:UndoModal();

	--增加UI消失时的效果
	StoryBoard:HideUIStoryBoard(roleInfoPanel, StoryBoardType.HideUI1, 'StoryBoard::OnPopUI');

	--置空人物形象
	armatureUI:Destroy();

	--触发回收显存事件
	EventManager:FireEvent(EventType.RecoverDisplayMemory);

end

--添加角色
function RoleInfoPanel:AddRole()

	--排序伙伴
	table.sort(ActorManager.user_data.partners, sortPartner);

	--获取主角＋伙伴的总个数
	local roleCount = 1 + #(ActorManager.user_data.partners);

	--创建头像列表
	for i = 1, roleCount do
		local t = uiSystem:CreateControl('huobanInfoTemplate');
		local radioButton = RadioButton(t:GetLogicChild(0));
		radioButton.Visibility = Visibility.Visible;
		radioButton.GroupID = RadionButtonGroup.selectRoleInfoHuoBan;
		radioButton.Tag = i;
		--添加响应事件
		radioButton:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'RoleInfoPanel:onRoleClick');

		--获取控件
		local labelName = Label(radioButton:GetLogicChild('name'));
		local imgJob = ImageElement(radioButton:GetLogicChild('job'));
		local imgHeadPic = ItemCell(radioButton:GetLogicChild('image'));
		local imgInTeam = ItemCell(radioButton:GetLogicChild('inTeam'));
		local imgUP = ImageElement(radioButton:GetLogicChild('up'));

		--设置控件属性
		local actor = {};
		if 1 == i then
			--主角
			actor = ActorManager.user_data.role;
		else
			--伙伴
			actor = ActorManager.user_data.partners[i - 1];
		end
		labelName.Text = actor.name;
		labelName.TextColor = QualityColor[actor.rare];
		imgJob.Image = actor.jobIcon;
		imgHeadPic.Background = Converter.String2Brush( RoleQualityType[actor.rare] );
		imgHeadPic.Image = GetPicture('navi/' .. actor.headImage .. '.ccz');
		imgInTeam.Visibility = Visibility.Hidden;
		imgUP.Visibility = Visibility.Hidden;

		--添加到头像列表
		huobanList:AddChild(t);
	end

	if huobanList:GetLogicChildrenCount() ~= 0 then
		local tt = huobanList:GetLogicChild(0);
		local radioButton = RadioButton(tt:GetLogicChild(0));
		radioButton.Selected = true;
	end

end

--删除角色
function RoleInfoPanel:RemoveRole()
	huobanList:RemoveAllChildren();
	self.role = nil;
end

--解雇角色
function RoleInfoPanel:FireRole( pos )
	local uiHuoBan = huobanList:GetLogicChild(pos-1);
	huobanList:RemoveChild(uiHuoBan);
	huobanList:ForceLayout();
	huobanListClip:ReChangeScrollBarPos();

	--重置后面的位置
	for i = pos, huobanList:GetLogicChildrenCount() do
		local ui = huobanList:GetLogicChild(i - 1);
		ui:GetLogicChild(0).Tag = i;
	end

	uiHuoBan = huobanList:GetLogicChild(pos-1);
	if uiHuoBan == nil then
		pos = pos - 1;
		uiHuoBan = huobanList:GetLogicChild(pos-1);
	end
	local radioButton = RadioButton(uiHuoBan:GetLogicChild(0));
	radioButton.Selected = true;
end

--刷新伙伴进阶
function RoleInfoPanel:RefreshRoleQualityUp( pid )
	if (self.role ~= nil) and (self.role.pid == pid) then
		local radioButton = UISystem.GetSelectedRadioButton(RadionButtonGroup.selectRoleInfoHuoBan);
		if radioButton ~= nil then
			self:SetRole(radioButton.Tag);
		end
	end
end

--获取滚动位置
function RoleInfoPanel:GetVScrollPos()
	return huobanListClip.VScrollPos;
end

--设置角色属性
function RoleInfoPanel:SetRole( index )

	self:unBind();

	--设置数据
	if 1 == index then
		--主角
		self.role = ActorManager.user_data.role;

		btnWing.Visibility = Visibility.Visible;
	else
		--伙伴
		self.role = ActorManager.user_data.partners[index - 1];

		btnWing.Visibility = Visibility.Hidden;
	end

	--刷新形象
	self:RefreshArmature()

	self:RefreshQianliFenmu();

	--刷新身上装备
	self:RefreshEquipInBody();

	self:RefreshFate();

	self:bind();

	--刷新一次数据
	self:updateBind();

end

function RoleInfoPanel:RefreshFate()
	local actorData = resTableManager:GetRowValue(ResTable.actor, tostring(self.role.resid));
	labelFateIntro.Text = actorData['hero_story'];
	local fateIdList = {};
	for i = 1, 4 do
		local id = actorData['destiny' .. i];
		table.insert(fateIdList, id);
	end

	local font = uiSystem:FindFont('huakang_20');

	for i = 1, 4 do
		local fateId = fateIdList[i];
		if fateId == 0 then
			fateList[i].Visibility = Visibility.Hidden;
		else
			fateList[i].Visibility = Visibility.Visible;
			fateList[i]:Clear();

			local fateData = resTableManager:GetRowValue(ResTable.destiny, tostring(fateId));
			fateList[i]:AppendText(fateData['name'] .. '：', QualityColor[fateData['rare']], font);
			fateList[i]:AppendText(LANG_roleInfoPanel_2, QuadColor(Color.White), font);

			local anyHeroCount = 0;		--任意英雄个数
			local heroId;
			local heroData;
			local isFirst = true;
			for index = 1,5 do
				heroId = fateData['hero' .. index];
				--触发英雄与该英雄相同时不处理
				if heroId ~= self.role.resid then
					if heroId == -1 then
						anyHeroCount = anyHeroCount + 1;
					elseif heroId ~= 0 then
						if not isFirst then
							fateList[i]:AppendText('、', QuadColor(Color.White), font);
						end
						isFirst = false;
						heroData = resTableManager:GetRowValue(ResTable.actor, tostring(heroId));
						fateList[i]:AppendText(heroData['name'], QualityColor[heroData['rare']], font);
					end
				end
			end

			if anyHeroCount >= 2 then
				--按规则减1
				anyHeroCount = anyHeroCount - 1;
				if not isFirst then
					fateList[i]:AppendText('、', QuadColor(Color.White), font);
				end
				isFirst = false;
				fateList[i]:AppendText(LANG_roleInfoPanel_3 .. anyHeroCount ..LANG_roleInfoPanel_4, QuadColor(Color.White), font);
			end

			fateList[i]:AppendText(LANG_roleInfoPanel_5, QuadColor(Color.White), font);
			local fateEffect = fateData['effect'];
			if fateEffect == 1  and actorData['job'] == JobType.magician then
				fateEffect = 8;
			end
			fateList[i]:AppendText(FatePropertyTypeName[fateEffect] .. '+', QuadColor(Color.White), font);
			fateList[i]:AppendText(tostring(math.floor(fateData['effect_value'] * 100)) .. '%', QuadColor(Color.White), font);

			fateList[i]:ForceLayout();
			if fateList[i]:GetLogicChildrenCount() <= 2 then
				fateList[i].Height = 51;
			else
				fateList[i].Height = 77;
			end
		end
	end
end

--刷新伙伴的潜力最大值
function RoleInfoPanel:RefreshQianliFenmu()
	textElementQianLiFenmu.Text = '/' .. resTableManager:GetValue(ResTable.potential_caps, tostring(self.role.lvl.level), 'caps');
end

--刷新形象
function RoleInfoPanel:RefreshArmature()

	local avatarName;
	if (self.role.pid == 0) and (self.role.equips[EquipmentPos.weapon] ~= nil) then
		local sex = resTableManager:GetValue(ResTable.actor, tostring(self.role.resid), 'gender');
		local key = self.role.equips[EquipmentPos.weapon].resid .. '_' .. sex;
		local path = GlobalData.AnimationPath .. resTableManager:GetValue(ResTable.avatar, key, 'path') .. '/';
		AvatarManager:LoadFile(path);
		avatarName = resTableManager:GetValue(ResTable.avatar, key, 'img');
	else
		local path = GlobalData.AnimationPath .. resTableManager:GetValue(ResTable.actor, tostring(self.role.resid), 'path') .. '/';
		AvatarManager:LoadFile(path);
		avatarName = resTableManager:GetValue(ResTable.actor, tostring(self.role.resid), 'img');
	end

	SoundManager:PlayVoice('v' .. tostring(self.role.resid));

	armatureUI:Destroy();
	armatureUI:LoadArmature(avatarName);
	armatureUI:SetAnimation(AnimationType.f_idle);

	-- 播放技能展示特效
	--self:ShowPlayerSkill(self.role.resid);

	--加载翅膀
	local wingData = self.role.wings;
	if (wingData ~= nil) and (#wingData > 0) then
		armatureUI:SetAnimation(AnimationType.fly_idle);
		AddWingsToUIActor(armatureUI, wingData[1].resid);
	end
end

-- 角色技能展示
function RoleInfoPanel:ShowPlayerSkill(resid)
	local playArmature = armatureUI;
	playArmature.Visibility = Visibility.Visible;

	local actorData = resTableManager:GetRowValue(ResTable.actor, tostring(resid));
	local path = GlobalData.AnimationPath .. actorData['path'] .. '/';
	AvatarManager:LoadFile(path);
	avatarName = actorData['img'];

	playArmature:LoadArmature(avatarName);
	playArmature:SetAnimation(AnimationType.f_idle);

	--enemyArmature:LoadArmature("bazi_output");
	--playArmature:SetAnimation(AnimationType.f_idle);
	playArmature:SetScriptAnimationCallback('RoleInfoPanel:OnSkillShowCallback', 0);

	local scriptName = actorData['skill_script'];

	LoadLuaFile('skillScript/' .. scriptName .. '.lua');			--加载手势技能脚本
	local skillScript = _G[scriptName];
	skillScript:preLoad();

	local effectScript = effectScriptManager:CreateEffectScript(scriptName);
	effectScript:SetArgs('Attacker', 100000);				--此参数代表此次攻击的ID，参数名称等测试完毕更改技能脚本
	effectScript:SetArgs('Targeter', -100000);				--临时用，代表使用此类中的敌方角色，以后更改技能脚本
	effectScript:TakeOff();										--执行

end

function RoleInfoPanel:OnSkillShowCallback()
	armatureUI.ZOrder = -100;
	armatureUI:SetAnimation(AnimationType.f_idle);
end

function RoleInfoPanel:OnClickPlayer()
	AvatarPosEffect:SetPlayerEnemyArmature(armatureUI, enemyArmature);
	self:ShowPlayerSkill(self.role.resid);
	armatureUI.ZOrder = 1000;
end

--刷新人物身上装备
function RoleInfoPanel:RefreshEquipInBody()

	for i = 1, 5 do
		local equip = self.role.equips[tostring(i)];
		local itemCell = imageBodyEquipList[i].cell;
		local equipBg = imageBodyEquipList[i].bg;
		local jiaIcon = imageBodyEquipList[i].jia;

		if equip == nil then
			itemCell.Image = nil;
			itemCell.Background = Converter.String2Brush(QualityType[0]);
			equipBg.Visibility = Visibility.Visible;
			jiaIcon.Visibility = Visibility.Visible;
		else
			local data = resTableManager:GetValue(ResTable.item, tostring(equip.resid), {'icon', 'quality'});
			itemCell.Image = GetPicture('icon/' .. data['icon'] .. '.ccz');
			itemCell.Background = Converter.String2Brush( QualityType[data['quality']] );
			equipBg.Visibility = Visibility.Hidden;
			jiaIcon.Visibility = Visibility.Hidden;
		end
	end

	--刷新一键按钮
	self:setOneKeyState();

	self:RefreshEquipInBag();

end

--刷新装备按钮
function RoleInfoPanel:refreshEquipButtonInBag()
	if lvEquip:GetLogicChildrenCount() > 1 then
		lvEquip.ShowPageBrush = true;
		btnLeftPage.Visibility = Visibility.Visible;
		btnRightPage.Visibility = Visibility.Visible;
	else
		lvEquip.ShowPageBrush = false;
		btnLeftPage.Visibility = Visibility.Hidden;
		btnRightPage.Visibility = Visibility.Hidden;
	end
end

--刷新背包里的装备
function RoleInfoPanel:RefreshEquipInBag()

	local pageIndex = lvEquip.ActivePageIndex;
	lvEquip:RemoveAllChildren();

	--取出背包数量的最大值
	local totalEquipCount = 0;
	for k, v in pairs(self.equipList) do
		if totalEquipCount < k then
			totalEquipCount = k;
		end
	end
	for k, v in pairs(self.canUseEquipList) do
		if totalEquipCount < k then
			totalEquipCount = k;
		end
	end

	local gridCount = math.ceil(totalEquipCount / equipItemCount);	--计算应该创建的grid页数
	local equipIndex = 1;												--向grid添加装备的index

	--没有东西就默认创建一个
	if totalEquipCount == 0 then
		gridCount = 1;
	end

	--创建grid
	for index = 1, gridCount do
		local grid = uiSystem:CreateControl('equipItemTemplate');
		local iconGrid = grid:GetLogicChild(0);

		lvEquip:AddChild(grid);

		for i = 1, equipItemCount do
			--获取控件
			local itemCell = ItemCell( iconGrid:GetLogicChild(tostring(i)) );
			self:initEquipItemCell(itemCell, equipIndex);

			equipIndex = equipIndex + 1;
		end
	end

	--刷新按钮
	self:refreshEquipButtonInBag();

	local count = lvEquip:GetLogicChildrenCount();
	if pageIndex ~= -1 then
		if pageIndex < count then
			lvEquip:SetActivePageIndexImmediate(pageIndex);
		end
	elseif count ~= 0 then
		lvEquip.ActivePageIndex = 0;
	end

end

--升序函数
function CompareRoleInfoUnUsedCell( pos1, pos2 )
	return pos1 < pos2;
end

--装备改变（先删除再增加，这样排的位置才对）
function RoleInfoPanel:EquipChange( msg )

	--删除
	for _,equip in ipairs(msg.del_equips) do

		local pos = -1;
		for k,v in pairs(self.equipList) do
			if equip.eid == v.eid then
				pos = k;
				break;
			end
		end

		if pos ~= -1 then
			self.equipList[pos] = nil;
			table.insert(self.canUseEquipList, pos);

			local userControl = lvEquip:GetLogicChild( math.ceil(pos / equipItemCount) - 1 );
			local iconGrid = userControl:GetLogicChild(0);
			local index = math.mod(pos, equipItemCount);
			if index == 0 then
				index = equipItemCount;
			end
			local itemCell = ItemCell( iconGrid:GetLogicChild( tostring(index) ) );

			--显示装备图标
			itemCell.Image = nil;
			itemCell.Background = Converter.String2Brush( QualityType[0] );

			local yinying = itemCell:GetLogicChild('yinying');
			local arrow = itemCell:GetLogicChild('arrow');

			yinying.Visibility = Visibility.Hidden;
			arrow.Visibility = Visibility.Hidden;
		end
	end

	table.sort(self.canUseEquipList, CompareRoleInfoUnUsedCell);


	--增加
	for _,equip in ipairs(msg.add_equips) do

		if #self.canUseEquipList ~= 0 then
			local pos = self.canUseEquipList[1];
			table.remove(self.canUseEquipList, 1);
			table.insert(self.equipList, pos, equip);
		else
			table.insert(self.equipList, equip);
		end

	end

	--只改变逻辑数据，穿脱装备的消息才刷新界面

end

--将控件显示与role角色属性绑定
function RoleInfoPanel:bind()
	uiSystem:Bind(DDXTYPE.DDX_STRING, self.role, 'fullName', labelName, 'Text');			    --绑定姓名
	uiSystem:Bind(DDXTYPE.DDX_INT, self.role.lvl, 'level', labelLevel, 'Text');			        --绑定等级
	uiSystem:Bind(DDXTYPE.DDX_INT, self.role.lvl, 'levelUpExp', probExp, 'MaxValue');		    --绑定当前升级所需经验
	uiSystem:Bind(DDXTYPE.DDX_INT, self.role.lvl, 'curLevelExp', probExp, 'CurValue');		    --绑定当前等级的经验
	uiSystem:Bind(DDXTYPE.DDX_INT, self.role.pro, 'hp', labelHp, 'Text');					    --绑定血量
	uiSystem:Bind(DDXTYPE.DDX_INT, self.role.pro, 'cri', labelStormsHit, 'Text');			    --绑定暴击值
	uiSystem:Bind(DDXTYPE.DDX_INT, self.role.pro, 'acc', labelHit, 'Text');				        --绑定命中值
	uiSystem:Bind(DDXTYPE.DDX_INT, self.role.pro, 'dodge', labelMiss, 'Text');				    --绑定闪避值
	uiSystem:Bind(DDXTYPE.DDX_INT, self.role.pro, 'def', labelNormalDefence, 'Text');		    --绑定普通防御
	uiSystem:Bind(DDXTYPE.DDX_INT, self.role.pro, 'res', labelMagicDefence, 'Text');		    --绑定魔法防御
	uiSystem:Bind(DDXTYPE.DDX_INT, self.role.pro, 'attack', labelAttack, 'Text');			    --绑定攻击
	uiSystem:Bind(DDXTYPE.DDX_STRING, self.role.pro, 'attackType', labelAttackType, 'Text');	--绑定攻击类型
	uiSystem:Bind(DDXTYPE.DDX_INT, self.role.pro, 'fp', labelFightPoint, 'Text');			    --绑定战力
	uiSystem:Bind(DDXTYPE.DDX_INT, self.role, 'potential', textElementQianLi, 'Text');			--绑定潜力
	--名字颜色
	labelName.TextColor = QualityColor[self.role.rare];

	--星级
	for i = 1, 5 do
		local star = starList:GetLogicChild(i-1);

		if self.role.quality >= i then
			star.Visibility = Visibility.Visible;
		else
			star.Visibility = Visibility.Collapsed;
		end
	end

end

--解除绑定
function RoleInfoPanel:unBind()

	if self.role == nil then
		return;
	end

	uiSystem:UnBind(self.role, 'fullName', labelName, 'Text');				--解除绑定姓名
	uiSystem:UnBind(self.role.lvl, 'level', labelLevel, 'Text');			--解除绑定等级
	uiSystem:UnBind(self.role.lvl, 'levelUpExp', probExp, 'MaxValue');		--解除绑定当前升级所需经验
	uiSystem:UnBind(self.role.lvl, 'curLevelExp', probExp, 'CurValue');		--解除绑定当前等级的经验
	uiSystem:UnBind(self.role.pro, 'hp', labelHp, 'Text');					--解除绑定血量
	uiSystem:UnBind(self.role.pro, 'cri', labelStormsHit, 'Text');			--解除绑定暴击值
	uiSystem:UnBind(self.role.pro, 'acc', labelHit, 'Text');				--解除绑定命中值
	uiSystem:UnBind(self.role.pro, 'dodge', labelMiss, 'Text');				--解除绑定闪避值
	uiSystem:UnBind(self.role.pro, 'def', labelNormalDefence, 'Text');		--解除绑定普通防御
	uiSystem:UnBind(self.role.pro, 'res', labelMagicDefence, 'Text');		--解除绑定魔法防御
	uiSystem:UnBind(self.role.pro, 'attack', labelAttack, 'Text');			--解除绑定攻击
	uiSystem:UnBind(self.role.pro, 'attackType', labelAttackType, 'Text');	--解除绑定攻击类型
	uiSystem:UnBind(self.role.pro, 'fp', labelFightPoint, 'Text');			--解除绑定战力
	uiSystem:UnBind(self.role, 'potential', textElementQianLi, 'Text');		--解除绑定潜力

end

--刷新绑定
function RoleInfoPanel:updateBind()
	uiSystem:UpdateDataBind();
end

--初始化人物属性背包ItemCell
function RoleInfoPanel:initEquipItemCell( itemCell, index )

	--设置控件属性,tag为位置
	itemCell.Tag = index;

	local yinying = itemCell:GetLogicChild('yinying');
	local arrow = itemCell:GetLogicChild('arrow');

	local bagEquip = self.equipList[index];
	if bagEquip ~= nil then
		itemCell.Image = self.equipList[index].icon;

		local color = resTableManager:GetValue(ResTable.item, tostring(bagEquip.resid), 'quality');
		itemCell.Background = Converter.String2Brush( QualityType[color] );

		local bagEquipData = resTableManager:GetRowValue(ResTable.equip, tostring(bagEquip.resid));

		local inJob = false;
		for _,v in ipairs(bagEquipData['jobsort']) do
			if v == self.role.job then
				inJob = true;
				break;
			end
		end

		if inJob then
			--同职业，比较战力
			yinying.Visibility = Visibility.Hidden;
			arrow.Visibility = Visibility.Visible;

			local bodyEquip = self.role.equips[ tostring(bagEquipData['part']) ];
			if bodyEquip == nil then
				arrow:SetImage('zhuangbeijiantou_1');
			else
				local up = false;		--表示增加战力
				if bagEquipData['part'] == EquipmentPos.weapon then
					--武器只算攻击力
					local bodyEquipData = resTableManager:GetValue(ResTable.equip, tostring(bodyEquip.resid), {'type', 'base_atk', 'base_mgc'});

					if bodyEquipData['base_atk'] ~= 0 then
						local bodyPhyAttack = bodyEquipData['base_atk'];
						if bodyEquip.strenlevel ~= 0 then
							local key = (bodyEquipData['type'] - 1) * 200 + bodyEquip.strenlevel;
							local tmp = resTableManager:GetRowValue(ResTable.equip_upgrade, tostring(key));
							bodyPhyAttack = bodyPhyAttack + tmp['atk'];
						end

						local bagPhyAttack = bagEquipData['base_atk'];
						if bagEquip.strenlevel ~= 0 then
							local key = (bagEquipData['type'] - 1) * 200 + bagEquip.strenlevel;
							local tmp = resTableManager:GetRowValue(ResTable.equip_upgrade, tostring(key));
							bagPhyAttack = bagPhyAttack + tmp['atk'];
						end

						up = bagPhyAttack > bodyPhyAttack;
					else
						local bodyMagAttack = bodyEquipData['base_mgc'];
						if bodyEquip.strenlevel ~= 0 then
							local key = (bodyEquipData['type'] - 1) * 200 + bodyEquip.strenlevel;
							local tmp = resTableManager:GetRowValue(ResTable.equip_upgrade, tostring(key));
							bodyMagAttack = bodyMagAttack + tmp['mgc'];
						end

						local bagMagAttack = bagEquipData['base_mgc'];
						if bagEquip.strenlevel ~= 0 then
							key = (bagEquipData['type'] - 1) * 200 + bagEquip.strenlevel;
							tmp = resTableManager:GetRowValue(ResTable.equip_upgrade, tostring(key));
							bagMagAttack = bagMagAttack + tmp['mgc'];
						end

						up = bagMagAttack > bodyMagAttack;
					end
				else
					--其他都用生命值
					local bodyEquipData = resTableManager:GetValue(ResTable.equip, tostring(bodyEquip.resid), {'type', 'base_hp'});

					local bodyHp = bodyEquipData['base_hp'];
					if bodyEquip.strenlevel ~= 0 then
						local key = (bodyEquipData['type'] - 1) * 200 + bodyEquip.strenlevel;
						local tmp = resTableManager:GetRowValue(ResTable.equip_upgrade, tostring(key));
						bodyHp = bodyHp + tmp['hp'];
					end

					local bagHp = bagEquipData['base_hp'];
					if bagEquip.strenlevel ~= 0 then
						key = (bagEquipData['type'] - 1) * 200 + bagEquip.strenlevel;
						tmp = resTableManager:GetRowValue(ResTable.equip_upgrade, tostring(key));
						bagHp = bagHp + tmp['hp'];
					end

					up = bagHp > bodyHp;
				end

				if up then
					arrow:SetImage('zhuangbeijiantou_1');
				else
					arrow:SetImage('zhuangbeijiantou_2');
				end
			end

			itemCell:SubscribeScriptedEvent('UIControl::MouseDownEvent', 'RoleInfoPanel:onMouseDown');
			itemCell:SubscribeScriptedEvent('UIControl::MouseMoveEvent', 'RoleInfoPanel:onMouseMove');
			itemCell:SubscribeScriptedEvent('UIControl::MouseUpEvent', 'RoleInfoPanel:onMouseUp');
			itemCell:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RoleInfoPanel:onMouseClick');
		else
			yinying.Visibility = Visibility.Visible;
			arrow.Visibility = Visibility.Visible;
			arrow:SetImage('zhuangbeijiantou_3');

			itemCell:SubscribeScriptedEvent('UIControl::MouseDownEvent', 'RoleInfoPanel:onMouseDown');
			itemCell:SubscribeScriptedEvent('UIControl::MouseMoveEvent', 'RoleInfoPanel:onMouseMove');
			itemCell:SubscribeScriptedEvent('UIControl::MouseUpEvent', 'RoleInfoPanel:onMouseUp');
			itemCell:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'RoleInfoPanel:onMouseClick');
		end
	else
		yinying.Visibility = Visibility.Hidden;
		arrow.Visibility = Visibility.Hidden;
	end

end

--设置一键按钮
function RoleInfoPanel:setOneKeyState()

	equipState = 0;
	for i = 1, 5 do
		local equip = self.role.equips[tostring(i)];
		if equip ~= nil then
			equipState = 1;
			break;
		end
	end

	if equipState == 0 then
		btnOnekey.Text = LANG_roleInfoPanel_6;
	else
		btnOnekey.Text = LANG_roleInfoPanel_7;
	end

end

--========================================================================
--点击事件

function RoleInfoPanel:onShowRoleInfo()
	MainUI:Push(self);
end

--关闭事件
function RoleInfoPanel:onClose()
	MainUI:Pop();			-- 必须先pop，再将role置空，因为hide的时候需要用到role做判断
	self.role = nil;
end

--头像点击事件
function RoleInfoPanel:onRoleClick(Args)
	local args = UIControlEventArgs(Args);
	self:SetRole(args.m_pControl.Tag);
end

--装备面板向左翻页
function RoleInfoPanel:onEquipPanelPageLeft()
	lvEquip:TurnPageForward();
end

--装备面板向右翻页
function RoleInfoPanel:onEquipPanelPageRight()
	lvEquip:TurnPageBack();
end

--显示命运或装备面板
function RoleInfoPanel:onChangePropsPanel()
	if equipPanel.Visibility == Visibility.Visible then
		equipPanel.Visibility = Visibility.Hidden;
		fatePanel.Visibility = Visibility.Visible;
		btnChange.Text = LANG_roleInfoPanel_8;
	else
		equipPanel.Visibility = Visibility.Visible;
		fatePanel.Visibility = Visibility.Hidden;
		btnChange.Text = LANG_roleInfoPanel_9;
	end

end

--解雇
function RoleInfoPanel:onFire()
	if 0 == self.role.pid then
		MessageBox:ShowDialog(MessageBoxType.Ok, LANG_roleInfoPanel_10);
	else
		PartnerFirePanel:onShow( self.role );
	end
end

--真正解雇
function RoleInfoPanel:onRealFire( pid )
	local msg = {}
	msg.pid = pid;
	Network:Send(NetworkCmdType.req_fire_partner, msg);
end

--一键
function RoleInfoPanel:onOneKey()

	if equipState == 0 then
		--一键穿上
		local equipList = {};
		equipList[1] = Package:GetFirstSortedEquip(self.role, EquipmentPos.head);
		equipList[2] = Package:GetFirstSortedEquip(self.role, EquipmentPos.body);
		equipList[3] = Package:GetFirstSortedEquip(self.role, EquipmentPos.foot);
		equipList[4] = Package:GetFirstSortedEquip(self.role, EquipmentPos.weapon);
		equipList[5] = Package:GetFirstSortedEquip(self.role, EquipmentPos.jewelry);

		for i = 1,5 do
			local equip = equipList[i];
			if equip ~= nil then
				local msg = {}
				msg.pid = self.role.pid;
				msg.eid = equip.eid;
				msg.flag = EquipTakeOnOff.on;
				msg.slot_pos = i;

				Network:Send(NetworkCmdType.req_wear_equip, msg);
			end
		end
	else
		--一键脱下
		if Package:GetAllItemCount() > (ActorManager.user_data.bagn - 5) then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_roleInfoPanel_11);
		else
			for i = 1, 5 do
				local equip = self.role.equips[tostring(i)];
				if equip ~= nil then
					local msg = {}
					msg.pid = self.role.pid;
					msg.eid = equip.eid;
					msg.flag = EquipTakeOnOff.off;
					msg.slot_pos = i;
					Network:Send(NetworkCmdType.req_wear_equip, msg);
				end
			end
		end
	end
end

--穿装备
function RoleInfoPanel:PutonEquip(resid, eid)
	if self.role == nil then
		return;
	end

	local msg = {}
	msg.pid = self.role.pid;
	msg.eid = eid;
	msg.flag = EquipTakeOnOff.on;
	msg.slot_pos = resTableManager:GetValue(ResTable.equip, tostring(resid), 'part');

	Network:Send(NetworkCmdType.req_wear_equip, msg);
end

--========================================================================
--拖拽处理
--========================================================================

local dragDropTimer = 0;
local dragDropItemCell;

--角色装备按下
function RoleInfoPanel:onMouseDown( Args )

	if dragDropTimer ~= 0 then
		return;
	end

	local args = UIMouseButtonEventArgs(Args);
	if args.Tag == 0 then
		return;
	end

	dragDropTimer = timerManager:CreateTimer(GlobalData.MouseMoveTime, 'RoleInfoPanel:onDragDopTimer', 0);
	dragDropItemCell = args.m_pOriginalControl;

end

--角色装备按下
function RoleInfoPanel:onMouseMove()

	if dragDropTimer ~= 0 then
		timerManager:DestroyTimer(dragDropTimer);
		dragDropTimer = 0;
		dragDropItemCell = nil;
	end

end

--角色装备抬起
function RoleInfoPanel:onMouseUp()

	if dragDropTimer ~= 0 then
		timerManager:DestroyTimer(dragDropTimer);
		dragDropTimer = 0;
		dragDropItemCell = nil;
	end

end

--按下超过一定时间没有移动认为是拖拽
function RoleInfoPanel:onDragDopTimer()

	mouseCursor.Image = dragDropItemCell.icon;
	mainDesktop:DoDragDrop(dragDropItemCell);
	timerManager:DestroyTimer(dragDropTimer);
	dragDropTimer = 0;
	dragDropItemCell = nil;

end

--背包装备tip
function RoleInfoPanel:onMouseClick( Args )
	local args = UIControlEventArgs(Args);
	local item = RoleInfoPanel.equipList[args.m_pControl.Tag];
	if item == nil then
		return;
	end

	TooltipPanel:ShowItem(roleInfoPanel, item, TipEquipShowButton.EquipSell);
end

--角色装备tip
function RoleInfoPanel:onBodyEquipClick( Args )
	local args = UIControlEventArgs(Args);
	local equip = self.role.equips[tostring(args.m_pControl.Tag)];
	if equip == nil then
		--显示装备购买界面
		local resid = 0;
		if args.m_pControl.Tag == 1 then
			resid = 16011;
		elseif args.m_pControl.Tag == 2 then
			resid = 16012;
		elseif args.m_pControl.Tag == 3 then
			resid = 16013;
		elseif args.m_pControl.Tag == 4 then
			if self.role.job == JobType.knight then
				resid = 16014;
			elseif self.role.job == JobType.warrior then
				resid = 16015;
			elseif self.role.job == JobType.hunter then
				resid = 16016;
			elseif self.role.job == JobType.magician then
				resid = 16017;
			end
		elseif args.m_pControl.Tag == 5 then
			if self.role.job == JobType.magician then
				resid = 16018;
			else
				resid = 16019;
			end
		end

		local item = resTableManager:GetValue(ResTable.money_shop_itemID, tostring(resid), {'id', 'price'});
		if (item['price'] > ActorManager.user_data.fpoint) then
			MessageBox:ShowDialog(MessageBoxType.Ok, LANG_roleInfoPanel_12);
		else
		--	BuyUniversalPanel:onShowPanel(item['id'])
		--	BuyUniversalPanel:SetButtonEnable(false);
		end
		return;
	end

	TooltipPanel:ShowItem(roleInfoPanel, equip, TipEquipShowButton.UnEquip);
end

--========================================================================
--========================================================================
