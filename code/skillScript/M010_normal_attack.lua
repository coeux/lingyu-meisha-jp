M010_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M010_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M010_normal_attack.info_pool[effectScript.ID].Attacker)
       	if M010_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(M010_normal_attack.info_pool[effectScript.ID].Effect1);M010_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
 
		M010_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("M010_pugong_1")
		PreLoadAvatar("M010_pugong_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "safdg" )
		effectScript:RegisterEvent( 28, "sfdgfdgfd" )
		effectScript:RegisterEvent( 29, "dsfdg" )
		effectScript:RegisterEvent( 30, "fdghfh" )
		effectScript:RegisterEvent( 31, "dsfgg" )
	end,

	safdg = function( effectScript )
		SetAnimation(M010_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	sfdgfdgfd = function( effectScript )
		M010_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( M010_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(50, 50), 2, 1500, 300, 0.7, M010_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), "M010_pugong_1", effectScript)
	end,

	dsfdg = function( effectScript )
		if M010_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(M010_normal_attack.info_pool[effectScript.ID].Effect1);M010_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	fdghfh = function( effectScript )
		AttachAvatarPosEffect(false, M010_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "M010_pugong_2")
	end,

	dsfgg = function( effectScript )
			DamageEffect(M010_normal_attack.info_pool[effectScript.ID].Attacker, M010_normal_attack.info_pool[effectScript.ID].Targeter, M010_normal_attack.info_pool[effectScript.ID].AttackType, M010_normal_attack.info_pool[effectScript.ID].AttackDataList, M010_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
