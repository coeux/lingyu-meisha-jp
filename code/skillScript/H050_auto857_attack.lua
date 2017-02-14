H050_auto857_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H050_auto857_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H050_auto857_attack.info_pool[effectScript.ID].Attacker)
        
		H050_auto857_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ftg" )
		effectScript:RegisterEvent( 6, "sf" )
	end,

	ftg = function( effectScript )
		SetAnimation(H050_auto857_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	sf = function( effectScript )
			DamageEffect(H050_auto857_attack.info_pool[effectScript.ID].Attacker, H050_auto857_attack.info_pool[effectScript.ID].Targeter, H050_auto857_attack.info_pool[effectScript.ID].AttackType, H050_auto857_attack.info_pool[effectScript.ID].AttackDataList, H050_auto857_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
