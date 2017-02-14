--fightQTEManager.lua
--=========================================================================================================
--QTE系统
FightQTEManager = 
	{
		hasAppear = false;				--是否已经出现过
		isHeartAppear = false;			--当前是否出现
		isInQTEState = false;			--当前是否处于QTE状态
	};

local timescale;						--保存游戏当前的时间缩放
local desktop;
local shader;							--UI遮罩
local uiCamera;							--UI相机
local sceneCamera;						--场景相机
local heartArmature;					--心脏armature
local guideArmature = nil;				--引导动画
local titleArmature = nil;				--称号动画
local comboArmature = nil;				--连击动画
local number1Armature = nil;			--十位数动画
local number2Armature = nil;			--个位数动画
local heartAppearArmature = nil;		--心脏跳动的时候的特效
local skipButton = nil;					--跳过按钮

local curState = 1;						--当前状态
local updateTimer = 0;					--心脏状态定时器
local QTEPassTime = 1;					--QTE pass时间
local isEndQTE = false;				--是否时间到结束QTE
local QTELassTime = 4;					--QTE持续时间
local FirstQTELastTime = 6;
local showDamageTimer = -1;			--QTE结束时展示伤害的计时器
local showDamageTime = 1.2;				--QTE结束时展示伤害的时间
local isSkipClicked;					--跳过按钮是否点击

local bossCurrentHP = 0;
local curCount = 0;						--当前击中次数
local totalCount = 0;					--总共连击次数
local totalDamage = 0;					--总伤害

local damageLabelList = {};				--伤害标签列表

local ParameterList = {};				--滑动次数和伤害的参数
ParameterList[4] = {count = 25, per = 0.0154};
ParameterList[5] = {count = 25, per = 0.0154};
ParameterList[6] = {count = 15, per = 0.0205};
ParameterList[7] = {count = 15, per = 0.0205};

local scratchTraceArmature = {};
scratchTraceArmature[4] = 'Gesture_3';
scratchTraceArmature[5] = 'Gesture_3';
scratchTraceArmature[6] = 'Gesture_2';
scratchTraceArmature[7] = 'Gesture_1'; 

local bossPosition;						--boss位置

--初始化
function FightQTEManager:Initialize(desk, startPos, hp)
	desktop = desk;
	
	sceneCamera = FightManager.scene:GetCamera();
	uiCamera = desktop.Camera;
	
	shader = desktop:GetLogicChild('shader');
	
	bossPosition = startPos;					--boss位置
	curState = 1;								--重置状态为1
	updateTimer = -1;
	bossCurrentHP = hp;							--boss血量
	curCount = 0;								--当前击中次数
	totalCount = 0;								--总共连击次数
	totalDamage = 0;							--总伤害
	timescale = appFramework.TimeScale;			--保存当前游戏速度
	
	BottomRenderStep:SetTouchBeginState(false);
end	

--更新伤害数字
function FightQTEManager:Update(elapse)
	local i = 1;
	while i <= #damageLabelList do
		local item = damageLabelList[i];
		item.totalTime = item.totalTime + elapse / appFramework.TimeScale;
		if item.totalTime >= 1 then
			desktop:RemoveChild(item.label);
			table.remove(damageLabelList, i);
		else
			local x = item.xSpeed * item.totalTime;
			local y = item.ySpeed * item.totalTime + item.yAddSpeed * item.totalTime * item.totalTime / 2;	
			item.label.Translate = Vector2(item.initPos.x + x, item.initPos.y + y);
			
			i = i + 1;
		end
	end	
end

--销毁
function FightQTEManager:Destroy()
	if (skipButton ~= nil) then
		desktop:RemoveChild(skipButton);
		skipButton = nil;
	end
end

