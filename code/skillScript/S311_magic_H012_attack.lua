S311_magic_H012_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S311_magic_H012_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S311_magic_H012_attack.info_pool[effectScript.ID].Attacker)
		S311_magic_H012_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("odin")
		PreLoadAvatar("S311")
		PreLoadSound("jiuxinglingri")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "sdfwerfq" )
		effectScript:RegisterEvent( 35, "ascasfqwf" )
		effectScript:RegisterEvent( 36, "xcvsfqa" )
		effectScript:RegisterEvent( 39, "xcvsdg" )
	end,

	sdfwerfq = function( effectScript )
		SetAnimation(S311_magic_H012_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("odin")
	end,

	ascasfqwf = function( effectScript )
		AttachAvatarPosEffect(false, S311_magic_H012_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 0), 1, 100, "S311")
	end,

	xcvsfqa = function( effectScript )
		CameraShake()
		PlaySound("jiuxinglingri")
	end,

	xcvsdg = function( effectScript )
		CameraShake()
		DamageEffect(S311_magic_H012_attack.info_pool[effectScript.ID].Attacker, S311_magic_H012_attack.info_pool[effectScript.ID].Targeter, S311_magic_H012_attack.info_pool[effectScript.ID].AttackType, S311_magic_H012_attack.info_pool[effectScript.ID].AttackDataList, S311_magic_H012_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
