S302_magic_H057_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S302_magic_H057_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S302_magic_H057_attack.info_pool[effectScript.ID].Attacker)
		S302_magic_H057_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S302")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dsfe" )
		effectScript:RegisterEvent( 28, "vdf" )
		effectScript:RegisterEvent( 32, "hn" )
		effectScript:RegisterEvent( 34, "ew" )
	end,

	dsfe = function( effectScript )
		SetAnimation(S302_magic_H057_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	vdf = function( effectScript )
		end,

	hn = function( effectScript )
		AttachAvatarPosEffect(false, S302_magic_H057_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S302")
	CameraShake()
	end,

	ew = function( effectScript )
			DamageEffect(S302_magic_H057_attack.info_pool[effectScript.ID].Attacker, S302_magic_H057_attack.info_pool[effectScript.ID].Targeter, S302_magic_H057_attack.info_pool[effectScript.ID].AttackType, S302_magic_H057_attack.info_pool[effectScript.ID].AttackDataList, S302_magic_H057_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
