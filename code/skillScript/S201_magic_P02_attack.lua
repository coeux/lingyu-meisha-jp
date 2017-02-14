S201_magic_P02_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S201_magic_P02_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S201_magic_P02_attack.info_pool[effectScript.ID].Attacker)
		S201_magic_P02_attack.info_pool[effectScript.ID] = nil
	end,
	preLoad = function()
		PreLoadSound("odin")
		PreLoadSound("womanhit")
		PreLoadAvatar("S201")
		PreLoadSound("wangzhezhijian")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "dongzuo" )
		effectScript:RegisterEvent( 6, "dadf" )
		effectScript:RegisterEvent( 20, "sfasg" )
		effectScript:RegisterEvent( 33, "jinengtiex" )
		effectScript:RegisterEvent( 34, "jineng" )
	end,

	dongzuo = function( effectScript )
		SetAnimation(S201_magic_P02_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	dadf = function( effectScript )
			PlaySound("odin")
	end,

	sfasg = function( effectScript )
			PlaySound("womanhit")
	end,

	jinengtiex = function( effectScript )
		AttachAvatarPosEffect(false, S201_magic_P02_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(55, 0), 1, 100, "S201")
		PlaySound("wangzhezhijian")
	end,

	jineng = function( effectScript )
			DamageEffect(S201_magic_P02_attack.info_pool[effectScript.ID].Attacker, S201_magic_P02_attack.info_pool[effectScript.ID].Targeter, S201_magic_P02_attack.info_pool[effectScript.ID].AttackType, S201_magic_P02_attack.info_pool[effectScript.ID].AttackDataList, S201_magic_P02_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	CameraShake()
	end,

}
