H028_auto459_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H028_auto459_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H028_auto459_attack.info_pool[effectScript.ID].Attacker)
        
		H028_auto459_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfdh" )
		effectScript:RegisterEvent( 8, "dsgdfh" )
	end,

	dsfdh = function( effectScript )
		SetAnimation(H028_auto459_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	dsgdfh = function( effectScript )
			DamageEffect(H028_auto459_attack.info_pool[effectScript.ID].Attacker, H028_auto459_attack.info_pool[effectScript.ID].Targeter, H028_auto459_attack.info_pool[effectScript.ID].AttackType, H028_auto459_attack.info_pool[effectScript.ID].AttackDataList, H028_auto459_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
