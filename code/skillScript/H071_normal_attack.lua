H071_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H071_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H071_normal_attack.info_pool[effectScript.ID].Attacker)
		H071_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 17, "b" )
	end,

	a = function( effectScript )
		SetAnimation(H071_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	b = function( effectScript )
			DamageEffect(H071_normal_attack.info_pool[effectScript.ID].Attacker, H071_normal_attack.info_pool[effectScript.ID].Targeter, H071_normal_attack.info_pool[effectScript.ID].AttackType, H071_normal_attack.info_pool[effectScript.ID].AttackDataList, H071_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
