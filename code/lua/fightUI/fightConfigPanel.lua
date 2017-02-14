--fightConfigPanel.lua
--==============================================================================================
--vip特权面板

FightConfigPanel =
	{
	};

--变量
local font;
local fontVip;
local color;

--控件
local mainDesktop;
local panel;

local animOff;				--动画关闭
local animOn;				--动画开启
local bulletOff;			--弹幕关闭
local bulletOn;				--弹幕开启
local fightProgress;		--关卡进度条
local bgmVolume;			--Bgm音量条
local soundVolume;			--音效音量条
local actorImage;			--进度条上的角色头像
local bossImage;			--进度条左边的boss头像
local panelAnim;
local panelBullet;
local panelInfo;			--说明页

local jieming;				--节名
local zhangming;			--章名

local textGuanqia;			--config文本
local textTongguan;

local bgmProgress;
local soundProgress;

local animStatus;

local isShowAnimState;

--============================================================================================
--更新控件状态

--更新动画开关状态
function FightConfigPanel:UpdateAnimState(flag)

	if flag then
		animOn.Selected = true;
		animOff.Selected = false;
	else
		animOn.Selected = false;
		animOff.Selected = true;
	end
	panelAnim.Background = Converter.String2Brush(flag and FightConfigBrush.On or FightConfigBrush.Off);
end

--更新弹幕开关状态
function FightConfigPanel:UpdateBulletState()
	bulletOn.Selected = BulletScreenManager:getEnable();
	bulletOff.Selected = not BulletScreenManager:getEnable();
	panelBullet.Background = Converter.String2Brush(BulletScreenManager:getEnable() and FightConfigBrush.On or FightConfigBrush.Off);
end

--更新当前关卡进度
function FightConfigPanel:UpdateFightProgress()
	fightProgress.CurValue, fightProgress.MaxValue = FightManager:getFightProgress();
end

--更新当前bgm音量
function FightConfigPanel:UpdateBgmVolume()
	if SystemPanel.soundFlag then
		local value = SoundManager:getBgmVolume();
		local value = value or 0;
		if value > 1 or value < 0 then
			value = 0;
		end
		bgmVolume.CurValue = value * 100;
		bgmProgress.CurValue = value * 100 ;
	end
end

--更新当前音效音量
function FightConfigPanel:UpdateSoundVolume()
	if SystemPanel.soundEffectFlag then
		local value = SoundManager:getEffectVolume();
		local value = value or 0;
		if value > 1 or value < 0 then
			value = 0;
		end
		soundVolume.CurValue = value * 100;
	    soundProgress.CurValue =  value * 100;
	end
end

--更新人物头像以及位置
function FightConfigPanel:UpdateActorImage()
	actorImage.Image = GetPicture('fight/cf_start_coin.ccz')
	actorImage:SetTranslateX(fightProgress.CurValue / fightProgress.MaxValue * 300);
end

--更新设置中进度条到头时的boss头像
function FightConfigPanel:UpdateBossImage()
	bossImage.Image = GetPicture('fight/cf_boss_coin.ccz')
end

--更新章名
function FightConfigPanel:UpdateZhangMing()
	local bid = FightManager.barrierId;
	if bid > 7000 and bid < 8000 then
		zhangming.Text = resTableManager:GetValue(ResTable.limit_round, tostring(bid), 'name');
	elseif (bid > 1000 and bid < 2000) or (bid > 5000 and bid < 6000) then
		zhangming.Text = resTableManager:GetValue(ResTable.barriers, tostring(bid), 'name');
	elseif bid > 8000 and bid < 9000 then
		zhangming.Text = LANG_expeditionPanel_8;
	elseif bid > 4000 and bid < 5000 then
		zhangming.Text = LANG_dragonTreasurePanel_6;
	else
		zhangming.Text = 'Silence!'
	end

	-- 特殊玩法处理
	if FightManager.mFightType == FightType.arena then
		zhangming.Text = LANG_Config_arena;
	elseif FightManager.mFightType == FightType.rank then
		zhangming.Text = LANG_Config_rank;
	elseif FightManager.mFightType == FightType.unionBattle then
		zhangming.Text = LANG_Config_unionBattle;
	elseif FightManager.mFightType == FightType.scuffle then
		zhangming.Text = LANG_Config_scuffle;
	end 
	zhangming.Text = LANG_Config_1;
end

--更新节名
function FightConfigPanel:UpdateJieMing()
	jieming.Text = tostring(soundVolume.CurValue)
end

--更新文本
function FightConfigPanel:UpdateText()
	--[[if textGuanqia.Text == "" then
		textGuanqia.Text = "111111111111"
	end]]

	if textTongguan.Text == "" then
		textTongguan.Text = "建议用免疫的灼烧的水属性的队员或者可清除buff的技能带全体回复的医生职业"
	end
end

