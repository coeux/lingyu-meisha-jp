M070_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M070_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M070_normal_attack.info_pool[effectScript.ID].Attacker)
		M070_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 17, "b" )
	end,

	a = function( effectScript )
		SetAnimation(M070_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	b = function( effectScript )
			DamageEffect(M070_normal_attack.info_pool[effectScript.ID].Attacker, M070_normal_attack.info_pool[effectScript.ID].Targeter, M070_normal_attack.info_pool[effectScript.ID].AttackType, M070_normal_attack.info_pool[effectScript.ID].AttackDataList, M070_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