--添加伤害显示
function FightQTEManager:displayDamage(data)
	local damageItem = {};
	damageItem.label = uiSystem:CreateControl('Label');
	damageItem.label.Size = Size(150, 100);
	damageItem.label.Font = uiSystem:FindFont('damageFont');
	damageItem.label.Text = tostring(data);
	damageItem.label.Pick = false;
	damageItem.label.ZOrder = 12;
	damageItem.xSpeed = Math.RangeRandom(-300, 300);	
	damageItem.yAddSpeed = Math.RangeRandom(500, 700);
	damageItem.ySpeed = Math.RangeRandom(-550, -350);
	damageItem.totalTime = 0;
	damageItem.initPos = Vector2(desktop.Width/2 + Math.RangeRandom(-20, 20), desktop.Height/2 - 80);
	damageItem.label.Translate = damageItem.initPos;
	desktop:AddChild(damageItem.label);
	table.insert(damageLabelList, damageItem);
end

--开始
function FightQTEManager:Start()
	FightManager:Pause();								--暂停游戏
	appFramework.TimeScale = 1;							--强制游戏进入正常速度
	shader.Visibility = Visibility.Visible;				--打开遮罩
	self.hasAppear = true;								--QTE已经出现
	self.isInQTEState = true;
	isSkipClicked = false;								--重置跳过按钮点击标记位

	--播放神之指意
	PlayEffect('God_refers_to_the_meaning_output/', Rect(0,0,0,0), 'God_refers_to_the_meaning');
	PlaySound('shenzhizhiyi');			--神之指意音效
	
	--心脏出现
	local pos = SceneToUiPT(sceneCamera, uiCamera, Vector3(bossPosition.x, bossPosition.y, 0));		
	heartAppearArmature = self:PlayHeartAppearEffect('Heart_1', pos, 1);
	
	--创建跳过按钮
	if (ActorManager.user_data.round.roundid > Configuration.QTETeachRoundID) then
		self:CreateSkipButton();
	end
end

--创建跳过按钮
function FightQTEManager:CreateSkipButton()
	if skipButton == nil then
		skipButton = uiSystem:CreateControl('ArmatureUI');
		skipButton:SubscribeScriptedEvent('UIControl::MouseClickEvent', 'FightQTEManager:Skip');		
		
		AvatarManager:LoadFile(GlobalData.EffectPath .. 'tiaoguo_output/');
		skipButton:LoadArmature('tiaoguo');
		skipButton:SetAnimation('play');
		
		skipButton.Size = Size(88,51);
		
		skipButton.Horizontal = ControlLayout.H_RIGHT;
		skipButton.Vertical = ControlLayout.V_TOP;
		skipButton.Margin = Rect(0,135,115,0);
		skipButton.ZOrder = 20;
		
		desktop:AddChild(skipButton);
	end
	
	skipButton.Visibility = Visibility.Visible;
end

--删除跳过按钮
function FightQTEManager:DestroySkipButton()
	if skipButton ~= nil then
		skipButton.Visibility = Visibility.Hidden;
	end
end

--跳过QTE
function FightQTEManager:Skip()
	self.isHeartAppear = false;					--设置此时已经不可再滑动
	isEndQTE = true;							--pass状态为true
	isSkipClicked = true;
	
	if heartAppearArmature ~= nil then				--删除跳动的心脏动画
		desktop:RemoveChild(heartAppearArmature);
		heartAppearArmature = nil;
	end
	
	if nil ~= guideArmature then					--删除引导动画
		desktop:RemoveChild(guideArmature);
		guideArmature = nil;
	end
	
	if nil ~= heartArmature then					--删除心脏滑动时的特效
		desktop:RemoveChild(heartArmature);
		heartArmature = nil;
	end
	
	if -1 ~= updateTimer then
		timerManager:DestroyTimer(updateTimer);		--删除QTE时间定时器
		updateTimer = -1;
	end
	
	self:Quit();
end

