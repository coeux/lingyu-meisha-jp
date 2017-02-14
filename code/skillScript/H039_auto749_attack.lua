H039_auto749_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H039_auto749_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H039_auto749_attack.info_pool[effectScript.ID].Attacker)
        
		H039_auto749_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dfgfhj" )
		effectScript:RegisterEvent( 10, "sdfdg" )
	end,

	dfgfhj = function( effectScript )
		SetAnimation(H039_auto749_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	sdfdg = function( effectScript )
			DamageEffect(H039_auto749_attack.info_pool[effectScript.ID].Attacker, H039_auto749_attack.info_pool[effectScript.ID].Targeter, H039_auto749_attack.info_pool[effectScript.ID].AttackType, H039_auto749_attack.info_pool[effectScript.ID].AttackDataList, H039_auto749_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
