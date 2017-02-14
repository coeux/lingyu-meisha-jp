S690_magic_M104_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S690_magic_M104_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S690_magic_M104_attack.info_pool[effectScript.ID].Attacker)
        
		S690_magic_M104_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S563_1")
		PreLoadAvatar("S563_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgfdh" )
		effectScript:RegisterEvent( 22, "hgjjhgkh" )
		effectScript:RegisterEvent( 27, "dsgf" )
		effectScript:RegisterEvent( 29, "dsfg" )
	end,

	dgfdh = function( effectScript )
		SetAnimation(S690_magic_M104_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	hgjjhgkh = function( effectScript )
		AttachAvatarPosEffect(false, S690_magic_M104_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, -15), 1.5, 100, "S563_1")
	end,

	dsgf = function( effectScript )
		AttachAvatarPosEffect(false, S690_magic_M104_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2, 100, "S563_2")
	end,

	dsfg = function( effectScript )
			DamageEffect(S690_magic_M104_attack.info_pool[effectScript.ID].Attacker, S690_magic_M104_attack.info_pool[effectScript.ID].Targeter, S690_magic_M104_attack.info_pool[effectScript.ID].AttackType, S690_magic_M104_attack.info_pool[effectScript.ID].AttackDataList, S690_magic_M104_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