--退出QTE
function FightQTEManager:Quit()
	appFramework.TimeScale = timescale;					--恢复游戏之前的速度
	shader.Visibility = Visibility.Hidden;
	self.isHeartAppear = false;						--滑动之后结束的，该值已经是false，但是如果没没，需要在退出之前设置false
	self.isInQTEState = false;						--QTE状态结束
	heartArmature = nil;
	
	while #damageLabelList > 0 do
		desktop:RemoveChild(damageLabelList[1].label);
		table.remove(damageLabelList, 1);
	end
	damageLabelList = {};

	self:DestroySkipButton();
	
	if totalCount == 0 then
		FightManager:Continue();
	else
		self:ShowDamage();
	end
	
end

--开始伤害表现
function FightQTEManager:ShowDamage()
	--添加遮罩
	FightManager:AddShader();
	--设置技能不可点击
	FightUIManager:SetAllSkillEffectEnable(false);
	--将boss提前
	FightManager:GetBoss():BringToFront();
	--添加特效
	FightManager:GetBoss():AddQTEDamageEffect();
	--创建定时器
	if showDamageTimer == -1 then
		showDamageTimer = timerManager:CreateTimer(showDamageTime, 'FightQTEManager:EndShowDamage', 0);
	end
	--显示QTE扣除血量标签
	timerManager:CreateTimer(showDamageTime / 2, 'FightQTEManager:ShowDamageLabel', 0, true);
end

--显示QTE扣除血量标签
function FightQTEManager:ShowDamageLabel()
	--添加伤害显示
	local damageItem = {};
	damageItem.data = totalDamage;
	damageItem.state = AttackState.critical;
	DamageLabelManager:Add(FightManager:GetBoss(), damageItem, AttackType.skill);
end

--结束伤害表现
function FightQTEManager:EndShowDamage()
	timerManager:DestroyTimer(showDamageTimer);
	showDamageTimer = -1;
	
	--设置技能可点击
	FightUIManager:SetAllSkillEffectEnable(true);
	FightManager:Continue();
	FightManager:RemoveShader();
	
	--boss减血
	FightManager:GetBoss():DeductHp(totalDamage);
	FightUIManager:UpdateBossUI();
end

--结束QTE状态
function FightQTEManager:EndQTE()
	self.isHeartAppear = false;					--设置此时已经不可再滑动
	isEndQTE = true;							--pass状态为true
	
	local maxCount = ParameterList[5].count + ParameterList[6].count + ParameterList[7].count;
	if (7 == curState) and (totalCount >= maxCount) then
		heartArmature:SetAnimation('break');
		PlaySound('breakheart');				--播放心脏爆破音效
	else
		heartArmature:SetAnimation('disappear');
	end

	if nil ~= guideArmature then				--删除引导动画
		desktop:RemoveChild(guideArmature);
		guideArmature = nil;
	end
	
	timerManager:DestroyTimer(updateTimer);		--删除QTE时间定时器
	updateTimer = -1;
end	

--结束pass计时状态
function FightQTEManager:EndPassQTE()
	curState = 5;									--进入装甲状态，可滑动
	isEndQTE = false;								--pass状态为false
	
	if nil ~= guideArmature then					--删除引导动画
		desktop:RemoveChild(guideArmature);
		guideArmature = nil;
	end
	
	if 0 ~= updateTimer then
		timerManager:DestroyTimer(updateTimer);		
	end

	if (ActorManager.user_data.round.roundid + 1 ~= FightManager.barrierId) or (FightManager.barrierId ~= Configuration.QTETeachRoundID) then
		updateTimer = timerManager:CreateTimer(QTELassTime, 'FightQTEManager:EndQTE', 0);			--QTE倒计时
	else
		updateTimer = timerManager:CreateTimer(FirstQTELastTime, 'FightQTEManager:EndQTE', 0);			--QTE倒计时
	end
end

--播放心脏特效
function FightQTEManager:PlayHeartAppearEffect(armatureName, pos, stateID)
	local armatureUI = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	armatureUI:LoadArmature(armatureName);
	armatureUI:SetAnimation('play');
	armatureUI.Translate = pos;
	armatureUI.ZOrder = 10;					--在sharder前面
	armatureUI:SetScriptAnimationCallback('FightQTEManager:heartAppearAnimationEnd', stateID);	
	desktop:AddChild(armatureUI);
	
	return armatureUI;
