H074_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H074_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H074_normal_attack.info_pool[effectScript.ID].Attacker)
		H074_normal_attack.info_pool[effectScript.ID] = nil
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
		SetAnimation(H074_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	b = function( effectScript )
		AttachAvatarPosEffect(false, H074_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(100, 0), 1, 100, "hit_31")
		DamageEffect(H074_normal_attack.info_pool[effectScript.ID].Attacker, H074_normal_attack.info_pool[effectScript.ID].Targeter, H074_normal_attack.info_pool[effectScript.ID].AttackType, H074_normal_attack.info_pool[effectScript.ID].AttackDataList, H074_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("gunfire")
	end,

}
