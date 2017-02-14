S301_magic_H061_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S301_magic_H061_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S301_magic_H061_attack.info_pool[effectScript.ID].Attacker)
		S301_magic_H061_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S301_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 31, "b" )
		effectScript:RegisterEvent( 32, "c" )
	end,

	a = function( effectScript )
		SetAnimation(S301_magic_H061_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	b = function( effectScript )
		end,

	c = function( effectScript )
			DamageEffect(S301_magic_H061_attack.info_pool[effectScript.ID].Attacker, S301_magic_H061_attack.info_pool[effectScript.ID].Targeter, S301_magic_H061_attack.info_pool[effectScript.ID].AttackType, S301_magic_H061_attack.info_pool[effectScript.ID].AttackDataList, S301_magic_H061_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	AttachAvatarPosEffect(false, S301_magic_H061_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S301_1")
	CameraShake()
	end,

}