--============================================================================================
--初始化
function FightConfigPanel:InitPanel(desktop)

	--变量初始化
	font = uiSystem:FindFont('huakang_20');
	--fontVip = uiSystem:FindFont('vipFont');
	color = QuadColor(Color(248, 220, 159, 255));
	animStatus = true;

	--界面初始化
	mainDesktop = desktop;
	panel = Panel(desktop:GetLogicChild('fightConfigPanel'));
	panel.Visibility = Visibility.Hidden;
	panel.ZOrder = PanelZOrder.fightConfig;

	--控件初始化
	animOff = panel:GetLogicChild('animPanel'):GetLogicChild('animOff');
	animOff:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'FightConfigPanel:OnAnimOff');
	animOn = panel:GetLogicChild('animPanel'):GetLogicChild('animOn');
	animOn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'FightConfigPanel:OnAnimOn');
	bulletOff = panel:GetLogicChild('bulletPanel'):GetLogicChild('bulletOff');
	bulletOff:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'FightConfigPanel:OnBulletOff');
	bulletOn = panel:GetLogicChild('bulletPanel'):GetLogicChild('bulletOn');
	bulletOn:SubscribeScriptedEvent('RadioButton::SelectedEvent', 'FightConfigPanel:OnBulletOn');

	panelAnim = panel:GetLogicChild('animPanel');
	panelBullet = panel:GetLogicChild('bulletPanel');
	--fightProgress = panel:GetLogicChild('fightProgress');
	--actorImage = panel:GetLogicChild('actorImage');
	--bossImage = panel:GetLogicChild('bossImage');
	--jieming = panel:GetLogicChild('jieming');
	zhangming = panel:GetLogicChild('title');
	--textGuanqia = panel:GetLogicChild('guanqiajianjie');
	--textTongguan = panel:GetLogicChild('tongguangongneng');
	bgmProgress = panel:GetLogicChild('bgmProgressBar');
	bgmVolume = panel:GetLogicChild('bgmVolume');
	soundProgress = panel:GetLogicChild('soundProgressBar');
	soundVolume = panel:GetLogicChild('soundVolume');

	isShowAnimState = true;
end

--销毁
function FightConfigPanel:Destroy()
end

--显示
function FightConfigPanel:Show()
	panel.Visibility = Visibility.Visible;
	self:UpdateAnimState(isShowAnimState);
	self:UpdateBulletState();
	--self:UpdateFightProgress();
	self:UpdateBgmVolume();
	self:UpdateSoundVolume();
	--self:UpdateActorImage();
	--self:UpdateBossImage();
	self:UpdateZhangMing();
	--self:UpdateJieMing();
	--self:UpdateText();
end

--隐藏
function FightConfigPanel:Hide()
	panel.Visibility = Visibility.Hidden;
end

--============================================================================================


--刷新领取按钮状态
--[[
function VipPanel:RefreshVipRewardButton()

	local firstPos = -1;		--第一个可以领取的位置
	local endPos = -1;		--最后一个已领取的位置
	for i = 1, 12 do
		local panel = listView:GetLogicChild(i-1):GetLogicChild(0);
		local get = panel:GetLogicChild('get');

		if ActorManager.user_data.reward.vip_reward[i] == 0 then
			--不能领
			get.Enable = false;
			get.Text = LANG_vipPanel_2;
		elseif ActorManager.user_data.reward.vip_reward[i] == -1 then
			--已领取
			get.Enable = false;
			get.Text = LANG_vipPanel_3;

			endPos = i;		--记录已领取位置
		elseif ActorManager.user_data.reward.vip_reward[i] == 1 then
			--可领取
			get.Enable = true;
			get.Text = LANG_vipPanel_4;

			if firstPos == -1 then
				firstPos = i;	--记录第一个可领取的位置
			end
		end
	end

	local pos = 0;
	if firstPos ~= -1 then
		pos = firstPos - 1;
	elseif endPos ~= -1 then
		pos = endPos;
	else
		pos = math.max(0, ActorManager.user_data.viplevel - 1);
	end

	listView:SetActivePageIndexImmediate(pos);

end
]]


--==============================================================================================
--事件
--关动画
function FightConfigPanel:OnAnimOff()
	isShowAnimState = false;
	panelAnim.Background = Converter.String2Brush(FightConfigBrush.Off);
	animStatus = false;
end

--开动画
function FightConfigPanel:OnAnimOn()
	isShowAnimState = true;
	panelAnim.Background = Converter.String2Brush(FightConfigBrush.On);
	animStatus = true;
end

--关弹幕
function FightConfigPanel:OnBulletOff()
	panelBullet.Background = Converter.String2Brush(FightConfigBrush.Off);

	BulletScreenManager:setEnable(false)
end

--开弹幕
function FightConfigPanel:OnBulletOn()
	panelBullet.Background = Converter.String2Brush(FightConfigBrush.On);
	BulletScreenManager:setEnable(true)
end

--修改bgm的音量
function FightConfigPanel:OnChangeBgmVolume()
	if SystemPanel.soundFlag then
		SoundManager:setBgmVolume(bgmVolume.CurValue/100);
	end
    bgmProgress.CurValue = bgmVolume.CurValue;
end

--修改音效音量
function FightConfigPanel:OnChangeEffectVolume()
	if SystemPanel.soundEffectFlag then
		SoundManager:setEffectVolume(soundVolume.CurValue/100);
	end
	soundProgress.CurValue =  soundVolume.CurValue;
end

--继续游戏
function FightConfigPanel:onContinue()
	SceneRenderStep:Continue();
	FightManager:ResumeAction();
	FightManager:ResumeEffectScript();
	FightUIManager:resumeTime();
	self:Hide();
end

--退出游戏
function FightConfigPanel:onClose()
	appFramework.TimeScale = Configuration.FightTimeScaleList[1];
	-- 特殊玩法处理
	if FightManager.mFightType == FightType.arena or
		FightManager.mFightType == FightType.rank or
		FightManager.mFightType == FightType.unionBattle or
		FightManager.mFightType == FightType.scuffle then
		self:onContinue();
		FightManager:setAllLeftRoleDie();
		return;
	end 

    SceneRenderStep:Continue();
    --FightManager:ResumeAction();
    effectScriptManager:DestroyAllEffectScript();
    FightUIManager:resumeTime();
    self:Hide();
    SoundManager:StopFightSound();
    FightOverUIManager:realTryAgain();
    --	FightOverUIManager:realReturnToPveBarrier();

    if platformSDK.m_System ~= 'Win32' then
        os.remove(appFramework:GetCachePath() .. 'debug.txt');
    end

end


--获取动画状态
function FightConfigPanel:getAnimStatus()
	return animStatus;
end
