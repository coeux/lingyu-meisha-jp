S211_magic_H009_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S211_magic_H009_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S211_magic_H009_attack.info_pool[effectScript.ID].Attacker)
		S211_magic_H009_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("girlskill")
		PreLoadAvatar("S211")
		PreLoadSound("caijuezhiren")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 3, "b" )
		effectScript:RegisterEvent( 5, "dfad" )
		effectScript:RegisterEvent( 22, "c" )
		effectScript:RegisterEvent( 25, "cd" )
	end,

	a = function( effectScript )
		SetAnimation(S211_magic_H009_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("girlskill")
	end,

	b = function( effectScript )
		AttachAvatarPosEffect(false, S211_magic_H009_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S211")
	end,

	dfad = function( effectScript )
			PlaySound("caijuezhiren")
	end,

	c = function( effectScript )
			DamageEffect(S211_magic_H009_attack.info_pool[effectScript.ID].Attacker, S211_magic_H009_attack.info_pool[effectScript.ID].Targeter, S211_magic_H009_attack.info_pool[effectScript.ID].AttackType, S211_magic_H009_attack.info_pool[effectScript.ID].AttackDataList, S211_magic_H009_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

	cd = function( effectScript )
		CameraShake()
	end,

}
