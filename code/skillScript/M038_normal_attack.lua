M038_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M038_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M038_normal_attack.info_pool[effectScript.ID].Attacker)
		M038_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("spear")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 10, "df" )
		effectScript:RegisterEvent( 18, "d" )
	end,

	a = function( effectScript )
		SetAnimation(M038_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("spear")
	end,

	d = function( effectScript )
			DamageEffect(M038_normal_attack.info_pool[effectScript.ID].Attacker, M038_normal_attack.info_pool[effectScript.ID].Targeter, M038_normal_attack.info_pool[effectScript.ID].AttackType, M038_normal_attack.info_pool[effectScript.ID].AttackDataList, M038_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
