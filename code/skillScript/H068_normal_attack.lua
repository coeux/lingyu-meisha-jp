H068_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H068_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H068_normal_attack.info_pool[effectScript.ID].Attacker)
		H068_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("roar")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 10, "df" )
		effectScript:RegisterEvent( 15, "b" )
	end,

	a = function( effectScript )
		SetAnimation(H068_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("roar")
	end,

	b = function( effectScript )
			DamageEffect(H068_normal_attack.info_pool[effectScript.ID].Attacker, H068_normal_attack.info_pool[effectScript.ID].Targeter, H068_normal_attack.info_pool[effectScript.ID].AttackType, H068_normal_attack.info_pool[effectScript.ID].AttackDataList, H068_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
