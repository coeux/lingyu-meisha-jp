H056_auto918_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H056_auto918_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H056_auto918_attack.info_pool[effectScript.ID].Attacker)
        
		H056_auto918_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfv" )
		effectScript:RegisterEvent( 6, "sv" )
	end,

	sfv = function( effectScript )
		SetAnimation(H056_auto918_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	sv = function( effectScript )
			DamageEffect(H056_auto918_attack.info_pool[effectScript.ID].Attacker, H056_auto918_attack.info_pool[effectScript.ID].Targeter, H056_auto918_attack.info_pool[effectScript.ID].AttackType, H056_auto918_attack.info_pool[effectScript.ID].AttackDataList, H056_auto918_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
