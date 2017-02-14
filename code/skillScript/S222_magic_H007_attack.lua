S222_magic_H007_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S222_magic_H007_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S222_magic_H007_attack.info_pool[effectScript.ID].Attacker)
		S222_magic_H007_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("juewangjuji")
		PreLoadAvatar("S222")
		PreLoadSound("fire")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sa" )
		effectScript:RegisterEvent( 10, "dff" )
		effectScript:RegisterEvent( 34, "b" )
		effectScript:RegisterEvent( 39, "r" )
		effectScript:RegisterEvent( 48, "v" )
		effectScript:RegisterEvent( 52, "w" )
	end,

	sa = function( effectScript )
		SetAnimation(S222_magic_H007_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dff = function( effectScript )
			PlaySound("juewangjuji")
	end,

	b = function( effectScript )
		CameraShake()
	end,

	r = function( effectScript )
		CameraShake()
	end,

	v = function( effectScript )
		AttachAvatarPosEffect(false, S222_magic_H007_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(200, 0), 1, -100, "S222")
		PlaySound("fire")
	end,

	w = function( effectScript )
			DamageEffect(S222_magic_H007_attack.info_pool[effectScript.ID].Attacker, S222_magic_H007_attack.info_pool[effectScript.ID].Targeter, S222_magic_H007_attack.info_pool[effectScript.ID].AttackType, S222_magic_H007_attack.info_pool[effectScript.ID].AttackDataList, S222_magic_H007_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

}
