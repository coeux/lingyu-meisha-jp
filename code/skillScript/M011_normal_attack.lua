M011_normal_attack = 
{
	info_pool = {},

	init = function( effectScript )
		M011_normal_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(M011_normal_attack.info_pool[effectScript.ID].Attacker)
       	if M011_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(M011_normal_attack.info_pool[effectScript.ID].Effect1);M011_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
 
		M011_normal_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("M011_pugong_2")
		PreLoadAvatar("M011_pugong_1")
		PreLoadAvatar("M011_pugong_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfdg" )
		effectScript:RegisterEvent( 21, "dsgdh" )
		effectScript:RegisterEvent( 24, "fdhgh" )
		effectScript:RegisterEvent( 25, "dsgh" )
		effectScript:RegisterEvent( 26, "dfh" )
		effectScript:RegisterEvent( 27, "sdfgh" )
	end,

	dsfdg = function( effectScript )
		SetAnimation(M011_normal_attack.info_pool[effectScript.ID].Attacker, AnimationType.attack)
	end,

	dsgdh = function( effectScript )
		AttachAvatarPosEffect(false, M011_normal_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-10, 20), 1, 100, "M011_pugong_2")
	end,

	fdhgh = function( effectScript )
		M011_normal_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( M011_normal_attack.info_pool[effectScript.ID].Attacker, Vector2(0, 0), 3, 1000, 300, 1, M011_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), "M011_pugong_1", effectScript)
	end,

	dsgh = function( effectScript )
		if M011_normal_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(M011_normal_attack.info_pool[effectScript.ID].Effect1);M011_normal_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	dfh = function( effectScript )
		AttachAvatarPosEffect(false, M011_normal_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "M011_pugong_3")
	end,

	sdfgh = function( effectScript )
			DamageEffect(M011_normal_attack.info_pool[effectScript.ID].Attacker, M011_normal_attack.info_pool[effectScript.ID].Targeter, M011_normal_attack.info_pool[effectScript.ID].AttackType, M011_normal_attack.info_pool[effectScript.ID].AttackDataList, M011_normal_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
