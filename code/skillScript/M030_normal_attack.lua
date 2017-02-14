M030_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M030_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0, Effect3 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M030_normal_attack.info_pool[effectScript.ID].Attacker)
		M030_normal_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("roar")
		PreLoadSound("iceball")
		PreLoadSound("iceball")
		PreLoadAvatar("arrow09")
		PreLoadAvatar("arrow09")
		PreLoadAvatar("hit_61")
		PreLoadAvatar("hit_61")
		PreLoadAvatar("hit_61")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fdgdfgwsg" )
		effectScript:RegisterEvent( 5, "daf" )
		effectScript:RegisterEvent( 9, "dafa" )
		effectScript:RegisterEvent( 11, "fasf" )
		effectScript:RegisterEvent( 12, "safasf" )
		effectScript:RegisterEvent( 13, "adgsdfadf" )
		effectScript:RegisterEvent( 14, "gsdvzv" )
		effectScript:RegisterEvent( 15, "wd" )
	end,

	fdgdfgwsg = function( effectScript )
		SetAnimation(M030_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
		PlaySound("roar")
	end,

	daf = function( effectScript )
			PlaySound("iceball")
	end,

	dafa = function( effectScript )
			PlaySound("iceball")
	end,

	fasf = function( effectScript )
		M030_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( M030_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(80, 210), 2, 1000, 300, 0.75, M030_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(30, 30), "arrow09", effectScript)
	M030_normal_attack.info_pool[effectScript.ID].Effect3 = AttachTraceEffect( M030_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(80, 210), 2, 800, 300, 0.75, M030_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(30, 10), "arrow09", effectScript)
	end,

	safasf = function( effectScript )
		DetachEffect(M030_normal_attack.info_pool[effectScript.ID].Effect1)
	DetachEffect(M030_normal_attack.info_pool[effectScript.ID].Effect3)
	end,

	adgsdfadf = function( effectScript )
		AttachAvatarPosEffect(false, M030_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "hit_61")
	AttachAvatarPosEffect(false, M030_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(80, -20), 1, 100, "hit_61")
	end,

	gsdvzv = function( effectScript )
			DamageEffect(M030_normal_attack.info_pool[effectScript.ID].Attacker, M030_normal_attack.info_pool[effectScript.ID].Targeter, M030_normal_attack.info_pool[effectScript.ID].AttackType, M030_normal_attack.info_pool[effectScript.ID].AttackDataList, M030_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	AttachAvatarPosEffect(false, M030_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-80, 0), 1, 100, "hit_61")
	end,

	wd = function( effectScript )
		end,

}
