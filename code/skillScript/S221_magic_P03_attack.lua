S221_magic_P03_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S221_magic_P03_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S221_magic_P03_attack.info_pool[effectScript.ID].Attacker)
		S221_magic_P03_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("juewangjuji")
		PreLoadAvatar("S221_P03")
		PreLoadSound("fire")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 10, "klk" )
		effectScript:RegisterEvent( 47, "f" )
		effectScript:RegisterEvent( 48, "v" )
		effectScript:RegisterEvent( 51, "fw" )
	end,

	a = function( effectScript )
		SetAnimation(S221_magic_P03_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	klk = function( effectScript )
			PlaySound("juewangjuji")
	end,

	f = function( effectScript )
		AttachAvatarPosEffect(false, S221_magic_P03_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(30, 0), 1, 100, "S221_P03")
		PlaySound("fire")
	end,

	v = function( effectScript )
			DamageEffect(S221_magic_P03_attack.info_pool[effectScript.ID].Attacker, S221_magic_P03_attack.info_pool[effectScript.ID].Targeter, S221_magic_P03_attack.info_pool[effectScript.ID].AttackType, S221_magic_P03_attack.info_pool[effectScript.ID].AttackDataList, S221_magic_P03_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

	fw = function( effectScript )
		CameraShake()
	end,

}
