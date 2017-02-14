H033_auto498_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H033_auto498_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H033_auto498_attack.info_pool[effectScript.ID].Attacker)
        
		H033_auto498_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dgh" )
		effectScript:RegisterEvent( 7, "dfgdh" )
	end,

	dgh = function( effectScript )
		SetAnimation(H033_auto498_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	dfgdh = function( effectScript )
			DamageEffect(H033_auto498_attack.info_pool[effectScript.ID].Attacker, H033_auto498_attack.info_pool[effectScript.ID].Targeter, H033_auto498_attack.info_pool[effectScript.ID].AttackType, H033_auto498_attack.info_pool[effectScript.ID].AttackDataList, H033_auto498_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
