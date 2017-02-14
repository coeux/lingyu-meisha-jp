S512_magic_M102_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S512_magic_M102_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S512_magic_M102_attack.info_pool[effectScript.ID].Attacker)
        
		S512_magic_M102_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("gs0092")
		PreLoadSound("gs_00101")
		PreLoadSound("gs_00102")
		PreLoadAvatar("S512_1")
		PreLoadAvatar("S512_2")
		PreLoadAvatar("M102_pugong_2")
		PreLoadAvatar("S512_3")
		PreLoadAvatar("M102_pugong_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "d" )
		effectScript:RegisterEvent( 22, "fsa123" )
		effectScript:RegisterEvent( 32, "d1dsa" )
		effectScript:RegisterEvent( 36, "adsf" )
		effectScript:RegisterEvent( 39, "dsdfg" )
		effectScript:RegisterEvent( 40, "sdf" )
		effectScript:RegisterEvent( 42, "ytuyu" )
		effectScript:RegisterEvent( 46, "jkhkj" )
	end,

	d = function( effectScript )
		SetAnimation(S512_magic_M102_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("gs0092")
		PlaySound("gs_00101")
		PlaySound("gs_00102")
	end,

	fsa123 = function( effectScript )
		AttachAvatarPosEffect(false, S512_magic_M102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(170, 180), 1.5, 100, "S512_1")
	end,

	d1dsa = function( effectScript )
		AttachAvatarPosEffect(false, S512_magic_M102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(185, 90), 1.2, 100, "S512_2")
	end,

	adsf = function( effectScript )
		AttachAvatarPosEffect(false, S512_magic_M102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(200, 30), 1.2, 100, "M102_pugong_2")
	end,

	dsdfg = function( effectScript )
		AttachAvatarPosEffect(false, S512_magic_M102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(350, 0), 2.5, 100, "S512_3")
	end,

	sdf = function( effectScript )
		AttachAvatarPosEffect(false, S512_magic_M102_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(280, 30), 1.2, 100, "M102_pugong_2")
	end,

	ytuyu = function( effectScript )
			DamageEffect(S512_magic_M102_attack.info_pool[effectScript.ID].Attacker, S512_magic_M102_attack.info_pool[effectScript.ID].Targeter, S512_magic_M102_attack.info_pool[effectScript.ID].AttackType, S512_magic_M102_attack.info_pool[effectScript.ID].AttackDataList, S512_magic_M102_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	jkhkj = function( effectScript )
			DamageEffect(S512_magic_M102_attack.info_pool[effectScript.ID].Attacker, S512_magic_M102_attack.info_pool[effectScript.ID].Targeter, S512_magic_M102_attack.info_pool[effectScript.ID].AttackType, S512_magic_M102_attack.info_pool[effectScript.ID].AttackDataList, S512_magic_M102_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
