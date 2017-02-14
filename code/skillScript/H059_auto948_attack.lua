H059_auto948_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H059_auto948_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H059_auto948_attack.info_pool[effectScript.ID].Attacker)
        
		H059_auto948_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "uju" )
		effectScript:RegisterEvent( 6, "db" )
	end,

	uju = function( effectScript )
		SetAnimation(H059_auto948_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	db = function( effectScript )
			DamageEffect(H059_auto948_attack.info_pool[effectScript.ID].Attacker, H059_auto948_attack.info_pool[effectScript.ID].Targeter, H059_auto948_attack.info_pool[effectScript.ID].AttackType, H059_auto948_attack.info_pool[effectScript.ID].AttackDataList, H059_auto948_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
