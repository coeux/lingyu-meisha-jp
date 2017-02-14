S144_magic_P101_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S144_magic_P101_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S144_magic_P101_attack.info_pool[effectScript.ID].Attacker)
        
		S144_magic_P101_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("s01013")
		PreLoadAvatar("S144")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 45, "aaa" )
		effectScript:RegisterEvent( 73, "a1" )
		effectScript:RegisterEvent( 78, "aa" )
		effectScript:RegisterEvent( 82, "g" )
		effectScript:RegisterEvent( 87, "e" )
	end,

	a = function( effectScript )
		SetAnimation(S144_magic_P101_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
		PlaySound("s01013")
	end,

	aaa = function( effectScript )
		SetAnimation(S144_magic_P101_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	a1 = function( effectScript )
		AttachAvatarPosEffect(false, S144_magic_P101_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(230, 90), 3, 100, "S144")
	end,

	aa = function( effectScript )
			DamageEffect(S144_magic_P101_attack.info_pool[effectScript.ID].Attacker, S144_magic_P101_attack.info_pool[effectScript.ID].Targeter, S144_magic_P101_attack.info_pool[effectScript.ID].AttackType, S144_magic_P101_attack.info_pool[effectScript.ID].AttackDataList, S144_magic_P101_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	g = function( effectScript )
			DamageEffect(S144_magic_P101_attack.info_pool[effectScript.ID].Attacker, S144_magic_P101_attack.info_pool[effectScript.ID].Targeter, S144_magic_P101_attack.info_pool[effectScript.ID].AttackType, S144_magic_P101_attack.info_pool[effectScript.ID].AttackDataList, S144_magic_P101_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	e = function( effectScript )
			DamageEffect(S144_magic_P101_attack.info_pool[effectScript.ID].Attacker, S144_magic_P101_attack.info_pool[effectScript.ID].Targeter, S144_magic_P101_attack.info_pool[effectScript.ID].AttackType, S144_magic_P101_attack.info_pool[effectScript.ID].AttackDataList, S144_magic_P101_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
