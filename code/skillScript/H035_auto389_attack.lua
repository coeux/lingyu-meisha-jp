H035_auto389_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H035_auto389_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H035_auto389_attack.info_pool[effectScript.ID].Attacker)
        
		H035_auto389_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 9, "hgkk" )
	end,

	hgkk = function( effectScript )
			DamageEffect(H035_auto389_attack.info_pool[effectScript.ID].Attacker, H035_auto389_attack.info_pool[effectScript.ID].Targeter, H035_auto389_attack.info_pool[effectScript.ID].AttackType, H035_auto389_attack.info_pool[effectScript.ID].AttackDataList, H035_auto389_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
