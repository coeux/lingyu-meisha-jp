S202_magic_P02_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S202_magic_P02_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S202_magic_P02_attack.info_pool[effectScript.ID].Attacker)
		S202_magic_P02_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("odin")
		PreLoadSound("womanhit")
		PreLoadAvatar("S202")
		PreLoadSound("moshitianhuo")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "g" )
		effectScript:RegisterEvent( 6, "dff" )
		effectScript:RegisterEvent( 20, "dffd" )
		effectScript:RegisterEvent( 32, "vbn" )
		effectScript:RegisterEvent( 36, "df" )
	end,

	g = function( effectScript )
		SetAnimation(S202_magic_P02_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dff = function( effectScript )
			PlaySound("odin")
	end,

	dffd = function( effectScript )
			PlaySound("womanhit")
	end,

	vbn = function( effectScript )
		AttachAvatarPosEffect(false, S202_magic_P02_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(140, 0), 1, 100, "S202")
	CameraShake()
		PlaySound("moshitianhuo")
	end,

	df = function( effectScript )
			DamageEffect(S202_magic_P02_attack.info_pool[effectScript.ID].Attacker, S202_magic_P02_attack.info_pool[effectScript.ID].Targeter, S202_magic_P02_attack.info_pool[effectScript.ID].AttackType, S202_magic_P02_attack.info_pool[effectScript.ID].AttackDataList, S202_magic_P02_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
