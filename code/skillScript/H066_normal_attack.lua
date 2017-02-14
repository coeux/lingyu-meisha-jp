H066_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H066_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H066_normal_attack.info_pool[effectScript.ID].Attacker)
		H066_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("roar")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 14, "sdf" )
		effectScript:RegisterEvent( 16, "b" )
	end,

	a = function( effectScript )
		SetAnimation(H066_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	sdf = function( effectScript )
			PlaySound("roar")
	end,

	b = function( effectScript )
			DamageEffect(H066_normal_attack.info_pool[effectScript.ID].Attacker, H066_normal_attack.info_pool[effectScript.ID].Targeter, H066_normal_attack.info_pool[effectScript.ID].AttackType, H066_normal_attack.info_pool[effectScript.ID].AttackDataList, H066_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
