H072_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H072_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H072_normal_attack.info_pool[effectScript.ID].Attacker)
		H072_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("hit_31")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 17, "b" )
	end,

	a = function( effectScript )
		SetAnimation(H072_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	b = function( effectScript )
			DamageEffect(H072_normal_attack.info_pool[effectScript.ID].Attacker, H072_normal_attack.info_pool[effectScript.ID].Targeter, H072_normal_attack.info_pool[effectScript.ID].AttackType, H072_normal_attack.info_pool[effectScript.ID].AttackDataList, H072_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	AttachAvatarPosEffect(false, H072_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "hit_31")
	end,

}
