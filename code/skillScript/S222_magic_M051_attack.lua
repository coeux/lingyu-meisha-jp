S222_magic_M051_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S222_magic_M051_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S222_magic_M051_attack.info_pool[effectScript.ID].Attacker)
		S222_magic_M051_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S222")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "SS" )
		effectScript:RegisterEvent( 19, "SDD" )
		effectScript:RegisterEvent( 21, "fgfdg" )
	end,

	SS = function( effectScript )
		SetAnimation(S222_magic_M051_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	SDD = function( effectScript )
		AttachAvatarPosEffect(false, S222_magic_M051_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(160, 0), 1, 100, "S222")
	CameraShake()
	end,

	fgfdg = function( effectScript )
		CameraShake()
		DamageEffect(S222_magic_M051_attack.info_pool[effectScript.ID].Attacker, S222_magic_M051_attack.info_pool[effectScript.ID].Targeter, S222_magic_M051_attack.info_pool[effectScript.ID].AttackType, S222_magic_M051_attack.info_pool[effectScript.ID].AttackDataList, S222_magic_M051_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
