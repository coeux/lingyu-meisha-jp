S121_magic_M054_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S121_magic_M054_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S121_magic_M054_attack.info_pool[effectScript.ID].Attacker)
		S121_magic_M054_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S121")
		PreLoadSound("shenshengchongji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 1, "ass" )
		effectScript:RegisterEvent( 15, "ddf" )
		effectScript:RegisterEvent( 18, "dd" )
		effectScript:RegisterEvent( 20, "dffg" )
		effectScript:RegisterEvent( 22, "fff" )
	end,

	ass = function( effectScript )
		SetAnimation(S121_magic_M054_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	ddf = function( effectScript )
		AttachAvatarPosEffect(false, S121_magic_M054_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(-40, 0), 1, 100, "S121")
		PlaySound("shenshengchongji")
	CameraShake()
	end,

	dd = function( effectScript )
		CameraShake()
		DamageEffect(S121_magic_M054_attack.info_pool[effectScript.ID].Attacker, S121_magic_M054_attack.info_pool[effectScript.ID].Targeter, S121_magic_M054_attack.info_pool[effectScript.ID].AttackType, S121_magic_M054_attack.info_pool[effectScript.ID].AttackDataList, S121_magic_M054_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dffg = function( effectScript )
		CameraShake()
	end,

	fff = function( effectScript )
		CameraShake()
	end,

}
