H037_auto728_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H037_auto728_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H037_auto728_attack.info_pool[effectScript.ID].Attacker)
        
		H037_auto728_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sdfgdhh" )
		effectScript:RegisterEvent( 9, "fdgjh" )
	end,

	sdfgdhh = function( effectScript )
		SetAnimation(H037_auto728_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	fdgjh = function( effectScript )
			DamageEffect(H037_auto728_attack.info_pool[effectScript.ID].Attacker, H037_auto728_attack.info_pool[effectScript.ID].Targeter, H037_auto728_attack.info_pool[effectScript.ID].AttackType, H037_auto728_attack.info_pool[effectScript.ID].AttackDataList, H037_auto728_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
