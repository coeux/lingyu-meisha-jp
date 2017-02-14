S121_magic_H077_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S121_magic_H077_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S121_magic_H077_attack.info_pool[effectScript.ID].Attacker)
		S121_magic_H077_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadAvatar("S121_H077")
		PreLoadSound("shenshengchongji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "xvsdfasf" )
		effectScript:RegisterEvent( 16, "zxvxcgsdg" )
		effectScript:RegisterEvent( 30, "fsf" )
		effectScript:RegisterEvent( 32, "asdczxc" )
	end,

	xvsdfasf = function( effectScript )
		SetAnimation(S121_magic_H077_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	zxvxcgsdg = function( effectScript )
		AttachAvatarPosEffect(false, S121_magic_H077_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(10, -45), 1, 100, "S121_H077")
		PlaySound("shenshengchongji")
	end,

	fsf = function( effectScript )
			DamageEffect(S121_magic_H077_attack.info_pool[effectScript.ID].Attacker, S121_magic_H077_attack.info_pool[effectScript.ID].Targeter, S121_magic_H077_attack.info_pool[effectScript.ID].AttackType, S121_magic_H077_attack.info_pool[effectScript.ID].AttackDataList, S121_magic_H077_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	asdczxc = function( effectScript )
		CameraShake()
	end,

}
