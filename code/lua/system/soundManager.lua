--soundManager.lua

--========================================================================
--声音管理类

SoundType = 
{
	scene		= 1,		--场景
	fight		= 2,		--战斗
};

SoundManager =
{
	mainCitysoundVolume = 0.5;
	TitleSoundVolume = 0.5;
	fightsoundVolume = 1;
	effectVolume = 1;

	UIClickSound		= GlobalData:GetResDir() .. 'resource/sound/ui_click.mp3';	--UI点击声音
	TitleSound			= GlobalData:GetResDir() .. 'resource/sound/title.mp3';		--标题音乐
	MainCitySound		= GlobalData:GetResDir() .. 'resource/sound/city.mp3';		--主城音乐
	BossSound			= GlobalData:GetResDir() .. 'resource/sound/boss.mp3';		--Boss战音乐
	FightSound			= GlobalData:GetResDir() .. 'resource/sound/battle.mp3';		--战斗音乐

	WinSound			= GlobalData:GetResDir() .. 'resource/sound/win.mp3';			--战斗胜利音乐
	LostSound			= GlobalData:GetResDir() .. 'resource/sound/lose.mp3';		--战斗失败音乐
};


local backgroundSound;
local fightSound;
local titleSound;

local backgroundSoundTimer = 0;
local backgroundVolume = 0;
local step = 0;

--初始化
function SoundManager:Init()
	local curSysTime = os.time();
	if tonumber(curSysTime) >= 1483196400 and tonumber(curSysTime) <= 1483801200 then
		SoundManager.TitleSound			= GlobalData:GetResDir() .. 'resource/sound/title_1.mp3';		--标题音乐
		SoundManager.MainCitySound		= GlobalData:GetResDir() .. 'resource/sound/city_1.mp3';		--主城音乐
		SoundManager.BossSound			= GlobalData:GetResDir() .. 'resource/sound/boss_1.mp3';		--Boss战音乐
		SoundManager.FightSound			= GlobalData:GetResDir() .. 'resource/sound/battle_1.mp3';		--战斗音乐
	else
		SoundManager.TitleSound			= GlobalData:GetResDir() .. 'resource/sound/title.mp3';		--标题音乐
		SoundManager.MainCitySound		= GlobalData:GetResDir() .. 'resource/sound/city.mp3';		--主城音乐
		SoundManager.BossSound			= GlobalData:GetResDir() .. 'resource/sound/boss.mp3';		--Boss战音乐
		SoundManager.FightSound			= GlobalData:GetResDir() .. 'resource/sound/battle.mp3';		--战斗音乐
	end
	uiSystem:SubscribeGlobalScriptedEvent('Button::ClickEvent', 'SoundManager:onUIClick');
end

function SoundManager:Destroy()
	uiSystem:UnSubscribeGlobalScriptedEvent('Button::ClickEvent', 'SoundManager:onUIClick');
end

--播放背景音乐
function SoundManager:PlayBackgroundSound()
	if titleSound then
		titleSound:SetPause(true);
	end
	if backgroundSound ~= nil then
		backgroundSound:SetPause(false);

		if SystemPanel.soundFlag then
			backgroundVolume = backgroundSound.Volume;
			backgroundSound.Volume = 0;
			backgroundSoundTimer = timerManager:CreateTimer(0.02, 'SoundManager:onBackgroundSoundRecover', 0);
		else
			backgroundSound.Volume = 0;
		end
	else
		backgroundSound = soundManager:PlaySound(self.MainCitySound, SoundSourceType.MainScene, true, true, false);
		if backgroundSound ~= nil then 	
			if SystemPanel.soundFlag then
				backgroundSound.Volume = self.mainCitysoundVolume;
			else
				backgroundSound.Volume = 0;
			end
		end
	end
end

function SoundManager:PlayTitleSound()
	if not titleSound then
		titleSound = soundManager:PlaySound(self.TitleSound, SoundSourceType.MainScene, true, true, false);
		if titleSound ~= nil then 	
			if SystemPanel.soundFlag then
				titleSound.Volume = self.TitleSoundVolume;
			else
				titleSound.Volume = 0;
			end
		end
	end
