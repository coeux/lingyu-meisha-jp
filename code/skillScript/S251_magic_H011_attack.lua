S251_magic_H011_attack = 
{
	info_pool = {},

	init = function( effectScript )
		S251_magic_H011_attack.info_pool[effectScript.ID] = { Attacker = 0,Targeter = 0,  AttackType = 0, AttackDataList = {}, AttackIndex = 1 }
	end,

	clean = function( effectScript )
		EffectScriptEnd(S251_magic_H011_attack.info_pool[effectScript.ID].Attacker)
        
		S251_magic_H011_attack.info_pool[effectScript.ID] = nil
	end,

	preLoad = function()
		PreLoadSound("stalk_01101")
		PreLoadSound("skill_01101")
		PreLoadAvatar("S250_1")
		PreLoadAvatar("S250_2")
	end,

	run = function( effectScript )
		effectScript:RegisterEvent( 0, "d" )
		effectScript:RegisterEvent( 19, "sfsdag" )
		effectScript:RegisterEvent( 20, "s" )
		effectScript:RegisterEvent( 25, "adad" )
		effectScript:RegisterEvent( 26, "sadwd" )
		effectScript:RegisterEvent( 29, "h" )
		effectScript:RegisterEvent( 32, "gdhjhk" )
		effectScript:RegisterEvent( 34, "fdghjhj" )
		effectScript:RegisterEvent( 37, "fdgfj" )
	end,

	d = function( effectScript )
		SetAnimation(S251_magic_H011_attack.info_pool[effectScript.ID].Attacker, AnimationType.skill)
		PlaySound("stalk_01101")
	end,

	sfsdag = function( effectScript )
			PlaySound("skill_01101")
	end,

	s = function( effectScript )
		AttachAvatarPosEffect(false, S251_magic_H011_attack.info_pool[effectScript.ID].Attacker, AvatarPos.root, Vector2(100, 85), 2, 100, "S250_1")
	end,

	adad = function( effectScript )
		AttachAvatarPosEffect(false, S251_magic_H011_attack.info_pool[effectScript.ID].Targeter, AvatarPos.body, Vector2(0, 0), 2.2, 100, "S250_2")
	end,

	sadwd = function( effectScript )
			DamageEffect(S251_magic_H011_attack.info_pool[effectScript.ID].Attacker, S251_magic_H011_attack.info_pool[effectScript.ID].Targeter, S251_magic_H011_attack.info_pool[effectScript.ID].AttackType, S251_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S251_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	h = function( effectScript )
			DamageEffect(S251_magic_H011_attack.info_pool[effectScript.ID].Attacker, S251_magic_H011_attack.info_pool[effectScript.ID].Targeter, S251_magic_H011_attack.info_pool[effectScript.ID].AttackType, S251_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S251_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	gdhjhk = function( effectScript )
			DamageEffect(S251_magic_H011_attack.info_pool[effectScript.ID].Attacker, S251_magic_H011_attack.info_pool[effectScript.ID].Targeter, S251_magic_H011_attack.info_pool[effectScript.ID].AttackType, S251_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S251_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fdghjhj = function( effectScript )
			DamageEffect(S251_magic_H011_attack.info_pool[effectScript.ID].Attacker, S251_magic_H011_attack.info_pool[effectScript.ID].Targeter, S251_magic_H011_attack.info_pool[effectScript.ID].AttackType, S251_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S251_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

	fdgfj = function( effectScript )
			DamageEffect(S251_magic_H011_attack.info_pool[effectScript.ID].Attacker, S251_magic_H011_attack.info_pool[effectScript.ID].Targeter, S251_magic_H011_attack.info_pool[effectScript.ID].AttackType, S251_magic_H011_attack.info_pool[effectScript.ID].AttackDataList, S251_magic_H011_attack.info_pool[effectScript.ID].AttackIndex, effectScript)
	end,

}
