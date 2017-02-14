S524_magic_M011_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S524_magic_M011_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0, Effect1 = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S524_magic_M011_attack.info_pool[effectScript.ID].Attacker)
       	if S524_magic_M011_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(S524_magic_M011_attack.info_pool[effectScript.ID].Effect1);S524_magic_M011_attack.info_pool[effectScript.ID].Effect1 = nil; end
 
		S524_magic_M011_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadAvatar("S568_1")
		PreLoadAvatar("M011_pugong_2")
		PreLoadAvatar("M011_pugong_1")
		PreLoadAvatar("S568_4")
		PreLoadAvatar("S568_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "gfhj" )
		effectScript:RegisterEvent( 3, "gfhjhgk" )
		effectScript:RegisterEvent( 11, "dgh" )
		effectScript:RegisterEvent( 16, "dsssssg" )
		effectScript:RegisterEvent( 17, "dghhkjk" )
		effectScript:RegisterEvent( 18, "gfhgkj" )
		effectScript:RegisterEvent( 19, "hgkhjkl" )
		effectScript:RegisterEvent( 21, "dgfgh" )
		effectScript:RegisterEvent( 25, "dgdfh" )
	end,

	gfhj = function( effectScript )
		SetAnimation(S524_magic_M011_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	gfhjhgk = function( effectScript )
		AttachAvatarPosEffect(false, S524_magic_M011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(20, 0), 1, -100, "S568_1")
	end,

	dgh = function( effectScript )
		AttachAvatarPosEffect(false, S524_magic_M011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-20, 0), 1, 100, "M011_pugong_2")
	end,

	dsssssg = function( effectScript )
		S524_magic_M011_attack.info_pool[effectScript.ID].Effect1 = AttachTraceEffect( S524_magic_M011_attack.info_pool[effectScript.ID].Attacker, Vector2(0, 0), 3, 800, 300, 1, S524_magic_M011_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-50, 0), "M011_pugong_1", effectScript)
	end,

	dghhkjk = function( effectScript )
		if S524_magic_M011_attack.info_pool[effectScript.ID].Effect1 then DetachEffect(S524_magic_M011_attack.info_pool[effectScript.ID].Effect1);S524_magic_M011_attack.info_pool[effectScript.ID].Effect1 = nil; end
	end,

	gfhgkj = function( effectScript )
		AttachAvatarPosEffect(false, S524_magic_M011_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1.5, 100, "S568_4")
	end,

	hgkhjkl = function( effectScript )
			DamageEffect(S524_magic_M011_attack.info_pool[effectScript.ID].Attacker, S524_magic_M011_attack.info_pool[effectScript.ID].Targeter, S524_magic_M011_attack.info_pool[effectScript.ID].AttackType, S524_magic_M011_attack.info_pool[effectScript.ID].AttackDataList, S524_magic_M011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dgfgh = function( effectScript )
		AttachAvatarPosEffect(false, S524_magic_M011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(80, 0), 1, 100, "S568_3")
	end,

	dgdfh = function( effectScript )
			DamageEffect(S524_magic_M011_attack.info_pool[effectScript.ID].Attacker, S524_magic_M011_attack.info_pool[effectScript.ID].Targeter, S524_magic_M011_attack.info_pool[effectScript.ID].AttackType, S524_magic_M011_attack.info_pool[effectScript.ID].AttackDataList, S524_magic_M011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
