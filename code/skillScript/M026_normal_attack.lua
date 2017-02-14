M026_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M026_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M026_normal_attack.info_pool[effectScript.ID].Attacker)
		M026_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("roar")
		PreLoadAvatar("hit_41")
		PreLoadAvatar("hit_41")
		PreLoadSound("thunder")
		PreLoadAvatar("hit_41")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "asfafqwr" )
		effectScript:RegisterEvent( 14, "fasdfasedwqf" )
		effectScript:RegisterEvent( 15, "sdgsdfafw" )
		effectScript:RegisterEvent( 16, "fdfgegv" )
	end,

	asfafqwr = function( effectScript )
		SetAnimation(M026_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("roar")
	end,

	fasdfasedwqf = function( effectScript )
		AttachAvatarPosEffect(false, M026_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1.5, 100, "hit_41")
	AttachAvatarPosEffect(false, M026_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-20, 0), 1.2, 100, "hit_41")
		PlaySound("thunder")
	end,

	sdgsdfafw = function( effectScript )
			DamageEffect(M026_normal_attack.info_pool[effectScript.ID].Attacker, M026_normal_attack.info_pool[effectScript.ID].Targeter, M026_normal_attack.info_pool[effectScript.ID].AttackType, M026_normal_attack.info_pool[effectScript.ID].AttackDataList, M026_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fdfgegv = function( effectScript )
		AttachAvatarPosEffect(false, M026_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(80, 0), 1.6, 100, "hit_41")
	end,

}
