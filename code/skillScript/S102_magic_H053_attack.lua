S102_magic_H053_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S102_magic_H053_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S102_magic_H053_attack.info_pool[effectScript.ID].Attacker)
		S102_magic_H053_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S102")
		PreLoadSound("buff")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "CVDFG" )
		effectScript:RegisterEvent( 8, "XCVXC" )
		effectScript:RegisterEvent( 22, "xcxcv" )
	end,

	CVDFG = function( effectScript )
		SetAnimation(S102_magic_H053_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	XCVXC = function( effectScript )
		AttachAvatarPosEffect(false, S102_magic_H053_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, 100, "S102")
		PlaySound("buff")
	end,

	xcxcv = function( effectScript )
		CameraShake()
	end,

}
