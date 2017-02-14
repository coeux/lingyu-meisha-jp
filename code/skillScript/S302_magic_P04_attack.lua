S302_magic_P04_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S302_magic_P04_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S302_magic_P04_attack.info_pool[effectScript.ID].Attacker)
		S302_magic_P04_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S302")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "fe" )
		effectScript:RegisterEvent( 36, "gf" )
		effectScript:RegisterEvent( 39, "nb" )
		effectScript:RegisterEvent( 44, "gh" )
		effectScript:RegisterEvent( 46, "vn" )
	end,

	fe = function( effectScript )
		SetAnimation(S302_magic_P04_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	gf = function( effectScript )
		end,

	nb = function( effectScript )
		AttachAvatarPosEffect(false, S302_magic_P04_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S302")
	CameraShake()
	end,

	gh = function( effectScript )
			DamageEffect(S302_magic_P04_attack.info_pool[effectScript.ID].Attacker, S302_magic_P04_attack.info_pool[effectScript.ID].Targeter, S302_magic_P04_attack.info_pool[effectScript.ID].AttackType, S302_magic_P04_attack.info_pool[effectScript.ID].AttackDataList, S302_magic_P04_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	vn = function( effectScript )
		CameraShake()
	end,

}
