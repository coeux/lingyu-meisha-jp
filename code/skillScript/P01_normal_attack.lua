P01_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		P01_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(P01_normal_attack.info_pool[effectScript.ID].Attacker)
		P01_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("q_pugong")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 23, "aa" )
	end,

	a = function( effectScript )
		SetAnimation(P01_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	AttachAvatarPosEffect(false, P01_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(180, 50), 1, 100, "q_pugong")
	end,

	aa = function( effectScript )
			DamageEffect(P01_normal_attack.info_pool[effectScript.ID].Attacker, P01_normal_attack.info_pool[effectScript.ID].Targeter, P01_normal_attack.info_pool[effectScript.ID].AttackType, P01_normal_attack.info_pool[effectScript.ID].AttackDataList, P01_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
