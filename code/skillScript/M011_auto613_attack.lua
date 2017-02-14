M011_auto613_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M011_auto613_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M011_auto613_attack.info_pool[effectScript.ID].Attacker)
        
		M011_auto613_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsgfh" )
		effectScript:RegisterEvent( 8, "hgjhj" )
	end,

	dsgfh = function( effectScript )
		SetAnimation(M011_auto613_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	hgjhj = function( effectScript )
			DamageEffect(M011_auto613_attack.info_pool[effectScript.ID].Attacker, M011_auto613_attack.info_pool[effectScript.ID].Targeter, M011_auto613_attack.info_pool[effectScript.ID].AttackType, M011_auto613_attack.info_pool[effectScript.ID].AttackDataList, M011_auto613_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
