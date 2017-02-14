S301_magic_H017_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S301_magic_H017_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S301_magic_H017_attack.info_pool[effectScript.ID].Attacker)
		S301_magic_H017_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("thor")
		PreLoadAvatar("S301_2")
		PreLoadSound("julongzhiji")
		PreLoadAvatar("S301_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "ddfasf" )
		effectScript:RegisterEvent( 4, "da" )
		effectScript:RegisterEvent( 38, "af" )
		effectScript:RegisterEvent( 39, "vngh" )
		effectScript:RegisterEvent( 41, "zxvsdgad" )
	end,

	ddfasf = function( effectScript )
		SetAnimation(S301_magic_H017_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	da = function( effectScript )
			PlaySound("thor")
	end,

	af = function( effectScript )
		AttachAvatarPosEffect(false, S301_magic_H017_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(40, 85), 1, 100, "S301_2")
	end,

	vngh = function( effectScript )
			PlaySound("julongzhiji")
	end,

	zxvsdgad = function( effectScript )
		AttachAvatarPosEffect(false, S301_magic_H017_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S301_1")
		DamageEffect(S301_magic_H017_attack.info_pool[effectScript.ID].Attacker, S301_magic_H017_attack.info_pool[effectScript.ID].Targeter, S301_magic_H017_attack.info_pool[effectScript.ID].AttackType, S301_magic_H017_attack.info_pool[effectScript.ID].AttackDataList, S301_magic_H017_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

}
