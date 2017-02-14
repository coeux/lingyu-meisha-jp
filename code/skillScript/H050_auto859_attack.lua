H050_auto859_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H050_auto859_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H050_auto859_attack.info_pool[effectScript.ID].Attacker)
        
		H050_auto859_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "drftg" )
		effectScript:RegisterEvent( 6, "df" )
	end,

	drftg = function( effectScript )
		SetAnimation(H050_auto859_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	df = function( effectScript )
			DamageEffect(H050_auto859_attack.info_pool[effectScript.ID].Attacker, H050_auto859_attack.info_pool[effectScript.ID].Targeter, H050_auto859_attack.info_pool[effectScript.ID].AttackType, H050_auto859_attack.info_pool[effectScript.ID].AttackDataList, H050_auto859_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
