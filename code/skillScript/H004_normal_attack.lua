H004_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		H004_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0, Effect2 = 0, Effect3 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(H004_normal_attack.info_pool[effectScript.ID].Attacker)
       	if H004_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(H004_normal_attack.info_pool[effectScript.ID].Effect1);H004_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
	if H004_normal_attack.info_pool[effectScript.ID].Effect2 then DetachEffect(H004_normal_attack.info_pool[effectScript.ID].Effect2);H004_normal_attack.info_pool[effectScript.ID].Effect2 = nil; end
	if H004_normal_attack.info_pool[effectScript.ID].Effect3 then DetachEffect(H004_normal_attack.info_pool[effectScript.ID].Effect3);H004_normal_attack.info_pool[effectScript.ID].Effect3 = nil; end
 
		H004_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_0402")
		PreLoadSound("atalk_0401")
		PreLoadAvatar("feibiao")
		PreLoadAvatar("feibiao")
		PreLoadAvatar("feibiao")
		PreLoadAvatar("q_pugong")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "safvzx" )
		effectScript:RegisterEvent( 19, "sdgfdh" )
		effectScript:RegisterEvent( 20, "d" )
		effectScript:RegisterEvent( 21, "f" )
		effectScript:RegisterEvent( 22, "e" )
		effectScript:RegisterEvent( 23, "s" )
	end,

	safvzx = function( effectScript )
		SetAnimation(H004_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	sdgfdh = function( effectScript )
			PlaySound("skill_0402")
		PlaySound("atalk_0401")
	end,

	d = function( effectScript )
		H004_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( H004_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(50, 60), 2, 1000, 300, 0.8, H004_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(-20, 0), "feibiao", effectScript)
	H004_normal_attack.info_pool[effectScript.ID].Effect2 = AttachTraceEffect( H004_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(50, 60), 2, 1000, 3, 0.8, H004_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-20, 50), "feibiao", effectScript)
	H004_normal_attack.info_pool[effectScript.ID].Effect3 = AttachTraceEffect( H004_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(50, 60), 2, 1000, 300, 0.8, H004_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-20, 20), "feibiao", effectScript)
	end,

	f = function( effectScript )
		if H004_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(H004_normal_attack.info_pool[effectScript.ID].Effect1);H004_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
	if H004_normal_attack.info_pool[effectScript.ID].Effect2 then DetachEffect(H004_normal_attack.info_pool[effectScript.ID].Effect2);H004_normal_attack.info_pool[effectScript.ID].Effect2 = nil; end
	if H004_normal_attack.info_pool[effectScript.ID].Effect3 then DetachEffect(H004_normal_attack.info_pool[effectScript.ID].Effect3);H004_normal_attack.info_pool[effectScript.ID].Effect3 = nil; end
	end,

	e = function( effectScript )
		AttachAvatarPosEffect(false, H004_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), -1.3, 100, "q_pugong")
	end,

	s = function( effectScript )
			DamageEffect(H004_normal_attack.info_pool[effectScript.ID].Attacker, H004_normal_attack.info_pool[effectScript.ID].Targeter, H004_normal_attack.info_pool[effectScript.ID].AttackType, H004_normal_attack.info_pool[effectScript.ID].AttackDataList, H004_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
