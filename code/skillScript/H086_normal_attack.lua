H086_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H086_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H086_normal_attack.info_pool[effectScript.ID].Attacker)
		H086_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("apollo")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 20, "s" )
	end,

	a = function( effectScript )
		SetAnimation(H086_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	s = function( effectScript )
			DamageEffect(H086_normal_attack.info_pool[effectScript.ID].Attacker, H086_normal_attack.info_pool[effectScript.ID].Targeter, H086_normal_attack.info_pool[effectScript.ID].AttackType, H086_normal_attack.info_pool[effectScript.ID].AttackDataList, H086_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("apollo")
	end,

}
