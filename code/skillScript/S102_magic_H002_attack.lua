S102_magic_H002_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S102_magic_H002_attack.info_pool[effectScript.ID] = { Attacker = 0, AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S102_magic_H002_attack.info_pool[effectScript.ID].Attacker)
		S102_magic_H002_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S102")
		PreLoadSound("buff")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sd" )
		effectScript:RegisterEvent( 28, "cxv" )
		effectScript:RegisterEvent( 31, "hdg" )
	end,

	sd = function( effectScript )
		SetAnimation(S102_magic_H002_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	cxv = function( effectScript )
		AttachAvatarPosEffect(false, S102_magic_H002_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(0, 0), 1, -100, "S102")
		PlaySound("buff")
	end,

	hdg = function( effectScript )
		CameraShake()
	end,

}
