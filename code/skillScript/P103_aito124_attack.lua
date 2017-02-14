P103_aito124_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P103_aito124_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P103_aito124_attack.info_pool[effectScript.ID].Attacker)
		P103_aito124_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S122_daoguang")
		PreLoadAvatar("S122_shouji")
		PreLoadAvatar("S122_shifa")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfsf" )
		effectScript:RegisterEvent( 17, "dadwf" )
		effectScript:RegisterEvent( 21, "adf" )
		effectScript:RegisterEvent( 27, "aff" )
		effectScript:RegisterEvent( 34, "asd" )
		effectScript:RegisterEvent( 39, "asffffd" )
		effectScript:RegisterEvent( 49, "safsfd" )
	end,

	sfsf = function( effectScript )
		SetAnimation(P103_aito124_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	dadwf = function( effectScript )
		AttachAvatarPosEffect(false, P103_aito124_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(65, 75), 1.2, 100, "S122_daoguang")
	end,

	adf = function( effectScript )
		AttachAvatarPosEffect(false, P103_aito124_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 50), -1.5, 100, "S122_shouji")
	end,

	aff = function( effectScript )
		AttachAvatarPosEffect(false, P103_aito124_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, 50), 1.2, 100, "S122_shifa")
	end,

	asd = function( effectScript )
			DamageEffect(P103_aito124_attack.info_pool[effectScript.ID].Attacker, P103_aito124_attack.info_pool[effectScript.ID].Targeter, P103_aito124_attack.info_pool[effectScript.ID].AttackType, P103_aito124_attack.info_pool[effectScript.ID].AttackDataList, P103_aito124_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	asffffd = function( effectScript )
			DamageEffect(P103_aito124_attack.info_pool[effectScript.ID].Attacker, P103_aito124_attack.info_pool[effectScript.ID].Targeter, P103_aito124_attack.info_pool[effectScript.ID].AttackType, P103_aito124_attack.info_pool[effectScript.ID].AttackDataList, P103_aito124_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	safsfd = function( effectScript )
			DamageEffect(P103_aito124_attack.info_pool[effectScript.ID].Attacker, P103_aito124_attack.info_pool[effectScript.ID].Targeter, P103_aito124_attack.info_pool[effectScript.ID].AttackType, P103_aito124_attack.info_pool[effectScript.ID].AttackDataList, P103_aito124_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
