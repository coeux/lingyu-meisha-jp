H053_auto889_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H053_auto889_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H053_auto889_attack.info_pool[effectScript.ID].Attacker)
        
		H053_auto889_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fyhuji" )
		effectScript:RegisterEvent( 6, "dvgbhnj" )
	end,

	fyhuji = function( effectScript )
		SetAnimation(H053_auto889_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	dvgbhnj = function( effectScript )
			DamageEffect(H053_auto889_attack.info_pool[effectScript.ID].Attacker, H053_auto889_attack.info_pool[effectScript.ID].Targeter, H053_auto889_attack.info_pool[effectScript.ID].AttackType, H053_auto889_attack.info_pool[effectScript.ID].AttackDataList, H053_auto889_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
