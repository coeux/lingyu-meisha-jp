S145_magic_P101_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S145_magic_P101_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S145_magic_P101_attack.info_pool[effectScript.ID].Attacker)
        
		S145_magic_P101_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s01013")
		PreLoadAvatar("S144")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 25, "aaa" )
		effectScript:RegisterEvent( 53, "a1" )
		effectScript:RegisterEvent( 58, "aa" )
		effectScript:RegisterEvent( 62, "g" )
		effectScript:RegisterEvent( 67, "e" )
	end,

	a = function( effectScript )
		SetAnimation(S145_magic_P101_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("s01013")
	end,

	aaa = function( effectScript )
		SetAnimation(S145_magic_P101_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	a1 = function( effectScript )
		AttachAvatarPosEffect(false, S145_magic_P101_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(230, 90), 3, 100, "S144")
	end,

	aa = function( effectScript )
			DamageEffect(S145_magic_P101_attack.info_pool[effectScript.ID].Attacker, S145_magic_P101_attack.info_pool[effectScript.ID].Targeter, S145_magic_P101_attack.info_pool[effectScript.ID].AttackType, S145_magic_P101_attack.info_pool[effectScript.ID].AttackDataList, S145_magic_P101_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	g = function( effectScript )
			DamageEffect(S145_magic_P101_attack.info_pool[effectScript.ID].Attacker, S145_magic_P101_attack.info_pool[effectScript.ID].Targeter, S145_magic_P101_attack.info_pool[effectScript.ID].AttackType, S145_magic_P101_attack.info_pool[effectScript.ID].AttackDataList, S145_magic_P101_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	e = function( effectScript )
			DamageEffect(S145_magic_P101_attack.info_pool[effectScript.ID].Attacker, S145_magic_P101_attack.info_pool[effectScript.ID].Targeter, S145_magic_P101_attack.info_pool[effectScript.ID].AttackType, S145_magic_P101_attack.info_pool[effectScript.ID].AttackDataList, S145_magic_P101_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
