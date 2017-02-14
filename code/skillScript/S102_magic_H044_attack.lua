S102_magic_H044_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S102_magic_H044_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S102_magic_H044_attack.info_pool[effectScript.ID].Attacker)
		S102_magic_H044_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S102")
		PreLoadSound("buff")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fdhdf" )
		effectScript:RegisterEvent( 4, "xcvxcv" )
		effectScript:RegisterEvent( 16, "xcbxcv" )
	end,

	fdhdf = function( effectScript )
		SetAnimation(S102_magic_H044_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	xcvxcv = function( effectScript )
		AttachAvatarPosEffect(false, S102_magic_H044_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(5, -10), 1, 100, "S102")
		PlaySound("buff")
	end,

	xcbxcv = function( effectScript )
		CameraShake()
	end,

}
