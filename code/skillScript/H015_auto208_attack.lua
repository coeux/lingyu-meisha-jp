H015_auto208_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H015_auto208_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H015_auto208_attack.info_pool[effectScript.ID].Attacker)
        
		H015_auto208_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 8, "fdgfh" )
	end,

	a = function( effectScript )
		SetAnimation(H015_auto208_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	fdgfh = function( effectScript )
			DamageEffect(H015_auto208_attack.info_pool[effectScript.ID].Attacker, H015_auto208_attack.info_pool[effectScript.ID].Targeter, H015_auto208_attack.info_pool[effectScript.ID].AttackType, H015_auto208_attack.info_pool[effectScript.ID].AttackDataList, H015_auto208_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
