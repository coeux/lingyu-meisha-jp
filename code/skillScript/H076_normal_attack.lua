H076_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H076_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H076_normal_attack.info_pool[effectScript.ID].Attacker)
		H076_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("sword")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "wfdarfqr" )
		effectScript:RegisterEvent( 18, "df" )
		effectScript:RegisterEvent( 22, "sadwqr" )
	end,

	wfdarfqr = function( effectScript )
		SetAnimation(H076_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	df = function( effectScript )
			PlaySound("sword")
	end,

	sadwqr = function( effectScript )
			DamageEffect(H076_normal_attack.info_pool[effectScript.ID].Attacker, H076_normal_attack.info_pool[effectScript.ID].Targeter, H076_normal_attack.info_pool[effectScript.ID].AttackType, H076_normal_attack.info_pool[effectScript.ID].AttackDataList, H076_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
