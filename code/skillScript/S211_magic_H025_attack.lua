S211_magic_H025_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S211_magic_H025_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S211_magic_H025_attack.info_pool[effectScript.ID].Attacker)
		S211_magic_H025_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S211")
		PreLoadSound("caijuezhiren")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 8, "b" )
		effectScript:RegisterEvent( 22, "e" )
		effectScript:RegisterEvent( 24, "c" )
		effectScript:RegisterEvent( 28, "d" )
	end,

	a = function( effectScript )
		SetAnimation(S211_magic_H025_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	b = function( effectScript )
		AttachAvatarPosEffect(false, S211_magic_H025_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 20), 1, 100, "S211")
		PlaySound("caijuezhiren")
	end,

	e = function( effectScript )
		CameraShake()
	end,

	c = function( effectScript )
			DamageEffect(S211_magic_H025_attack.info_pool[effectScript.ID].Attacker, S211_magic_H025_attack.info_pool[effectScript.ID].Targeter, S211_magic_H025_attack.info_pool[effectScript.ID].AttackType, S211_magic_H025_attack.info_pool[effectScript.ID].AttackDataList, S211_magic_H025_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	d = function( effectScript )
		CameraShake()
	end,

}