end

--播放QTE引导
function FightQTEManager:PlayQTEGuideEffect(pos)
	local armatureUI = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	armatureUI:LoadArmature('QTE_yindao');
	armatureUI:SetAnimation('play');
	armatureUI.Translate = pos;
	armatureUI.ZOrder = 11;
	desktop:AddChild(armatureUI);
	
	return armatureUI;
end

--播放滑动时候的心脏特效
function FightQTEManager:PlayHeartScratchEffect(armatureName, pos, stateID)
	local armatureUI = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	armatureUI:LoadArmature(armatureName);
	armatureUI:SetAnimation('idle');
	armatureUI.Translate = pos;
	armatureUI.ZOrder = 10;					--在sharder前面
	armatureUI:SetScriptAnimationCallback('FightQTEManager:heartAppearAnimationEnd', stateID);	
	desktop:AddChild(armatureUI);
	
	return armatureUI;
end

--播放滑动轨迹特效
function FightQTEManager:PlayScratchTraceEffect(startPoint, endPoint)
	local armatureUI = ArmatureUI( uiSystem:CreateControl('ArmatureUI') );
	armatureUI:LoadArmature(scratchTraceArmature[curState]);
	armatureUI:SetAnimation('play');
	armatureUI.Translate = Vector2((startPoint.x + endPoint.x)/2, (startPoint.y + endPoint.y)/2);	
	armatureUI.ZOrder = 11;					--在sharder前面
	desktop:AddChild(armatureUI);
	
	local angle = Math.ATan((endPoint.y - startPoint.y) / (endPoint.x - startPoint.x));
	if endPoint.x < startPoint.x then
		angle = angle + 3.141592653;
	end
	armatureUI:SetRotation(angle);		--旋转
end

--心脏出现特效的动作结束相应函数
function FightQTEManager:heartAppearAnimationEnd(armature, stateID)
	if armature:IsCurAnimationLoop() then
		--循环动作
		armature:Replay();
		return;
	elseif (isSkipClicked) then
		--由于该函数是延迟下一帧执行的，所以当某一个心脏动画结束后，添加该延迟事件，加入在下一帧玩家点击跳过按钮，
		--会先删除当前心脏，然后在该帧执行此延迟函数，创建新的心脏，导致bug不消失的bug
		--该标志位是为防止该事件发生的
		return;
	end	
	
	if 1 == stateID then		
		uiSystem:AddAutoReleaseControl(armature);				--销毁第一个心脏
		
		curState = 2;
		local pos = SceneToUiPT(sceneCamera, uiCamera, Vector3(bossPosition.x, bossPosition.y, 0));
		heartAppearArmature = self:PlayHeartAppearEffect('Heart_Shield_1', Vector2((pos.x + desktop.Width/2)/2, (pos.y + desktop.Height/2)/2), 2);
	elseif 2 == stateID then
		uiSystem:AddAutoReleaseControl(armature);				--销毁第二个心脏
		
		curState = 3;		
		heartAppearArmature = self:PlayHeartAppearEffect('Heart_Iron_1', Vector2(desktop.Width/2, desktop.Height/2), 3);		--心脏
		guideArmature = self:PlayQTEGuideEffect(Vector2(desktop.Width/2, desktop.Height/2));
	elseif 3 == stateID then	
		uiSystem:AddAutoReleaseControl(armature);				--销毁第三个心脏
		heartAppearArmature = nil;
		
		curState = 4;
		self.isHeartAppear = true;	
		heartArmature = self:PlayHeartScratchEffect('Heart_Iron', Vector2(desktop.Width/2, desktop.Height/2), 4);
		if (ActorManager.user_data.round.roundid + 1 ~= FightManager.barrierId) or (FightManager.barrierId ~= Configuration.QTETeachRoundID) then
			updateTimer = timerManager:CreateTimer(QTEPassTime, 'FightQTEManager:EndQTE', 0);
		end

	elseif (4 == stateID) then										--装甲状态	
		if 'shake' == armature:GetAnimation() then					--抖动结束
			armature:SetAnimation('idle');
		
		elseif 'break' == armature:GetAnimation() then				--爆破
			--玩家划破该心脏，非QTE时间到了
			uiSystem:AddAutoReleaseControl(armature);				--销毁第四个心脏
		
		elseif 'disappear' == armature:GetAnimation() then			--装甲消失
			--QTE时间到了，心脏消失，QTE结束
			uiSystem:AddAutoReleaseControl(armature);				--销毁第四个心脏
			self:Quit();											--退出
		end
		
	elseif 6 == stateID then	--保护罩状态
		if 'shake' == armature:GetAnimation() then					--抖动结束
			armature:SetAnimation('idle');
			
		elseif 'break' == armature:GetAnimation() then				--爆破
			--玩家划破该心脏，非QTE时间到了
			uiSystem:AddAutoReleaseControl(armature);				--销毁第五个心脏
	
		elseif 'disappear' == armature:GetAnimation() then			--装甲消失
			--QTE时间到了，心脏消失，QTE结束
			uiSystem:AddAutoReleaseControl(armature);				--销毁第五个心脏		
			self:Quit();											--退出	
			
		end
		
	elseif 7 == stateID then	--裸露状态
		if 'shake' == armature:GetAnimation() then					--抖动结束
			armature:SetAnimation('idle');
			
		elseif 'disappear' == armature:GetAnimation() or 'break' == armature:GetAnimation() then			--装甲消失
			uiSystem:AddAutoReleaseControl(armature);				--销毁装甲心脏
			self:Quit();
		end
		
	end		
	
