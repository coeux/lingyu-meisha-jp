M069_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M069_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M069_normal_attack.info_pool[effectScript.ID].Attacker)
		M069_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 16, "vv" )
	end,

	a = function( effectScript )
		SetAnimation(M069_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	vv = function( effectScript )
			DamageEffect(M069_normal_attack.info_pool[effectScript.ID].Attacker, M069_normal_attack.info_pool[effectScript.ID].Targeter, M069_normal_attack.info_pool[effectScript.ID].AttackType, M069_normal_attack.info_pool[effectScript.ID].AttackDataList, M069_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
