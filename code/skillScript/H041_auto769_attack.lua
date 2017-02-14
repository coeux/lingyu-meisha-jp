H041_auto769_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H041_auto769_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H041_auto769_attack.info_pool[effectScript.ID].Attacker)
        
		H041_auto769_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfdhh" )
		effectScript:RegisterEvent( 7, "dsfdh" )
	end,

	dsfdhh = function( effectScript )
		SetAnimation(H041_auto769_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	dsfdh = function( effectScript )
			DamageEffect(H041_auto769_attack.info_pool[effectScript.ID].Attacker, H041_auto769_attack.info_pool[effectScript.ID].Targeter, H041_auto769_attack.info_pool[effectScript.ID].AttackType, H041_auto769_attack.info_pool[effectScript.ID].AttackDataList, H041_auto769_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
