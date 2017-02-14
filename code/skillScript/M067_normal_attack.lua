M067_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M067_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M067_normal_attack.info_pool[effectScript.ID].Attacker)
		M067_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 15, "as" )
	end,

	a = function( effectScript )
		SetAnimation(M067_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	as = function( effectScript )
			DamageEffect(M067_normal_attack.info_pool[effectScript.ID].Attacker, M067_normal_attack.info_pool[effectScript.ID].Targeter, M067_normal_attack.info_pool[effectScript.ID].AttackType, M067_normal_attack.info_pool[effectScript.ID].AttackDataList, M067_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
