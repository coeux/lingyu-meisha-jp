S253_magic_H011_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S253_magic_H011_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S253_magic_H011_attack.info_pool[effectScript.ID].Attacker)
        
		S253_magic_H011_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("skill_01104")
		PreLoadAvatar("H011_xuli")
		PreLoadSound("skill_01102")
		PreLoadSound("atalk_01101")
		PreLoadAvatar("S252_1")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "b" )
		effectScript:RegisterEvent( 16, "sfd" )
		effectScript:RegisterEvent( 18, "jhkjl" )
		effectScript:RegisterEvent( 45, "a" )
		effectScript:RegisterEvent( 59, "fghgfj" )
		effectScript:RegisterEvent( 60, "ewfef" )
		effectScript:RegisterEvent( 69, "c" )
		effectScript:RegisterEvent( 72, "z" )
		effectScript:RegisterEvent( 74, "t" )
		effectScript:RegisterEvent( 75, "v" )
	end,

	b = function( effectScript )
		SetAnimation(S253_magic_H011_attack.info_pool[effectScript.ID].Attacker, AnimationType.chant)
	end,

	sfd = function( effectScript )
			PlaySound("skill_01104")
	end,

	jhkjl = function( effectScript )
		AttachAvatarPosEffect(false, S253_magic_H011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(10, -10), 1.2, 100, "H011_xuli")
	end,

	a = function( effectScript )
		SetAnimation(S253_magic_H011_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill2)
	end,

	fghgfj = function( effectScript )
			PlaySound("skill_01102")
		PlaySound("atalk_01101")
	end,

	ewfef = function( effectScript )
		AttachAvatarPosEffect(false, S253_magic_H011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 90), 2, 100, "S252_1")
	end,

	c = function( effectScript )
			DamageEffect(S253_magic_H011_attack.info_pool[effectScript.ID].Attacker, S253_magic_H011_attack.info_pool[effectScript.ID].Targeter, S253_magic_H011_attack.info_pool[effectScript.ID].AttackType, S253_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S253_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	z = function( effectScript )
		CameraShake()
	end,

	t = function( effectScript )
			DamageEffect(S253_magic_H011_attack.info_pool[effectScript.ID].Attacker, S253_magic_H011_attack.info_pool[effectScript.ID].Targeter, S253_magic_H011_attack.info_pool[effectScript.ID].AttackType, S253_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S253_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	v = function( effectScript )
			DamageEffect(S253_magic_H011_attack.info_pool[effectScript.ID].Attacker, S253_magic_H011_attack.info_pool[effectScript.ID].Targeter, S253_magic_H011_attack.info_pool[effectScript.ID].AttackType, S253_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S253_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
