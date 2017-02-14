H051_auto868_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H051_auto868_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H051_auto868_attack.info_pool[effectScript.ID].Attacker)
        
		H051_auto868_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "xdrfg" )
		effectScript:RegisterEvent( 6, "dftg" )
	end,

	xdrfg = function( effectScript )
		SetAnimation(H051_auto868_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	dftg = function( effectScript )
			DamageEffect(H051_auto868_attack.info_pool[effectScript.ID].Attacker, H051_auto868_attack.info_pool[effectScript.ID].Targeter, H051_auto868_attack.info_pool[effectScript.ID].AttackType, H051_auto868_attack.info_pool[effectScript.ID].AttackDataList, H051_auto868_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
