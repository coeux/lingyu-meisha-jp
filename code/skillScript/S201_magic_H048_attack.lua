S201_magic_H048_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S201_magic_H048_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S201_magic_H048_attack.info_pool[effectScript.ID].Attacker)
		S201_magic_H048_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("manhit")
		PreLoadAvatar("S201")
		PreLoadSound("wangzhezhijian")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "asfaqwe" )
		effectScript:RegisterEvent( 16, "asfqwrqwe" )
		effectScript:RegisterEvent( 17, "sdfgwer" )
	end,

	asfaqwe = function( effectScript )
		SetAnimation(S201_magic_H048_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("manhit")
	end,

	asfqwrqwe = function( effectScript )
		AttachAvatarPosEffect(false, S201_magic_H048_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(70, 0), 1, 100, "S201")
	end,

	sdfgwer = function( effectScript )
		CameraShake()
		DamageEffect(S201_magic_H048_attack.info_pool[effectScript.ID].Attacker, S201_magic_H048_attack.info_pool[effectScript.ID].Targeter, S201_magic_H048_attack.info_pool[effectScript.ID].AttackType, S201_magic_H048_attack.info_pool[effectScript.ID].AttackDataList, S201_magic_H048_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("wangzhezhijian")
	end,

}
