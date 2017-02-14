H106_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H106_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H106_normal_attack.info_pool[effectScript.ID].Attacker)
		H106_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("thunder")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "a" )
		effectScript:RegisterEvent( 16, "de" )
	end,

	a = function( effectScript )
		SetAnimation(H106_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	de = function( effectScript )
			DamageEffect(H106_normal_attack.info_pool[effectScript.ID].Attacker, H106_normal_attack.info_pool[effectScript.ID].Targeter, H106_normal_attack.info_pool[effectScript.ID].AttackType, H106_normal_attack.info_pool[effectScript.ID].AttackDataList, H106_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("thunder")
	end,

}
