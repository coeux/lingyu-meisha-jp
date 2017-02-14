S211_magic_M053_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S211_magic_M053_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S211_magic_M053_attack.info_pool[effectScript.ID].Attacker)
		S211_magic_M053_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S211")
		PreLoadSound("caijuezhiren")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "AAS" )
		effectScript:RegisterEvent( 8, "fftg" )
		effectScript:RegisterEvent( 16, "aa" )
		effectScript:RegisterEvent( 21, "asd" )
		effectScript:RegisterEvent( 23, "adff" )
	end,

	AAS = function( effectScript )
		SetAnimation(S211_magic_M053_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	fftg = function( effectScript )
		AttachAvatarPosEffect(false, S211_magic_M053_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S211")
		PlaySound("caijuezhiren")
	end,

	aa = function( effectScript )
		CameraShake()
		DamageEffect(S211_magic_M053_attack.info_pool[effectScript.ID].Attacker, S211_magic_M053_attack.info_pool[effectScript.ID].Targeter, S211_magic_M053_attack.info_pool[effectScript.ID].AttackType, S211_magic_M053_attack.info_pool[effectScript.ID].AttackDataList, S211_magic_M053_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	asd = function( effectScript )
		CameraShake()
	end,

	adff = function( effectScript )
		CameraShake()
	end,

}
