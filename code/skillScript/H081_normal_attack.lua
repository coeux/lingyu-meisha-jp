H081_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H081_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H081_normal_attack.info_pool[effectScript.ID].Attacker)
		H081_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("spear")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 17, "df" )
		effectScript:RegisterEvent( 20, "d" )
	end,

	a = function( effectScript )
		SetAnimation(H081_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("spear")
	end,

	d = function( effectScript )
			DamageEffect(H081_normal_attack.info_pool[effectScript.ID].Attacker, H081_normal_attack.info_pool[effectScript.ID].Targeter, H081_normal_attack.info_pool[effectScript.ID].AttackType, H081_normal_attack.info_pool[effectScript.ID].AttackDataList, H081_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
