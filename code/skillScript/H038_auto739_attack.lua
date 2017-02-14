H038_auto739_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H038_auto739_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H038_auto739_attack.info_pool[effectScript.ID].Attacker)
        
		H038_auto739_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfdhj" )
		effectScript:RegisterEvent( 8, "fdgjj" )
	end,

	dsfdhj = function( effectScript )
		SetAnimation(H038_auto739_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	fdgjj = function( effectScript )
			DamageEffect(H038_auto739_attack.info_pool[effectScript.ID].Attacker, H038_auto739_attack.info_pool[effectScript.ID].Targeter, H038_auto739_attack.info_pool[effectScript.ID].AttackType, H038_auto739_attack.info_pool[effectScript.ID].AttackDataList, H038_auto739_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
