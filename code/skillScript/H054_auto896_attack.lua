H054_auto896_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H054_auto896_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H054_auto896_attack.info_pool[effectScript.ID].Attacker)
        
		H054_auto896_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "cf" )
		effectScript:RegisterEvent( 6, "vb" )
	end,

	cf = function( effectScript )
		SetAnimation(H054_auto896_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	vb = function( effectScript )
			DamageEffect(H054_auto896_attack.info_pool[effectScript.ID].Attacker, H054_auto896_attack.info_pool[effectScript.ID].Targeter, H054_auto896_attack.info_pool[effectScript.ID].AttackType, H054_auto896_attack.info_pool[effectScript.ID].AttackDataList, H054_auto896_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
