S301_magic_H041_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S301_magic_H041_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S301_magic_H041_attack.info_pool[effectScript.ID].Attacker)
		S301_magic_H041_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("charge")
		PreLoadSound("julongzhiji")
		PreLoadAvatar("S301_2")
		PreLoadAvatar("S301_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "xcvsdg" )
		effectScript:RegisterEvent( 15, "daf" )
		effectScript:RegisterEvent( 39, "xcasdg" )
		effectScript:RegisterEvent( 40, "fasfad" )
		effectScript:RegisterEvent( 41, "safw" )
		effectScript:RegisterEvent( 42, "dzsfafw" )
	end,

	xcvsdg = function( effectScript )
		SetAnimation(S301_magic_H041_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	daf = function( effectScript )
			PlaySound("charge")
	end,

	xcasdg = function( effectScript )
			PlaySound("julongzhiji")
	AttachAvatarPosEffect(false, S301_magic_H041_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(50, 100), 1, 100, "S301_2")
	end,

	fasfad = function( effectScript )
		AttachAvatarPosEffect(false, S301_magic_H041_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S301_1")
	end,

	safw = function( effectScript )
		end,

	dzsfafw = function( effectScript )
		CameraShake()
		DamageEffect(S301_magic_H041_attack.info_pool[effectScript.ID].Attacker, S301_magic_H041_attack.info_pool[effectScript.ID].Targeter, S301_magic_H041_attack.info_pool[effectScript.ID].AttackType, S301_magic_H041_attack.info_pool[effectScript.ID].AttackDataList, S301_magic_H041_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
