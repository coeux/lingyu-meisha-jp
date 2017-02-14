H043_auto787_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H043_auto787_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H043_auto787_attack.info_pool[effectScript.ID].Attacker)
        
		H043_auto787_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsgfdhhj" )
		effectScript:RegisterEvent( 8, "fdgfjh" )
	end,

	dsgfdhhj = function( effectScript )
		end,

	fdgfjh = function( effectScript )
			DamageEffect(H043_auto787_attack.info_pool[effectScript.ID].Attacker, H043_auto787_attack.info_pool[effectScript.ID].Targeter, H043_auto787_attack.info_pool[effectScript.ID].AttackType, H043_auto787_attack.info_pool[effectScript.ID].AttackDataList, H043_auto787_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
