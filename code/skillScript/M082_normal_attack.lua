M082_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M082_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M082_normal_attack.info_pool[effectScript.ID].Attacker)
		M082_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("slimehit")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 25, "d" )
	end,

	a = function( effectScript )
		SetAnimation(M082_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	d = function( effectScript )
			DamageEffect(M082_normal_attack.info_pool[effectScript.ID].Attacker, M082_normal_attack.info_pool[effectScript.ID].Targeter, M082_normal_attack.info_pool[effectScript.ID].AttackType, M082_normal_attack.info_pool[effectScript.ID].AttackDataList, M082_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("slimehit")
	end,

}
