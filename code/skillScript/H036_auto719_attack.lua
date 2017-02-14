H036_auto719_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H036_auto719_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H036_auto719_attack.info_pool[effectScript.ID].Attacker)
        
		H036_auto719_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fgh" )
		effectScript:RegisterEvent( 9, "gfjhj" )
	end,

	fgh = function( effectScript )
		SetAnimation(H036_auto719_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	gfjhj = function( effectScript )
			DamageEffect(H036_auto719_attack.info_pool[effectScript.ID].Attacker, H036_auto719_attack.info_pool[effectScript.ID].Targeter, H036_auto719_attack.info_pool[effectScript.ID].AttackType, H036_auto719_attack.info_pool[effectScript.ID].AttackDataList, H036_auto719_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