end

--背景音乐渐变放大
function SoundManager:onBackgroundSoundRecover()
	local v = backgroundSound.Volume + 0.01;
	if v >= backgroundVolume then
		v = backgroundVolume;
		timerManager:DestroyTimer(backgroundSoundTimer);
		backgroundSoundTimer = 0;
	end

	backgroundSound.Volume = v;
end

--背景音乐暂停或继续
function SoundManager:PauseBackgroundSound()
	if backgroundSound == nil then
		return;
	end

	if backgroundSoundTimer ~= 0 then
		timerManager:DestroyTimer(backgroundSoundTimer);
		backgroundSoundTimer = 0;
		backgroundSound.Volume = backgroundVolume;
	end

	backgroundSound:SetPause(true);
end

--设置背景音乐开关
function SoundManager:SetBackgroundSound( flag )
	if backgroundSound == nil then
		return;
	end

	if flag then
		backgroundSound.Volume = self.mainCitysoundVolume;
	else
		backgroundSound.Volume = 0;
	end
end

--播放战斗音乐
function SoundManager:PlayFightSound( EliteFlag )
	if EliteFlag then
		fightSound = soundManager:PlaySound(self.BossSound, SoundSourceType.FightScene, true, true, true);
		if not fightSound then
			return
		end

		if appFramework:IsInBackground() or not SystemPanel.soundFlag then
			fightSound.Volume = 0;
		else
			fightSound.Volume = self.fightsoundVolume;
		end
	else
		fightSound = soundManager:PlaySound(self.FightSound, SoundSourceType.FightScene, true, true, true);
		if not fightSound then
			return
		end

		if appFramework:IsInBackground() or not SystemPanel.soundFlag then
			fightSound.Volume = 0;
		else
			fightSound.Volume = self.fightsoundVolume;
		end
	end
end

--战斗音乐停止
function SoundManager:StopFightSound()
	soundManager:DestroySource(fightSound);
end

--播放音效
function SoundManager:PlayEffect( effectName )
	if appFramework:IsInBackground() or not SystemPanel.soundEffectFlag then
		return nil;
	end

	local effect = soundManager:PlaySound(GlobalData:GetResDir() .. 'resource/sound/' .. effectName .. '.mp3', SoundSourceType.Fight, false, false, true);
	if (effect == nil) then
		PrintLog('sound resource miss path = ' .. GlobalData:GetResDir() .. 'resource/sound/' .. effectName .. '.mp3');
		return nil;
	end

	effect.Volume = self.effectVolume;

	return effect;
end

--播放声优
function SoundManager:PlayVoice( voiceName )
	if appFramework:IsInBackground() or not SystemPanel.soundEffectFlag then
		return nil;
	end
	Debug.assert(voiceName, "voiceName is empty")

	local effect = soundManager:PlaySound(GlobalData:GetResDir() .. 'resource/sound/voice/' .. voiceName .. '.mp3', SoundSourceType.UI, false, false, true);
	if (effect == nil) then
		PrintLog('sound resource miss path = ' .. GlobalData:GetResDir() .. 'resource/sound/voice/' .. voiceName .. '.mp3');
		return nil;
	end

	effect.Volume = self.effectVolume;

	return effect;
end

--播放UI按钮按下
function SoundManager:onUIClick()
	if SystemPanel.soundEffectFlag then
		soundManager:PlaySound(self.UIClickSound, SoundSourceType.UI, false, false, true);
	end
end


--获取当前战斗背景音量
function SoundManager:getBgmVolume()
	return self.fightsoundVolume;
end


--获取当前音效音量
function SoundManager:getEffectVolume()
	return self.effectVolume;
end

--设置当前战斗背景音量
function SoundManager:setBgmVolume(volume)
	self.fightsoundVolume = volume;
	fightSound.Volume = self.fightsoundVolume;
end

--设置当前音效的ProgressBar
function SoundManager:setBgmproBar(volume)
	bgmProgressBar.CurValue = volume
end

--设置当前音效音量
function SoundManager:setEffectVolume(volume)
	self.effectVolume = volume;
end
