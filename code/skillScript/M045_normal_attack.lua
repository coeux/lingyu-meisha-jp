M045_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M045_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M045_normal_attack.info_pool[effectScript.ID].Attacker)
		M045_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("breakheart")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 14, "df" )
		effectScript:RegisterEvent( 20, "f" )
	end,

	a = function( effectScript )
		SetAnimation(M045_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("breakheart")
	end,

	f = function( effectScript )
			DamageEffect(M045_normal_attack.info_pool[effectScript.ID].Attacker, M045_normal_attack.info_pool[effectScript.ID].Targeter, M045_normal_attack.info_pool[effectScript.ID].AttackType, M045_normal_attack.info_pool[effectScript.ID].AttackDataList, M045_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
