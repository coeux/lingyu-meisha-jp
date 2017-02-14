H044_auto799_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H044_auto799_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H044_auto799_attack.info_pool[effectScript.ID].Attacker)
        
		H044_auto799_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdgfgh" )
		effectScript:RegisterEvent( 9, "dgfdhgfj" )
	end,

	sfdgfgh = function( effectScript )
		SetAnimation(H044_auto799_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	dgfdhgfj = function( effectScript )
			DamageEffect(H044_auto799_attack.info_pool[effectScript.ID].Attacker, H044_auto799_attack.info_pool[effectScript.ID].Targeter, H044_auto799_attack.info_pool[effectScript.ID].AttackType, H044_auto799_attack.info_pool[effectScript.ID].AttackDataList, H044_auto799_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
