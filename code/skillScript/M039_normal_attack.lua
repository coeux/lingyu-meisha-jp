M039_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M039_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M039_normal_attack.info_pool[effectScript.ID].Attacker)
		M039_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("spear")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 10, "df" )
		effectScript:RegisterEvent( 20, "d" )
	end,

	a = function( effectScript )
		SetAnimation(M039_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("spear")
	end,

	d = function( effectScript )
			DamageEffect(M039_normal_attack.info_pool[effectScript.ID].Attacker, M039_normal_attack.info_pool[effectScript.ID].Targeter, M039_normal_attack.info_pool[effectScript.ID].AttackType, M039_normal_attack.info_pool[effectScript.ID].AttackDataList, M039_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
