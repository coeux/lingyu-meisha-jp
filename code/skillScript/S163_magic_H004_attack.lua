S163_magic_H004_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S163_magic_H004_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S163_magic_H004_attack.info_pool[effectScript.ID].Attacker)
		S163_magic_H004_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("manhit")
		PreLoadAvatar("S201")
		PreLoadSound("wangzhezhijian")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 11, "da" )
		effectScript:RegisterEvent( 32, "jinengtiex" )
		effectScript:RegisterEvent( 33, "jineng" )
		effectScript:RegisterEvent( 37, "wrsf" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(S163_magic_H004_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	da = function( effectScript )
			PlaySound("manhit")
	end,

	jinengtiex = function( effectScript )
		AttachAvatarPosEffect(false, S163_magic_H004_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(140, 0), 1, 100, "S201")
		PlaySound("wangzhezhijian")
	end,

	jineng = function( effectScript )
			DamageEffect(S163_magic_H004_attack.info_pool[effectScript.ID].Attacker, S163_magic_H004_attack.info_pool[effectScript.ID].Targeter, S163_magic_H004_attack.info_pool[effectScript.ID].AttackType, S163_magic_H004_attack.info_pool[effectScript.ID].AttackDataList, S163_magic_H004_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

	wrsf = function( effectScript )
		CameraShake()
	end,

}	