H024_auto573_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H024_auto573_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H024_auto573_attack.info_pool[effectScript.ID].Attacker)
        
		H024_auto573_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 8, "jhgkjh" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(H024_auto573_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	jhgkjh = function( effectScript )
			DamageEffect(H024_auto573_attack.info_pool[effectScript.ID].Attacker, H024_auto573_attack.info_pool[effectScript.ID].Targeter, H024_auto573_attack.info_pool[effectScript.ID].AttackType, H024_auto573_attack.info_pool[effectScript.ID].AttackDataList, H024_auto573_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