end

--称号、连击动画回调
function FightQTEManager:titleAnimationEnd(armature, id)
	if armature:IsCurAnimationLoop() then
		--循环动作
		armature:Replay();
		return;
	end	
	
	uiSystem:AddAutoReleaseControl(armature);
	if id == 1 then		--称号
		titleArmature = nil;
	elseif id == 2 then	--连击
		comboArmature = nil;
	elseif id == 3 then	--十位数
		number1Armature = nil;
	elseif id == 4 then	--个位数
		number2Armature = nil;
	end	
	
end

--==========================================================================================================
--滑到心脏
function FightQTEManager:ScratchHeart()
	if 5 == curState then				--装甲状态
		curCount = curCount + 1;
		
		if curCount >= ParameterList[curState].count then
			curCount = 0;										--次数清空
			curState = curState + 1;
			heartArmature:SetAnimation('break');				--当前的心脏消失
			heartArmature = self:PlayHeartScratchEffect('Heart_Shield', Vector2(desktop.Width/2, desktop.Height/2), 6);		--播放下一个心脏特效
			PlaySound('breakarmor');							--播放装甲爆破音效
		end
		
	elseif 6 == curState then			--护罩状态
		curCount = curCount + 1;

		if curCount >= ParameterList[curState].count then
			curCount = 0;										--次数清空
			curState = curState + 1;
			heartArmature:SetAnimation('break');				--当前的心脏消失
			heartArmature = self:PlayHeartScratchEffect('Heart', Vector2(desktop.Width/2, desktop.Height/2), 7);				--播放下一个心脏特效
			PlaySound('breakshield');							--播放护罩爆破音效
		end
		
	elseif 7 == curState then			--裸露状态
		curCount = curCount + 1;
		
	end
	
	--判断血量是否超过boss当前血量上限
	local damage = math.floor(Math.RangeRandom(0.8, 1.2) * ParameterList[curState].per * bossCurrentHP);
	totalDamage = totalDamage + damage;	
	self:displayDamage(damage);
	if totalDamage >= bossCurrentHP then
		totalDamage = bossCurrentHP - 10;
	end	
	
	totalCount = totalCount + 1;		--总共连击次数	
	--连击
	if comboArmature ~= nil then
		topDesktop:RemoveChild(comboArmature);
	end
	--comboArmature = PlayEffect('Batter_1_output/', Rect(100, 180, 0, 0), 'Batter');
	--comboArmature:SetScriptAnimationCallback('FightQTEManager:titleAnimationEnd', 2);	
	
	--十位数字
	if totalCount >= 10 then
		if number1Armature ~= nil then
			topDesktop:RemoveChild(number1Armature);
		end
		--number1Armature = PlayEffect('Batter_1_output/', Rect(160, 180, 0, 0), 'Batter_shuzi_' .. math.floor(totalCount/10));
		--number1Armature:SetScriptAnimationCallback('FightQTEManager:titleAnimationEnd', 3);
	end	
	
	--个位数字
	if number2Armature ~= nil then
		topDesktop:RemoveChild(number2Armature);
	end
	--number2Armature = PlayEffect('Batter_1_output/', Rect(120, 180, 0, 0), 'Batter_shuzi_' .. math.mod(totalCount, 10));
	--number2Armature:SetScriptAnimationCallback('FightQTEManager:titleAnimationEnd', 4);
	
	--称号
	if totalCount == 10 then
		if titleArmature ~= nil then
			topDesktop:RemoveChild(titleArmature);
		end
		--titleArmature = PlayEffect('Batter_output/', Rect(250, 40, 0, 0), 'Cool');
		--titleArmature:SetScriptAnimationCallback('FightQTEManager:titleAnimationEnd', 1);	
		PlaySound('combo1');			--音效
		
	elseif totalCount == 25 then
		if titleArmature ~= nil then
			topDesktop:RemoveChild(titleArmature);
		end
		--titleArmature = PlayEffect('Batter_output/', Rect(250, 40, 0, 0), 'Praise');
		--titleArmature:SetScriptAnimationCallback('FightQTEManager:titleAnimationEnd', 1);	
		PlaySound('combo2');			--音效
			
	elseif totalCount == 40 then
		if titleArmature ~= nil then
			topDesktop:RemoveChild(titleArmature);
		end
		--titleArmature = PlayEffect('Batter_output/', Rect(250, 40, 0, 0), 'Perfect');
		--titleArmature:SetScriptAnimationCallback('FightQTEManager:titleAnimationEnd', 1);	
		PlaySound('combo3');			--音效
		
	elseif totalCount == 50 then
		if titleArmature ~= nil then
			topDesktop:RemoveChild(titleArmature);
		end
		--titleArmature = PlayEffect('Batter_output/', Rect(250, 40, 0, 0), 'Domineering');
		--titleArmature:SetScriptAnimationCallback('FightQTEManager:titleAnimationEnd', 1);	
		PlaySound('combo4');			--音效
		
	elseif totalCount == 60 then
		if titleArmature ~= nil then
			topDesktop:RemoveChild(titleArmature);
		end
		--titleArmature = PlayEffect('Batter_output/', Rect(250, 40, 0, 0), 'God');
		--titleArmature:SetScriptAnimationCallback('FightQTEManager:titleAnimationEnd', 1);	
		PlaySound('combo5');			--音效
		
	end
	
	heartArmature:SetAnimation('shake');
end

--获取Rect
function FightQTEManager:GetRect()
	if 5 == curState or 4 == curState then				--装甲状态
		return Rect(desktop.Width/2 - 170, desktop.Height/2 - 200, desktop.Width/2 + 190, desktop.Height/2 + 205);
	elseif 6 == curState then			--护罩状态
		return Rect(desktop.Width/2 - 145, desktop.Height/2 - 175, desktop.Width/2 + 175, desktop.Height/2 + 190);
	elseif 7 == curState then			--裸露状态
		return Rect(desktop.Width/2 - 125, desktop.Height/2 - 145, desktop.Width/2 + 125, desktop.Height/2 + 150);
	end
end

--获取状态
function FightQTEManager:GetState()
	return curState;
end	

--当前是否处于QTE状态
function FightQTEManager:IsInQTEState()
	return self.isInQTEState;
end
