H022_auto561_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H022_auto561_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H022_auto561_attack.info_pool[effectScript.ID].Attacker)
        
		H022_auto561_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sf" )
		effectScript:RegisterEvent( 30, "jhgjhk" )
	end,

	sf = function( effectScript )
		SetAnimation(H022_auto561_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	jhgjhk = function( effectScript )
			DamageEffect(H022_auto561_attack.info_pool[effectScript.ID].Attacker, H022_auto561_attack.info_pool[effectScript.ID].Targeter, H022_auto561_attack.info_pool[effectScript.ID].AttackType, H022_auto561_attack.info_pool[effectScript.ID].AttackDataList, H022_auto561_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
