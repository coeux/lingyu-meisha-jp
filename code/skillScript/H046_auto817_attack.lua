H046_auto817_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H046_auto817_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H046_auto817_attack.info_pool[effectScript.ID].Attacker)
        
		H046_auto817_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fdgfhj" )
		effectScript:RegisterEvent( 8, "dsgh" )
	end,

	fdgfhj = function( effectScript )
		SetAnimation(H046_auto817_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	dsgh = function( effectScript )
			DamageEffect(H046_auto817_attack.info_pool[effectScript.ID].Attacker, H046_auto817_attack.info_pool[effectScript.ID].Targeter, H046_auto817_attack.info_pool[effectScript.ID].AttackType, H046_auto817_attack.info_pool[effectScript.ID].AttackDataList, H046_auto817_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
