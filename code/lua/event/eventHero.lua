--eventHero.lua

--========================================================================
--主角
--========================================================================

--升级（回到主城升级）
function Event:OnHeroLevelUp( oldLevel, newLevel, deltaFP )
	
    --显示属性变化
    RoleLevelUpPanel:Show();

	--升级效果表现
	local path = GlobalData.EffectPath .. 'levelup_output/';
	AvatarManager:LoadFile(path);
	local armature = sceneManager:CreateSceneNode('Armature');
	armature.ZOrder = -1;
	armature:LoadArmature('levelup_01');
	armature:SetAnimation('play');
	ActorManager.hero:AttachEffect(AvatarPos.root, armature);
	
	armature = sceneManager:CreateSceneNode('Armature');
	armature.ZOrder = 100;
	armature:LoadArmature('levelup_02');
	armature:SetAnimation('play');
	ActorManager.hero:AttachEffect(AvatarPos.root, armature);

	--播放升级声音
	-- SoundManager:PlayEffect('apollo2');
	SoundManager:PlayEffect('user_level_up')
	
--[[	--在主界面播放主角升级特效
	PlayEffect('shengliyanhua_output/' , Rect.ZERO, 'shengliyanhua');--]]
	
	--战斗力改变
	-- FightPoint:ShowFP(deltaFP);

	--=======================================================================
	--=======================================================================
	
	--升级推送信息
	MainUI:AddLocalLetter(newLevel);
	--更新主城NPC状态
	Task:UpdateMainSceneUI();

end
