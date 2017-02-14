S321_magic_H090_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S321_magic_H090_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S321_magic_H090_attack.info_pool[effectScript.ID].Attacker)
		S321_magic_H090_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("odin")
		PreLoadAvatar("S321")
		PreLoadSound("juewangjuji")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 30, "s" )
		effectScript:RegisterEvent( 33, "ass" )
	end,

	a = function( effectScript )
		SetAnimation(S321_magic_H090_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("odin")
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, S321_magic_H090_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 1, 100, "S321")
	CameraShake()
		PlaySound("juewangjuji")
	end,

	ass = function( effectScript )
			DamageEffect(S321_magic_H090_attack.info_pool[effectScript.ID].Attacker, S321_magic_H090_attack.info_pool[effectScript.ID].Targeter, S321_magic_H090_attack.info_pool[effectScript.ID].AttackType, S321_magic_H090_attack.info_pool[effectScript.ID].AttackDataList, S321_magic_H090_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
