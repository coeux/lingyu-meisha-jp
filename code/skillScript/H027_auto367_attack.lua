H027_auto367_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H027_auto367_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H027_auto367_attack.info_pool[effectScript.ID].Attacker)
        
		H027_auto367_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfg" )
		effectScript:RegisterEvent( 6, "gd" )
	end,

	dsfg = function( effectScript )
		SetAnimation(H027_auto367_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	gd = function( effectScript )
			DamageEffect(H027_auto367_attack.info_pool[effectScript.ID].Attacker, H027_auto367_attack.info_pool[effectScript.ID].Targeter, H027_auto367_attack.info_pool[effectScript.ID].AttackType, H027_auto367_attack.info_pool[effectScript.ID].AttackDataList, H027_auto367_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
