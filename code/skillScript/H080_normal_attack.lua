H080_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H080_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H080_normal_attack.info_pool[effectScript.ID].Attacker)
		H080_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("juewangjuji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "as" )
		effectScript:RegisterEvent( 15, "sdsdf" )
	end,

	as = function( effectScript )
		SetAnimation(H080_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	sdsdf = function( effectScript )
			DamageEffect(H080_normal_attack.info_pool[effectScript.ID].Attacker, H080_normal_attack.info_pool[effectScript.ID].Targeter, H080_normal_attack.info_pool[effectScript.ID].AttackType, H080_normal_attack.info_pool[effectScript.ID].AttackDataList, H080_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("juewangjuji")
	end,

}
