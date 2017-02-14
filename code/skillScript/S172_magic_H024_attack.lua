S172_magic_H024_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S172_magic_H024_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S172_magic_H024_attack.info_pool[effectScript.ID].Attacker)
        
		S172_magic_H024_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_02404")
		PreLoadAvatar("S170_1")
		PreLoadAvatar("S170_2")
		PreLoadSound("atalk_02401")
		PreLoadSound("skill_02403")
		PreLoadAvatar("S170_3")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "a" )
		effectScript:RegisterEvent( 4, "gfhj" )
		effectScript:RegisterEvent( 6, "fsdgfsg" )
		effectScript:RegisterEvent( 25, "adsg" )
		effectScript:RegisterEvent( 30, "v" )
		effectScript:RegisterEvent( 31, "fdgh" )
		effectScript:RegisterEvent( 38, "qwe" )
		effectScript:RegisterEvent( 39, "f" )
		effectScript:RegisterEvent( 42, "d" )
		effectScript:RegisterEvent( 45, "dsgdgh" )
	end,

	a = function( effectScript )
		SetAnimation(S172_magic_H024_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
	end,

	gfhj = function( effectScript )
			PlaySound("skill_02404")
	end,

	fsdgfsg = function( effectScript )
		AttachAvatarPosEffect(false, S172_magic_H024_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(40, 75), 2, 100, "S170_1")
	end,

	adsg = function( effectScript )
		AttachAvatarPosEffect(false, S172_magic_H024_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, 100), 2, 100, "S170_2")
		PlaySound("atalk_02401")
	end,

	v = function( effectScript )
		CameraShake()
	end,

	fdgh = function( effectScript )
			PlaySound("skill_02403")
	end,

	qwe = function( effectScript )
			DamageEffect(S172_magic_H024_attack.info_pool[effectScript.ID].Attacker, S172_magic_H024_attack.info_pool[effectScript.ID].Targeter, S172_magic_H024_attack.info_pool[effectScript.ID].AttackType, S172_magic_H024_attack.info_pool[effectScript.ID].AttackDataList, S172_magic_H024_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	f = function( effectScript )
		AttachAvatarPosEffect(false, S172_magic_H024_attack.info_pool[effectScript.ID].Targeter, AvatarPos.root, Vector2(0, -10), 2, 100, "S170_3")
	end,

	d = function( effectScript )
			DamageEffect(S172_magic_H024_attack.info_pool[effectScript.ID].Attacker, S172_magic_H024_attack.info_pool[effectScript.ID].Targeter, S172_magic_H024_attack.info_pool[effectScript.ID].AttackType, S172_magic_H024_attack.info_pool[effectScript.ID].AttackDataList, S172_magic_H024_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	dsgdgh = function( effectScript )
			DamageEffect(S172_magic_H024_attack.info_pool[effectScript.ID].Attacker, S172_magic_H024_attack.info_pool[effectScript.ID].Targeter, S172_magic_H024_attack.info_pool[effectScript.ID].AttackType, S172_magic_H024_attack.info_pool[effectScript.ID].AttackDataList, S172_magic_H024_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
