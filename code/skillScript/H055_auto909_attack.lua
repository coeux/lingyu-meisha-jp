H055_auto909_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H055_auto909_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H055_auto909_attack.info_pool[effectScript.ID].Attacker)
        
		H055_auto909_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fghj" )
		effectScript:RegisterEvent( 6, "xdcfvg" )
	end,

	fghj = function( effectScript )
		SetAnimation(H055_auto909_attack.info_pool[effectScript.ID].Attacker, AnimationType.f_idle)
	end,

	xdcfvg = function( effectScript )
			DamageEffect(H055_auto909_attack.info_pool[effectScript.ID].Attacker, H055_auto909_attack.info_pool[effectScript.ID].Targeter, H055_auto909_attack.info_pool[effectScript.ID].AttackType, H055_auto909_attack.info_pool[effectScript.ID].AttackDataList, H055_auto909_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
