S202_magic_P01_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S202_magic_P01_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S202_magic_P01_attack.info_pool[effectScript.ID].Attacker)
		S202_magic_P01_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("manhit")
		PreLoadAvatar("S202")
		PreLoadSound("moshitianhuo")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "g" )
		effectScript:RegisterEvent( 11, "da" )
		effectScript:RegisterEvent( 30, "rg" )
		effectScript:RegisterEvent( 32, "fgh" )
		effectScript:RegisterEvent( 37, "gfh" )
	end,

	g = function( effectScript )
		SetAnimation(S202_magic_P01_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	da = function( effectScript )
			PlaySound("manhit")
	end,

	rg = function( effectScript )
		AttachAvatarPosEffect(false, S202_magic_P01_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(150, -20), 1, 100, "S202")
	CameraShake()
		PlaySound("moshitianhuo")
	end,

	fgh = function( effectScript )
			DamageEffect(S202_magic_P01_attack.info_pool[effectScript.ID].Attacker, S202_magic_P01_attack.info_pool[effectScript.ID].Targeter, S202_magic_P01_attack.info_pool[effectScript.ID].AttackType, S202_magic_P01_attack.info_pool[effectScript.ID].AttackDataList, S202_magic_P01_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	gfh = function( effectScript )
		CameraShake()
	end,

}
