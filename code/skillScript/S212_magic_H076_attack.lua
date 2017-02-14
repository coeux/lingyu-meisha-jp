S212_magic_H076_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S212_magic_H076_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S212_magic_H076_attack.info_pool[effectScript.ID].Attacker)
		S212_magic_H076_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S212_1")
		PreLoadAvatar("S212_2")
		PreLoadSound("caijuezhiren")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "s" )
		effectScript:RegisterEvent( 1, "vf" )
		effectScript:RegisterEvent( 3, "dff" )
		effectScript:RegisterEvent( 15, "cx" )
		effectScript:RegisterEvent( 23, "cxv" )
		effectScript:RegisterEvent( 30, "wd" )
		effectScript:RegisterEvent( 31, "cvb" )
	end,

	s = function( effectScript )
		SetAnimation(S212_magic_H076_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	vf = function( effectScript )
		AttachAvatarPosEffect(false, S212_magic_H076_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S212_1")
	AttachAvatarPosEffect(false, S212_magic_H076_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, -100, "S212_2")
	end,

	dff = function( effectScript )
			PlaySound("caijuezhiren")
	end,

	cx = function( effectScript )
		CameraShake()
	end,

	cxv = function( effectScript )
		CameraShake()
	end,

	wd = function( effectScript )
			DamageEffect(S212_magic_H076_attack.info_pool[effectScript.ID].Attacker, S212_magic_H076_attack.info_pool[effectScript.ID].Targeter, S212_magic_H076_attack.info_pool[effectScript.ID].AttackType, S212_magic_H076_attack.info_pool[effectScript.ID].AttackDataList, S212_magic_H076_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	cvb = function( effectScript )
		CameraShake()
	end,

}
