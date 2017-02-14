M020_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M020_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M020_normal_attack.info_pool[effectScript.ID].Attacker)
		M020_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 22, "f" )
		effectScript:RegisterEvent( 23, "d" )
	end,

	a = function( effectScript )
		SetAnimation(M020_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	f = function( effectScript )
		CameraShake()
		PlaySound("")
	end,

	d = function( effectScript )
			DamageEffect(M020_normal_attack.info_pool[effectScript.ID].Attacker, M020_normal_attack.info_pool[effectScript.ID].Targeter, M020_normal_attack.info_pool[effectScript.ID].AttackType, M020_normal_attack.info_pool[effectScript.ID].AttackDataList, M020_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
