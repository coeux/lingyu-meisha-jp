M086_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M086_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M086_normal_attack.info_pool[effectScript.ID].Attacker)
		M086_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("ice")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "d" )
		effectScript:RegisterEvent( 6, "df" )
		effectScript:RegisterEvent( 17, "a" )
	end,

	d = function( effectScript )
		SetAnimation(M086_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("ice")
	end,

	a = function( effectScript )
			DamageEffect(M086_normal_attack.info_pool[effectScript.ID].Attacker, M086_normal_attack.info_pool[effectScript.ID].Targeter, M086_normal_attack.info_pool[effectScript.ID].AttackType, M086_normal_attack.info_pool[effectScript.ID].AttackDataList, M086_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
