S618_magic_H017_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S618_magic_H017_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S618_magic_H017_attack.info_pool[effectScript.ID].Attacker)
        
		S618_magic_H017_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01701")
		PreLoadSound("skill_01702")
		PreLoadAvatar("S210_2")
		PreLoadAvatar("S210_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "s" )
		effectScript:RegisterEvent( 2, "fds" )
		effectScript:RegisterEvent( 22, "d" )
		effectScript:RegisterEvent( 23, "fsdg" )
		effectScript:RegisterEvent( 24, "f" )
	end,

	s = function( effectScript )
		SetAnimation(S618_magic_H017_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
		PlaySound("stalk_01701")
		PlaySound("skill_01702")
	end,

	fds = function( effectScript )
		AttachAvatarPosEffect(false, S618_magic_H017_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(75, 100), 2.5, 100, "S210_2")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S618_magic_H017_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(250, 70), 1.5, 100, "S210_1")
	end,

	fsdg = function( effectScript )
		if S618_magic_H017_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(S618_magic_H017_attack.info_pool[effectScript.ID].Effect1);S618_magic_H017_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	f = function( effectScript )
			DamageEffect(S618_magic_H017_attack.info_pool[effectScript.ID].Attacker, S618_magic_H017_attack.info_pool[effectScript.ID].Targeter, S618_magic_H017_attack.info_pool[effectScript.ID].AttackType, S618_magic_H017_attack.info_pool[effectScript.ID].AttackDataList, S618_magic_H017_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
