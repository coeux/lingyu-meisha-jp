H009_auto607_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H009_auto607_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H009_auto607_attack.info_pool[effectScript.ID].Attacker)
        
		H009_auto607_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfsdg" )
		effectScript:RegisterEvent( 8, "hjgjkj" )
	end,

	sfsdg = function( effectScript )
		SetAnimation(H009_auto607_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	hjgjkj = function( effectScript )
			DamageEffect(H009_auto607_attack.info_pool[effectScript.ID].Attacker, H009_auto607_attack.info_pool[effectScript.ID].Targeter, H009_auto607_attack.info_pool[effectScript.ID].AttackType, H009_auto607_attack.info_pool[effectScript.ID].AttackDataList, H009_auto607_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
