P02_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P02_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P02_normal_attack.info_pool[effectScript.ID].Attacker)
		P02_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("spear")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "attack_begin" )
		effectScript:RegisterEvent( 6, "add_effect" )
		effectScript:RegisterEvent( 10, "attack_effect" )
	end,

	attack_begin = function( effectScript )
		SetAnimation(P02_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	add_effect = function( effectScript )
			PlaySound("spear")
	end,

	attack_effect = function( effectScript )
			DamageEffect(P02_normal_attack.info_pool[effectScript.ID].Attacker, P02_normal_attack.info_pool[effectScript.ID].Targeter, P02_normal_attack.info_pool[effectScript.ID].AttackType, P02_normal_attack.info_pool[effectScript.ID].AttackDataList, P02_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
