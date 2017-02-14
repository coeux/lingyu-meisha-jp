S201_magic_H107_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S201_magic_H107_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S201_magic_H107_attack.info_pool[effectScript.ID].Attacker)
		S201_magic_H107_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("manhit")
		PreLoadAvatar("S201")
		PreLoadSound("wangzhezhijian")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 10, "s" )
		effectScript:RegisterEvent( 29, "f" )
		effectScript:RegisterEvent( 30, "d" )
	end,

	a = function( effectScript )
		SetAnimation(S201_magic_H107_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	s = function( effectScript )
			PlaySound("manhit")
	end,

	f = function( effectScript )
		AttachAvatarPosEffect(false, S201_magic_H107_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 0), 1, 100, "S201")
	CameraShake()
		PlaySound("wangzhezhijian")
	end,

	d = function( effectScript )
			DamageEffect(S201_magic_H107_attack.info_pool[effectScript.ID].Attacker, S201_magic_H107_attack.info_pool[effectScript.ID].Targeter, S201_magic_H107_attack.info_pool[effectScript.ID].AttackType, S201_magic_H107_attack.info_pool[effectScript.ID].AttackDataList, S201_magic_H107_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
