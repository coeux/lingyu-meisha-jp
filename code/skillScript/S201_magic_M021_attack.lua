S201_magic_M021_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S201_magic_M021_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S201_magic_M021_attack.info_pool[effectScript.ID].Attacker)
		S201_magic_M021_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("miemie")
		PreLoadAvatar("S201")
		PreLoadSound("wangzhezhijian")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 1, "sad" )
		effectScript:RegisterEvent( 23, "denuegb" )
		effectScript:RegisterEvent( 24, "ad" )
		effectScript:RegisterEvent( 26, "sdweer" )
		effectScript:RegisterEvent( 36, "ff" )
	end,

	a = function( effectScript )
		SetAnimation(S201_magic_M021_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	sad = function( effectScript )
			PlaySound("miemie")
	end,

	denuegb = function( effectScript )
		AttachAvatarPosEffect(false, S201_magic_M021_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 5), 1, 100, "S201")
		PlaySound("wangzhezhijian")
	end,

	ad = function( effectScript )
			DamageEffect(S201_magic_M021_attack.info_pool[effectScript.ID].Attacker, S201_magic_M021_attack.info_pool[effectScript.ID].Targeter, S201_magic_M021_attack.info_pool[effectScript.ID].AttackType, S201_magic_M021_attack.info_pool[effectScript.ID].AttackDataList, S201_magic_M021_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	sdweer = function( effectScript )
		CameraShake()
	end,

	ff = function( effectScript )
		CameraShake()
	end,

}
