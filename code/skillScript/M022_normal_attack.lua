M022_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M022_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M022_normal_attack.info_pool[effectScript.ID].Attacker)
		M022_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 9, "xianshishanghai" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(M022_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	xianshishanghai = function( effectScript )
			DamageEffect(M022_normal_attack.info_pool[effectScript.ID].Attacker, M022_normal_attack.info_pool[effectScript.ID].Targeter, M022_normal_attack.info_pool[effectScript.ID].AttackType, M022_normal_attack.info_pool[effectScript.ID].AttackDataList, M022_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
