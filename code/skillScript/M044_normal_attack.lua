M044_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M044_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M044_normal_attack.info_pool[effectScript.ID].Attacker)
		M044_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("roar")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 14, "df" )
		effectScript:RegisterEvent( 20, "d" )
	end,

	a = function( effectScript )
		SetAnimation(M044_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("roar")
	end,

	d = function( effectScript )
			DamageEffect(M044_normal_attack.info_pool[effectScript.ID].Attacker, M044_normal_attack.info_pool[effectScript.ID].Targeter, M044_normal_attack.info_pool[effectScript.ID].AttackType, M044_normal_attack.info_pool[effectScript.ID].AttackDataList, M044_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
