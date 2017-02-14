H038_auto736_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H038_auto736_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H038_auto736_attack.info_pool[effectScript.ID].Attacker)
        
		H038_auto736_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfdhgjh" )
		effectScript:RegisterEvent( 8, "gfhghjk" )
	end,

	dsfdhgjh = function( effectScript )
		SetAnimation(H038_auto736_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	gfhghjk = function( effectScript )
			DamageEffect(H038_auto736_attack.info_pool[effectScript.ID].Attacker, H038_auto736_attack.info_pool[effectScript.ID].Targeter, H038_auto736_attack.info_pool[effectScript.ID].AttackType, H038_auto736_attack.info_pool[effectScript.ID].AttackDataList, H038_auto736_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
