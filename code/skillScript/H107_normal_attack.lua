H107_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H107_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H107_normal_attack.info_pool[effectScript.ID].Attacker)
		H107_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("sword")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "w" )
		effectScript:RegisterEvent( 10, "r" )
		effectScript:RegisterEvent( 21, "t" )
	end,

	w = function( effectScript )
		SetAnimation(H107_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	r = function( effectScript )
			PlaySound("sword")
	end,

	t = function( effectScript )
			DamageEffect(H107_normal_attack.info_pool[effectScript.ID].Attacker, H107_normal_attack.info_pool[effectScript.ID].Targeter, H107_normal_attack.info_pool[effectScript.ID].AttackType, H107_normal_attack.info_pool[effectScript.ID].AttackDataList, H107_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
