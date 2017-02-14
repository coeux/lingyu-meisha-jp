S211_magic_H100_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S211_magic_H100_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S211_magic_H100_attack.info_pool[effectScript.ID].Attacker)
		S211_magic_H100_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("laugh")
		PreLoadAvatar("S211")
		PreLoadSound("caijuezhiren")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 14, "d" )
		effectScript:RegisterEvent( 31, "f" )
	end,

	a = function( effectScript )
		SetAnimation(S211_magic_H100_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("laugh")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S211_magic_H100_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(-15, -20), 1, 100, "S211")
		PlaySound("caijuezhiren")
	end,

	f = function( effectScript )
			DamageEffect(S211_magic_H100_attack.info_pool[effectScript.ID].Attacker, S211_magic_H100_attack.info_pool[effectScript.ID].Targeter, S211_magic_H100_attack.info_pool[effectScript.ID].AttackType, S211_magic_H100_attack.info_pool[effectScript.ID].AttackDataList, S211_magic_H100_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

}
