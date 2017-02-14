H101_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H101_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H101_normal_attack.info_pool[effectScript.ID].Attacker)
		H101_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 13, "d" )
	end,

	a = function( effectScript )
		SetAnimation(H101_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	d = function( effectScript )
			DamageEffect(H101_normal_attack.info_pool[effectScript.ID].Attacker, H101_normal_attack.info_pool[effectScript.ID].Targeter, H101_normal_attack.info_pool[effectScript.ID].AttackType, H101_normal_attack.info_pool[effectScript.ID].AttackDataList, H101_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
