S411_magic_M041_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S411_magic_M041_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S411_magic_M041_attack.info_pool[effectScript.ID].Attacker)
		S411_magic_M041_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S411")
		PreLoadSound("lieyannutao")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 14, "d" )
		effectScript:RegisterEvent( 22, "f" )
	end,

	a = function( effectScript )
		SetAnimation(S411_magic_M041_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S411_magic_M041_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S411")
		PlaySound("lieyannutao")
	CameraShake()
	end,

	f = function( effectScript )
			DamageEffect(S411_magic_M041_attack.info_pool[effectScript.ID].Attacker, S411_magic_M041_attack.info_pool[effectScript.ID].Targeter, S411_magic_M041_attack.info_pool[effectScript.ID].AttackType, S411_magic_M041_attack.info_pool[effectScript.ID].AttackDataList, S411_magic_M041_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

}
