H058_auto936_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H058_auto936_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H058_auto936_attack.info_pool[effectScript.ID].Attacker)
        
		H058_auto936_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fcv" )
		effectScript:RegisterEvent( 6, "fb" )
	end,

	fcv = function( effectScript )
		SetAnimation(H058_auto936_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	fb = function( effectScript )
			DamageEffect(H058_auto936_attack.info_pool[effectScript.ID].Attacker, H058_auto936_attack.info_pool[effectScript.ID].Targeter, H058_auto936_attack.info_pool[effectScript.ID].AttackType, H058_auto936_attack.info_pool[effectScript.ID].AttackDataList, H058_auto936_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
