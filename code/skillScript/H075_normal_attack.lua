H075_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H075_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H075_normal_attack.info_pool[effectScript.ID].Attacker)
		H075_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("H075_1")
		PreLoadSound("minifire")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 19, "d" )
		effectScript:RegisterEvent( 20, "w" )
	end,

	a = function( effectScript )
		SetAnimation(H075_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, H075_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "H075_1")
		PlaySound("minifire")
	end,

	w = function( effectScript )
			DamageEffect(H075_normal_attack.info_pool[effectScript.ID].Attacker, H075_normal_attack.info_pool[effectScript.ID].Targeter, H075_normal_attack.info_pool[effectScript.ID].AttackType, H075_normal_attack.info_pool[effectScript.ID].AttackDataList, H075_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
