S140_magic_P101_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S140_magic_P101_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S140_magic_P101_attack.info_pool[effectScript.ID].Attacker)
        
		S140_magic_P101_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s01011")
		PreLoadAvatar("S140")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aaa" )
		effectScript:RegisterEvent( 17, "a1" )
		effectScript:RegisterEvent( 25, "aa" )
	end,

	aaa = function( effectScript )
		SetAnimation(S140_magic_P101_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("s01011")
	end,

	a1 = function( effectScript )
		AttachAvatarPosEffect(false, S140_magic_P101_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(250, 30), 3.5, 100, "S140")
	end,

	aa = function( effectScript )
			DamageEffect(S140_magic_P101_attack.info_pool[effectScript.ID].Attacker, S140_magic_P101_attack.info_pool[effectScript.ID].Targeter, S140_magic_P101_attack.info_pool[effectScript.ID].AttackType, S140_magic_P101_attack.info_pool[effectScript.ID].AttackDataList, S140_magic_P101_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
