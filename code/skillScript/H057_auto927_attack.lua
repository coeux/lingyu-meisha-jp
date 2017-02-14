H057_auto927_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H057_auto927_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H057_auto927_attack.info_pool[effectScript.ID].Attacker)
        
		H057_auto927_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "df" )
		effectScript:RegisterEvent( 6, "wsf" )
	end,

	df = function( effectScript )
		SetAnimation(H057_auto927_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	wsf = function( effectScript )
			DamageEffect(H057_auto927_attack.info_pool[effectScript.ID].Attacker, H057_auto927_attack.info_pool[effectScript.ID].Targeter, H057_auto927_attack.info_pool[effectScript.ID].AttackType, H057_auto927_attack.info_pool[effectScript.ID].AttackDataList, H057_auto927_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
