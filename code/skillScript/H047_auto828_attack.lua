H047_auto828_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H047_auto828_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H047_auto828_attack.info_pool[effectScript.ID].Attacker)
        
		H047_auto828_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfgdghfjj" )
		effectScript:RegisterEvent( 7, "fdgfj" )
	end,

	dfgdghfjj = function( effectScript )
		SetAnimation(H047_auto828_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	fdgfj = function( effectScript )
			DamageEffect(H047_auto828_attack.info_pool[effectScript.ID].Attacker, H047_auto828_attack.info_pool[effectScript.ID].Targeter, H047_auto828_attack.info_pool[effectScript.ID].AttackType, H047_auto828_attack.info_pool[effectScript.ID].AttackDataList, H047_auto828_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
