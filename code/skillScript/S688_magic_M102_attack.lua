S688_magic_M102_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S688_magic_M102_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S688_magic_M102_attack.info_pool[effectScript.ID].Attacker)
        
		S688_magic_M102_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sadsf" )
		effectScript:RegisterEvent( 8, "dsfgdh" )
	end,

	sadsf = function( effectScript )
		SetAnimation(S688_magic_M102_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	dsfgdh = function( effectScript )
			DamageEffect(S688_magic_M102_attack.info_pool[effectScript.ID].Attacker, S688_magic_M102_attack.info_pool[effectScript.ID].Targeter, S688_magic_M102_attack.info_pool[effectScript.ID].AttackType, S688_magic_M102_attack.info_pool[effectScript.ID].AttackDataList, S688_magic_M102_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
