H011_auto609_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H011_auto609_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H011_auto609_attack.info_pool[effectScript.ID].Attacker)
        
		H011_auto609_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "d" )
		effectScript:RegisterEvent( 8, "jhgjhk" )
	end,

	d = function( effectScript )
		SetAnimation(H011_auto609_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	jhgjhk = function( effectScript )
			DamageEffect(H011_auto609_attack.info_pool[effectScript.ID].Attacker, H011_auto609_attack.info_pool[effectScript.ID].Targeter, H011_auto609_attack.info_pool[effectScript.ID].AttackType, H011_auto609_attack.info_pool[effectScript.ID].AttackDataList, H011_auto609_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
