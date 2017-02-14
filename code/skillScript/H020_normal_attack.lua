H020_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H020_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H020_normal_attack.info_pool[effectScript.ID].Attacker)
       	if H020_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(H020_normal_attack.info_pool[effectScript.ID].Effect1);H020_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
 
		H020_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("attack_02001")
		PreLoadSound("atalk_02001")
		PreLoadAvatar("bzpugong")
		PreLoadAvatar("bzshouji")
		PreLoadSound("attack_02002")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "aa" )
		effectScript:RegisterEvent( 16, "s" )
		effectScript:RegisterEvent( 17, "r" )
		effectScript:RegisterEvent( 18, "e" )
		effectScript:RegisterEvent( 19, "fgdhgf" )
		effectScript:RegisterEvent( 20, "a" )
	end,

	aa = function( effectScript )
		SetAnimation(H020_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("attack_02001")
		PlaySound("atalk_02001")
	end,

	s = function( effectScript )
		H020_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H020_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(30, 120), 1, 400, 250, 2, H020_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 50), "bzpugong", effectScript)
	end,

	r = function( effectScript )
		if H020_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(H020_normal_attack.info_pool[effectScript.ID].Effect1);H020_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	e = function( effectScript )
		AttachAvatarPosEffect(false, H020_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 2.5, 100, "bzshouji")
	end,

	fgdhgf = function( effectScript )
			PlaySound("attack_02002")
	end,

	a = function( effectScript )
			DamageEffect(H020_normal_attack.info_pool[effectScript.ID].Attacker, H020_normal_attack.info_pool[effectScript.ID].Targeter, H020_normal_attack.info_pool[effectScript.ID].AttackType, H020_normal_attack.info_pool[effectScript.ID].AttackDataList, H020_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
