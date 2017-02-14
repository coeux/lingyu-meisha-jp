M087_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M087_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M087_normal_attack.info_pool[effectScript.ID].Attacker)
		M087_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("thor")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "w" )
		effectScript:RegisterEvent( 16, "f" )
	end,

	w = function( effectScript )
		SetAnimation(M087_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("thor")
	end,

	f = function( effectScript )
			DamageEffect(M087_normal_attack.info_pool[effectScript.ID].Attacker, M087_normal_attack.info_pool[effectScript.ID].Targeter, M087_normal_attack.info_pool[effectScript.ID].AttackType, M087_normal_attack.info_pool[effectScript.ID].AttackDataList, M087_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
