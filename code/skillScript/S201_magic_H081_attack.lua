S201_magic_H081_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S201_magic_H081_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S201_magic_H081_attack.info_pool[effectScript.ID].Attacker)
		S201_magic_H081_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("juewangjuji")
		PreLoadAvatar("S201")
		PreLoadSound("wangzhezhijian")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 26, "d" )
		effectScript:RegisterEvent( 27, "s" )
	end,

	a = function( effectScript )
		SetAnimation(S201_magic_H081_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("juewangjuji")
	end,

	d = function( effectScript )
		AttachAvatarPosEffect(false, S201_magic_H081_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(90, 10), 1, 100, "S201")
	CameraShake()
		PlaySound("wangzhezhijian")
	end,

	s = function( effectScript )
			DamageEffect(S201_magic_H081_attack.info_pool[effectScript.ID].Attacker, S201_magic_H081_attack.info_pool[effectScript.ID].Targeter, S201_magic_H081_attack.info_pool[effectScript.ID].AttackType, S201_magic_H081_attack.info_pool[effectScript.ID].AttackDataList, S201_magic_H081_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
