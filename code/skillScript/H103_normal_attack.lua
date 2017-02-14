H103_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H103_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H103_normal_attack.info_pool[effectScript.ID].Attacker)
		H103_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("arrow02")
		PreLoadSound("bow")
		PreLoadAvatar("hit_31")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "q" )
		effectScript:RegisterEvent( 14, "b" )
		effectScript:RegisterEvent( 16, "bc" )
	end,

	q = function( effectScript )
		SetAnimation(H103_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	b = function( effectScript )
		H103_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H103_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(10, 70), 3, 800, 300, 1, H103_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, 0), "arrow02", effectScript)
		PlaySound("bow")
	end,

	bc = function( effectScript )
		AttachAvatarPosEffect(false, H103_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "hit_31")
	DetachEffect(H103_normal_attack.info_pool[effectScript.ID].Effect1)
		DamageEffect(H103_normal_attack.info_pool[effectScript.ID].Attacker, H103_normal_attack.info_pool[effectScript.ID].Targeter, H103_normal_attack.info_pool[effectScript.ID].AttackType, H103_normal_attack.info_pool[effectScript.ID].AttackDataList, H103_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
