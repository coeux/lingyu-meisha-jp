H045_auto809_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H045_auto809_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H045_auto809_attack.info_pool[effectScript.ID].Attacker)
        
		H045_auto809_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sfdgfh" )
		effectScript:RegisterEvent( 7, "dsfdhghj" )
	end,

	sfdgfh = function( effectScript )
		SetAnimation(H045_auto809_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	dsfdhghj = function( effectScript )
			DamageEffect(H045_auto809_attack.info_pool[effectScript.ID].Attacker, H045_auto809_attack.info_pool[effectScript.ID].Targeter, H045_auto809_attack.info_pool[effectScript.ID].AttackType, H045_auto809_attack.info_pool[effectScript.ID].AttackDataList, H045_auto809_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
