H025_auto286_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H025_auto286_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H025_auto286_attack.info_pool[effectScript.ID].Attacker)
        
		H025_auto286_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdg" )
		effectScript:RegisterEvent( 8, "ykjhk" )
	end,

	sfdg = function( effectScript )
		SetAnimation(H025_auto286_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	ykjhk = function( effectScript )
			DamageEffect(H025_auto286_attack.info_pool[effectScript.ID].Attacker, H025_auto286_attack.info_pool[effectScript.ID].Targeter, H025_auto286_attack.info_pool[effectScript.ID].AttackType, H025_auto286_attack.info_pool[effectScript.ID].AttackDataList, H025_auto286_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
