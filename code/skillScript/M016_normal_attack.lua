M016_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M016_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M016_normal_attack.info_pool[effectScript.ID].Attacker)
		M016_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 12, "d" )
	end,

	a = function( effectScript )
		SetAnimation(M016_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	d = function( effectScript )
			DamageEffect(M016_normal_attack.info_pool[effectScript.ID].Attacker, M016_normal_attack.info_pool[effectScript.ID].Targeter, M016_normal_attack.info_pool[effectScript.ID].AttackType, M016_normal_attack.info_pool[effectScript.ID].AttackDataList, M016_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
