S212_magic_H100_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S212_magic_H100_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S212_magic_H100_attack.info_pool[effectScript.ID].Attacker)
		S212_magic_H100_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("laugh")
		PreLoadAvatar("S212_1")
		PreLoadAvatar("S212_2")
		PreLoadSound("caijuezhiren")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 6, "e" )
		effectScript:RegisterEvent( 25, "d" )
	end,

	a = function( effectScript )
		SetAnimation(S212_magic_H100_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("laugh")
	end,

	e = function( effectScript )
		AttachAvatarPosEffect(false, S212_magic_H100_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S212_1")
	AttachAvatarPosEffect(false, S212_magic_H100_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, -100, "S212_2")
		PlaySound("caijuezhiren")
	end,

	d = function( effectScript )
			DamageEffect(S212_magic_H100_attack.info_pool[effectScript.ID].Attacker, S212_magic_H100_attack.info_pool[effectScript.ID].Targeter, S212_magic_H100_attack.info_pool[effectScript.ID].AttackType, S212_magic_H100_attack.info_pool[effectScript.ID].AttackDataList, S212_magic_H100_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

}
