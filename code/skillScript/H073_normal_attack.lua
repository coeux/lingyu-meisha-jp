H073_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H073_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H073_normal_attack.info_pool[effectScript.ID].Attacker)
		H073_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("hit_31")
		PreLoadSound("gunfire")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 24, "b" )
	end,

	a = function( effectScript )
		SetAnimation(H073_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	b = function( effectScript )
		AttachAvatarPosEffect(false, H073_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "hit_31")
		DamageEffect(H073_normal_attack.info_pool[effectScript.ID].Attacker, H073_normal_attack.info_pool[effectScript.ID].Targeter, H073_normal_attack.info_pool[effectScript.ID].AttackType, H073_normal_attack.info_pool[effectScript.ID].AttackDataList, H073_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("gunfire")
	end,

}
