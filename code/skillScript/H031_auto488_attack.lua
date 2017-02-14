H031_auto488_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H031_auto488_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H031_auto488_attack.info_pool[effectScript.ID].Attacker)
        
		H031_auto488_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfdg" )
		effectScript:RegisterEvent( 8, "fdh" )
	end,

	dsfdg = function( effectScript )
		SetAnimation(H031_auto488_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	fdh = function( effectScript )
			DamageEffect(H031_auto488_attack.info_pool[effectScript.ID].Attacker, H031_auto488_attack.info_pool[effectScript.ID].Targeter, H031_auto488_attack.info_pool[effectScript.ID].AttackType, H031_auto488_attack.info_pool[effectScript.ID].AttackDataList, H031_auto488_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
