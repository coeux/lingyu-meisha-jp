H104_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H104_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H104_normal_attack.info_pool[effectScript.ID].Attacker)
		H104_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("spear")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "asssd" )
		effectScript:RegisterEvent( 15, "dfff" )
	end,

	asssd = function( effectScript )
		SetAnimation(H104_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	dfff = function( effectScript )
			PlaySound("spear")
		DamageEffect(H104_normal_attack.info_pool[effectScript.ID].Attacker, H104_normal_attack.info_pool[effectScript.ID].Targeter, H104_normal_attack.info_pool[effectScript.ID].AttackType, H104_normal_attack.info_pool[effectScript.ID].AttackDataList, H104_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
