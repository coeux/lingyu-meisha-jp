H032_auto409_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H032_auto409_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H032_auto409_attack.info_pool[effectScript.ID].Attacker)
        
		H032_auto409_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdg" )
		effectScript:RegisterEvent( 7, "fdg" )
	end,

	sfdg = function( effectScript )
		SetAnimation(H032_auto409_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	fdg = function( effectScript )
			DamageEffect(H032_auto409_attack.info_pool[effectScript.ID].Attacker, H032_auto409_attack.info_pool[effectScript.ID].Targeter, H032_auto409_attack.info_pool[effectScript.ID].AttackType, H032_auto409_attack.info_pool[effectScript.ID].AttackDataList, H032_auto409_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
