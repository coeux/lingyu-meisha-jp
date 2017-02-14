S201_magic_H021_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S201_magic_H021_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S201_magic_H021_attack.info_pool[effectScript.ID].Attacker)
		S201_magic_H021_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("manhit")
		PreLoadAvatar("S201")
		PreLoadSound("wangzhezhijian")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 15, "ad" )
		effectScript:RegisterEvent( 32, "jineng" )
		effectScript:RegisterEvent( 36, "doudong" )
		effectScript:RegisterEvent( 41, "shanghai" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(S201_magic_H021_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	ad = function( effectScript )
			PlaySound("manhit")
	end,

	jineng = function( effectScript )
		AttachAvatarPosEffect(false, S201_magic_H021_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(170, 0), 1.2, 100, "S201")
	end,

	doudong = function( effectScript )
		CameraShake()
	end,

	shanghai = function( effectScript )
			DamageEffect(S201_magic_H021_attack.info_pool[effectScript.ID].Attacker, S201_magic_H021_attack.info_pool[effectScript.ID].Targeter, S201_magic_H021_attack.info_pool[effectScript.ID].AttackType, S201_magic_H021_attack.info_pool[effectScript.ID].AttackDataList, S201_magic_H021_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
		PlaySound("wangzhezhijian")
	end,

}
