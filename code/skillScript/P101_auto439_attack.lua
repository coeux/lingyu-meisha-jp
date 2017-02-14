P101_auto439_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P101_auto439_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P101_auto439_attack.info_pool[effectScript.ID].Attacker)
        
		P101_auto439_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "safdsg" )
		effectScript:RegisterEvent( 8, "kjhkjl" )
	end,

	safdsg = function( effectScript )
		SetAnimation(P101_auto439_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	kjhkjl = function( effectScript )
			DamageEffect(P101_auto439_attack.info_pool[effectScript.ID].Attacker, P101_auto439_attack.info_pool[effectScript.ID].Targeter, P101_auto439_attack.info_pool[effectScript.ID].AttackType, P101_auto439_attack.info_pool[effectScript.ID].AttackDataList, P101_auto439_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
